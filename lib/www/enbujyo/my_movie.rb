require 'www/enbujyo/game'
require 'www/enbujyo/movie'
require 'activesupport'

module WWW
  class Enbujyo
    class MyMovie
      def initialize(agent)
        @agent = agent
      end

      def parse
        page = @agent.auth_get '/members/movie/list.html'
        slots_status = page.search('div[@class="st_block_info2_body"] a')

        movies_info_html = page.search('div.st_movie_info')
        movies_info = movies_info_html.collect do |div|
          info = {}
          info[:title] = div.search('div.st_movie_info_desc_battle_vs').text
          date = div.search('div.st_movie_info_desc_battle_date span')
          info[:date] = Time.parse(date[0].text)
          info[:result] = date[1].text
          info[:movie] = div.search('div.st_movie_info_desc_movie').text

          # if completed...

          div.search('div.st_movie_info_datetime_date').each do |d|
            case d.text
            when /完成日時: (20.*?)/
              info[:encoded_at] = Time.parse($1)
            when /完成日時: \[(.*?)\]/
              info[:encode_status] = $1
            when /発注日時: (20.*?)/
              info[:requested_at] = Time.parse($1)
            when /購入日時: (20.*?)/
              info[:bought_at] = Time.parse($1)
            when /ダウンロード期限: (20.*?)/
              info[:download_limit] = Time.parse($1)
            when /残りダウンロード回数: (\d+)回/
              info[:download_left] = $1.to_i
            end
          end

          id = div.search('*/@u')[0].to_s

          if thumbnail = div.search('div.st_movie_info_thumbnail_mini_all')
            info[:thumbnails] = thumbnail.search('a/@href').collect(&:to_s)
          end
          if download = div.search('span.st_reserve_menu_download_l a/@href')[0]
            info[:url] = (page.uri + download.to_s).to_s unless download.to_s.blank?
          end
          if purchase_url = div.search('span.st_reserve_menu_purchase_l a/@href')[0]
            info[:purchase_url] = (page.uri + purchase_url.to_s).to_s
          end
          if delete_url = div.search('span.st_reserve_menu_delete_l a/@href')[0]
            info[:delete_url] = page.uri + delete_url.to_s
          end

          game = Game.parse_replay(@agent, id)
          Movie.new(info, game)
        end
        movies_info
      end

    end
  end
end
 
