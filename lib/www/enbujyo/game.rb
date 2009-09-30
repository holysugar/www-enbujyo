require 'time'
require 'json'

require 'www/enbujyo/helper'

module WWW
  class Enbujyo
    class Game
      attr_reader :player0, :deck0, :location0, :player1, :deck1, :location1,
        :date, :movie_date, :publish_date
      attr_reader :id, :options

      def initialize(p0, p0deck, p0loc, p1, p1deck, p1loc, options = {})
        @player0 = p0
        @deck0 = p0deck
        @location0 = p0loc
        @player1 = p1
        @deck1 = p1deck
        @location1 = p1loc

        @date = Time.parse(options['date']) if options['date']
        @movie_date = Date.parse(options['movie_date']) if options['movie_date']
        @publish_date = Date.parse(options['publish_date']) if options['publish_date']
        case options[:p0result]
        when 'lose'
          @winner = 1
        when 'win'
          @winner = 0
        end

        @id = options[:id]

        @options = options
      end

      def to_s
        return <<-EOD
#{player0} #{"「#{player0.team}」" if player0.team}
#{location0}
#{deck0}
---
#{player1} #{"「#{player1.team}」" if player1.team}
#{location1}
#{deck1}
        EOD
      end

      def self.parse_replay(agent, id)
        url = "http://enbujyo.3594t.com/members/replay.cgi?u=#{id}"
        gamedata = agent.get(url).body
        parse(gamedata, id)[0]
      end

      def self.parse(gamedata, id = nil)
        if gamedata.is_a? String
          json = Utils.hack_json(gamedata)
          gamedata = JSON.parse(json)
        end

        game = gamedata['replay'].collect{|rep|

          rep[:id] = id if id

          p0, p0deck, p0loc = _parse_player_data('p0', rep)
          p1, p1deck, p1loc = _parse_player_data('p1', rep)

          new(p0, p0deck, p0loc, p1, p1deck, p1loc, rep)
        }
        game
      end

      def self._parse_player_data(prefix, rep)
        deck = Deck.new
        rep.keys.grep(/#{prefix}card_params_\d/).sort.each{|k|
          deck.cards.push WWW::Enbujyo::Card.parse_from_jsonstr(rep[k])
        }
        %w|0 1|.each do |num|
          next unless rep[prefix+'staff_image_'+num]

          deck.gcards.push(WWW::Enbujyo::Gunshi.new(
            :image => rep[prefix+'staff_image_'+num],
            :level => rep[prefix+'staff_level_'+num],
            :longname => rep[prefix+'staff_name_'+num],
            :team => rep[prefix+'staff_seiryoku_name_'+num],
            :attribute => rep[prefix+'staff_zokusei_name'],
            :strategy => rep[prefix+'strategy_name'],
            :ex => rep[prefix+'skill_ex_name']
          ))
        end
        player = WWW::Enbujyo::Player.new(
          :name => rep[prefix+'name'],
          :name_image_url => rep[prefix+'image'],
          :team => rep[prefix+'team_name'],
          :title => rep[prefix+'grade_name'],
          :brave => rep[prefix+'brave'],
          :brave_desc => rep[prefix+'brave_desc'],
          :rank => rep[prefix+'rank'],
          :wins => rep[prefix+'win'],
          :loses => rep[prefix+'lose'],
          :rate => rep[prefix+'win_rate']
        )
        location = WWW::Enbujyo::Location.new(
          :pref => rep[prefix+'pref_name'],
          :office => rep[prefix+'office']
        )
        return [player, deck, location]
      end
    end
  end
end
 
