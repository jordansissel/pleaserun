require "testenv"
require "pleaserun/mustache_methods"

describe PleaseRun::MustacheMethods do
  subject do
    Class.new
      include PleaseRun::MustacheMethods

      def whatever
        return "hello world"
      end
    end
  end

end
