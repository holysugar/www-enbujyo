require 'www/enbujyo/game'
require 'www/enbujyo/movie'
require 'activesupport'

module WWW
  class Enbujyo
    class Selection
      attr_reader :mode, :url

      def initialize(agent, mode = :latest)
        @agent = agent
        @mode = mode

        @cgiurl = @agent.baseurl + '/members/selection/selection.cgi'
        
        case @mode
        when :latest
          url = @agent.baseurl + '/members/selection/index.html'
        when :feature
          url = @agent.baseurl + '/members/selection/feature/index.html'
        when :archive
          url = @agent.baseurl + '/members/selection/archive.html'
        else
          raise InvalidArgumentError(mode)
        end
        @url = url.to_s

      end

      def get_information(options = {})
        referer = @url

        if options[:date]
          date = options[:date].is_a?(Date) ? options[:date].strftime("%Y%m%d") : options[:date]
          q = "date=#{date}&version=1"
        else
          q = "mode=#{@mode}&version=1"
        end
        page = @agent.get("#{@cgiurl}?#{q}", [], referer)
        Game.parse(page.body)
      end

      def download(movie_type, date = nil, force = false)
        date ||= (Time.now - 60*60*17).strftime("%Y%m%d")  # 17時で切り替え/JST前提
        movie_date = Selection.date_to_query(date)
        movie_type = Movie.movietype_query(movie_type)

        @agent.auth_get @url # referer

        downloadurl = "http://download.enbujyo.3594t.com/selection_download.cgi?date=#{movie_date}&type=#{movie_type}"
        if movie_type == 's'
          return Utils.download_movie(@agent, downloadurl)
        end

        case check(movie_type, date)['result']
        when 'RESULT_ALREADY_PURCHASE_MAX_DOWNLOADS'
          warn "Selection downloads max time."
          return false
        when 'RESULT_ALREADY_PURCHASE'
          puts "REAULT ALREADY PURCHASE!"
          # do nothing
        else # 'RESULT_NOT_PURCHASE'
          puts "GOING TO PURCHASE!"
          opt = {
            'date' => date,
            'mode' => 'purchase',
            'type' => movie_type,
            'version' => 1,
            'r' => rand,
          }
          @agent.get @url # referer
          opt['feature'] = date if @mode == :feature
          puts "Purchase movie at #{@cgiurl}: #{opt}"
          @agent.post(@cgiurl, opt)
       end
        if @mode == :feature
          downloadurl += "&content=feature&loc=/feature/"
        end
        return Utils.download_movie(@agent, downloadurl)
      end

      def check(movie_type, date)
        referer = @url
        movie_type = Movie.movietype_query(movie_type)
        q = "mode=check&date=#{date}&type=#{movie_type}&version=1"
        page = @agent.get("#{@cgiurl}?#{q}", [], referer)
        JSON.parse(Utils.hack_json(page.body))
      end

      def self.date_to_query(date)
        (date.is_a?(Date) or date.is_a?(Time)) ? date.strftime("%Y%m%d") : date
      end
      
    end
  end
end
 
