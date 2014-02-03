require "pleaserun/namespace"
require "insist"

# A mixin class that provides 'attribute' to a class.
# The main use for such attributes is to provide validation for mutators.
#
# Example:
#
#     class Person
#       include PleaseRun::Configurable
#
#       attribute :greeting, "A simple greeting" do |greeting|
#         # do any validation here.
#         raise "Greeting must be a string!" unless greeting.is_a?(String)
#       end
#     end
#
#     person = Person.new
#     person.greeting = 1234 # Fails!
#     person.greeting = "Hello, world!"
#
#     puts person.greeting
#     # "Hello, world!"
module PleaseRun::Configurable
  class ConfigurationError < ::StandardError; end
  class ValidationError < ConfigurationError; end

  def self.included(klass)
    klass.extend(ClassMixin)

    m = respond_to?(:initialize) ? method(:initialize) : nil
    define_method(:initialize) do |*args, &block|
      m.call(*args, &block) if m
      configurable_setup
    end
  end # def self.included

  def configurable_setup
    @attributes = {}
    self.class.ancestors.each do |ancestor|
      next unless ancestor.include?(PleaseRun::Configurable)
      ancestor.attributes.each do |facet|
        @attributes[facet.name] = facet.clone
      end
    end
  end # def configurable_setup

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
    end # def attribute

    def attributes
      return @attributes ||= []
    end

    def all_attributes
      return ancestors.select { |a| a.respond_to?(:attributes) }.collect{ |a| a.attributes }.flatten
    end # def attributes
  end # def ClassMixin

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
    end # def initialize

    def value=(v)
      validate(v)
      @value = v
    end # def value=

    def validate(v)
      return @validator.call(v) if @validator
    rescue
      raise ValidationError, "Invalid value '#{v.inspect}' for attribute '#{name}'"
    end # def validate

    def value
      return @value if @value
      return @options[:default] if @options.include?(:default)
      return nil
    end # def value

    def set?
      return !@value.nil?
    end # def set?
  end # class Facet
end # module PleaseRun::Configurable
