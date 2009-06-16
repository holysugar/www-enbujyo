
module WWW
  class Enbujyo
    class Location
      attr_reader :pref, :office
      def initialize(options = {})
        @pref = options[:pref]
        @office = options[:office]
      end
      def to_s
        "#{@pref} #{@office}"
      end
    end
  end
end

 
