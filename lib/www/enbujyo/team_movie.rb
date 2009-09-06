require 'www/enbujyo/game'
require 'www/enbujyo/movie'
require 'activesupport'

module WWW
  class Enbujyo
    class TeamMovie
      def initialize(agent)
        @agent = agent
      end

      def parse
        page = @agent.auth_get '/members/teambox/index.html'

        movies_info_html = page.search('div.st_movie_info')
        movies_info = movies_info_html.select{|div|
          div.search('.st_movie_info_empty_image').empty?
        }.collect do |div|
          info = {}
          info[:title] = div.search('div.st_movie_info_desc_battle_vs').text
          date = div.search('div.st_movie_info_desc_battle_date span')
          info[:date] = Time.parse(date[0].text)
          info[:result] = date[1].text
          info[:movie] = div.search('div.st_movie_info_desc_movie').text

          div.search('div.st_movie_info_datetime_date').each do |d|
            case d.text
            when /公開日時: (20\d\d-\d\d-\d\d \d\d:\d\d:\d\d)/
              info[:published_at] = Time.parse($1)
            when /残りダウンロード回数: (\d+)回/
              info[:download_left] = $1.to_i
            when /あなたの公開動画/
              info[:yours] = true
            end
          end

          info[:thumbnails] = div.search('div.st_movie_info_thumbnail_mini_all a/@href').collect(&:to_s)

          if download = div.search('span.st_reserve_menu_download_l a/@href')[0]
            info[:url] = (page.uri + download.to_s).to_s unless download.to_s.blank?
          end

          viewurl = div.search('span.st_reserve_menu_view_l a/@href')[0].to_s
          id = Movie.url_to_id(viewurl)

          game = Game.parse_replay(@agent, id)
          Movie.new(@agent, info, game)
        end

        movies_info
      end
    end
  end
end
 
