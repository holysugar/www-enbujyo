require 'www/enbujyo/util'

module WWW
  class Enbujyo
    class Player
      attr_reader :name, :name_image_url, :pclass, :title

      def initialize(attr)
        p attr
        @name         = attr[:name]
        @name_image_url = attr[:name_image_url]
        @accesscode   = attr[:accesscode]

        @title        = attr[:title]

        @pclass       = PlayerClass.create(attr)
      end

      def description
        return <<-EOD
#{@name}
#{@pclass}
        EOD
      end

      def self.parse
      end

    end

    class PlayerClass
      def self.create(attr)
        case
        when attr[:akashi]
          Hasya.new(attr)
        when attr[:hin]
          Hin.new(attr)
        when attr[:kyuu]
          Kyuu.new(attr)
        else
          warn "No PlayerClass: #{attr.inspect}"
        end
      end
    end

    class Hasya < PlayerClass
      attr_reader :title, :akashi, :seibou
      def initialize(attr)
        @title  = attr[:title]
        @akashi = attr[:akashi]
        @seibou = attr[:seibou].to_i
      end
      def to_s
        "#{@title} 証: #{@akashi} 声望値: #{@seibou}%"
      end
    end

    class Hin < PlayerClass
      attr_reader :title, :hin, :buyuu
      def initialize(attr)
        @title = attr[:title]
        @buyuu = attr[:buyuu].to_i
        @hin   = Util.ch_to_i(attr[:title].match(/./)[0])
      end
      def to_s
        "#{@title} 武勇: #{@buyuu}"
      end
    end

    class Kyu < PlayerClass
      def initialize(attr)
        raise NotImplementedError
      end
    end

  end
end

