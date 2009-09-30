
module WWW
  class Enbujyo
    class Player
      attr_reader :name, :name_image_url, :pclass, :title,
        :brave, :brave_desc, :seibou, :rank, :team,
        :wins, :loses, :games, :draws, :rate

      def initialize(attr)
        @name         = attr[:name]
        @name_image_url = 'http://enbujyo.3594t.com' + attr[:name_image_url] rescue ''
        @accesscode   = attr[:accesscode]
        @team       = attr[:team]

        @title      = attr[:title]
        @brave      = attr[:brave]
        @brave_desc = attr[:brave_desc]
        @seibou     = attr[:seibou]
        @rank       = attr[:rank]

        @games = attr[:games]
        @wins  = attr[:wins]
        @loses = attr[:loses]
        @draws = attr[:draws]
        @rate  = attr[:rate]
      end

      def akashi?
        @brave_desc == '証'
      end

      def to_s
        "#{@name} #{@brave_desc}:#{@brave}"
      end

      def description
        "#{@name} #{@brave_desc}:#{@brave}\n" +
        "#{@wins}勝 #{@loses}負 勝率#{@rate}%"
      end

    end
  end
end

