# -*- mode:ruby; coding:utf-8 -*-

module WWW
  class Enbujyo
    class Deck
      attr_accessor :cards, :gcards
      def initialize
        @cards = []
        @gcards = []
      end

      def to_s
        [
          @cards.collect{|c| c.to_s }.join("\n"),
          @gcards.collect{|c| "軍師:" + c.to_s }.join("\n")
        ].join("\n")
      end
    end

    class Gunshi
      attr_accessor :name, :rarity, :image, :team, :level,
        :strategy, :attribute, :ex
      def initialize(options = {})
        @image = options[:image]
        @level = options[:level]
        @name  = options[:name]
        @rarity = options[:rarity]
        @team  = options[:team]
        @attribute = options[:attribute]
        @strategy  = options[:strategy]
        @ex  = options[:ex]

        unless /^http/ =~ @image 
          @image = 'http://enbujyo.3594t.com/img/game/cards/' + @image
        end
        if options[:longname]
          _, @team, @rarity, @name = options[:longname].match(/(.+?)([A-Z]{1,2})(.*)/u).to_a
        end
      end

      def to_s
        "#{team}#{rarity}#{name}"
      end

      def description
        "#{team}#{rarity}#{name} #{attribute}/#{strategy}/Lv.#{level}"
      end
 
    end

    class Card
      attr_accessor :name, :cost, :strength, :intelligence, :attribute,
        :icon, :image, :team, :rarity
      def initialize(options = {})
        @name = options[:name]
        @cost = options[:cost]
        @strength = options[:strength]
        @intelligence = options[:intelligence]
        @attribute = options[:attribute]
        @icon = options[:icon]
        @image = options[:image]
        @team = options[:team]
        @rarity = options[:rarity]
      end

      def self.parse_from_jsonstr(string)
        # SAMPLE: arcade_icon_yarihei_gun.gif,1.0,3,,1,群C程遠志,天,4b5ea861463d15dc.gif
        icon, cost, strength, _, intelligence, longname, attribute, image = string.split(/,/)
        _, team, rarity, name = longname.match(/(.+?)([A-Z]{1,2})(.*)/u).to_a

        Card.new({
            :name => name,
            :cost => cost,
            :strength => strength,
            :intelligence => intelligence,
            :attribute => attribute,
            :icon => 'http://enbujyo.3594t.com/img/game/ico/' + icon,
            :image => 'http://enbujyo.3594t.com/img/game/cards/' + image,
            :team => team,
            :rarity => rarity,
        })
      end

      def to_s
        "#{team}#{rarity}#{name}"
      end
      def description
        "#{team}#{rarity}#{name} #{cost}/#{strength}/#{intelligence}/#{attribute}"
      end
    end
  end
end

