require 'time'

module WWW
  class Enbujyo
    class Game
      attr_reader :player0, :deck0, :location0, :player1, :deck1, :location1,
        :date, :movie_date

      def initialize(p0, p0deck, p0loc, p1, p1deck, p1loc, options = {})
        @player0 = p0
        @deck0 = p0deck
        @location0 = p0loc
        @player1 = p1
        @deck1 = p1deck
        @location1 = p1loc

        @date = Time.parse(options['date']) if options['date']
        @movie_date = Date.parse(options['movie_date']) if options['movie_date']
        case options[:p0result]
        when 'lose'
          @winner = 1
        when 'win'
          @winner = 0
        end
      end

      def to_s
        return <<-EOD
#{player0} #{"「#{player0.team}」" if player0.team}
#{location0}
#{deck0}
----
#{player1} #{"「#{player1.team}」" if player1.team}
#{location1}
#{deck1}
        EOD
      end
    end
  end
end
 
