require "pleaserun/namespace"
require "insist"

module PleaseRun::Configurable
  class ConfigurationError < ::StandardError; end
  class ValidationError < ConfigurationError; end

  module Mixin
    def self.included(klass)
      klass.extend(ClassMixin)

      m = respond_to?(:initialize) ? method(:initialize) : nil
      define_method(:initialize) do |*args, &block|
        m.call(*args, &block) if m
        configurable_setup
      end
    end

    def configurable_setup
      @attributes = {}
      self.class.ancestors.each do |ancestor|
        #if ancestor.respond_to?(:attributes)
        if ancestor.include?(PleaseRun::Configurable::Mixin)
          ancestor.attributes.each do |facet|
            @attributes[facet.name] = facet.clone
          end
        end
      end
    end
  end

  module ClassMixin
    def attribute(name, description, options={}, &validator)
      facet = Facet.new(name, description, options, &validator)
      attributes << facet

      # define '<name>' and '<name>=' methods
      define_method(name.to_sym) do
        # object instance, not class ivar
        @attributes[name.to_sym].value
      end

      define_method("#{name}=".to_sym) do |value|
        # object instance, not class ivar
        @attributes[name.to_sym].value = value
      end

      define_method("#{name}?".to_sym) do
        return @attributes[name.to_sym].set?
      end

    end

    def attributes
      return (@attributes ||= [])
    end
  end

  class Facet
    attr_reader :name
    attr_reader :description

    def initialize(name, description, options={}, &validator)
      insist { name }.is_a?(Symbol)
      insist { description }.is_a?(String)
      insist { options }.is_a?(Hash)
      
      @name = name
      @description = description
      @options = options
      @validator = validator if block_given?

      if @options[:default]
        validate(@options[:default])
      end
    end

    def value=(v)
      validate(v)
      @value = v
    end

    def validate(v)
      return @validator.call(v) if @validator
    rescue
      raise ValidationError, "Invalid value '#{v.inspect}' for attribute '#{name}'"
    end

    def value
      return @value if @value
      return @options[:default] if @options.include?(:default)
      return nil
    end

    def set?
      return !@value.nil?
    end
  end
end
