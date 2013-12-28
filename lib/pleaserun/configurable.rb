require "pleaserun/namespace"

module PleaseRun::Configurable
  class Facet
    def initialize(@name, @description, @options={}); end
  end

  def self.config(name, description, options={})
    @configuration ||= {}
    @configuration[name] = Facet.new(name, description, options)
  end
end
