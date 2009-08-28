# -*- mode:ruby; coding:utf-8 -*-
$KCODE = 'u'

require 'mechanize'
require 'logger'
require 'tempfile'
require 'fileutils'
require 'nkf'
require 'json'

require 'www/enbujyo/player'
require 'www/enbujyo/deck'
require 'www/enbujyo/location'
require 'www/enbujyo/game'

#
# SEGA の三国志大戦公式サイトへアクセスするライブラリ.
#
module WWW
  class Enbujyo
    attr_accessor :mail, :password
    attr_reader :agent

    class LoginError < RuntimeError; end

    def initialize(options = {})
      @agent = options.delete(:agent)
      @mail = options.delete(:mail)
      @password = options.delete(:password)
      @options = options
      unless @agent
        @agent = WWW::Mechanize.new
        @agent.user_agent_alias = 'Windows Mozilla'
      end
    end

    def login
      @agent.get('http://enbujyo.3594t.com/')
      @agent.page.form_with(:action => '/action.cgi') {|f|
        f.field_with(:name => 'mail').value = @mail
        f.field_with(:name => 'password').value = @password
        f.click_button
      }
      raise LoginError if /error/i =~ @agent.page.uri.to_s
      true
    end

    def get_player_user(reload = false)
      if reload or not @player_user
        auth_get(@agent, 'http://enbujyo.3594t.com/members/player/index.html')
        @player_user = get_player_data(@agent)
      end
      @player_user
    end

    def get_player_data(page_loaded_agent)
      player = {}

      div1 = page_loaded_agent.page.search('div.st_block_info3')[0]
      div1text = div1.text
      player[:name_image_url] = div1.search('img')[0]['src']
      player[:name] = div1text.scan(/\b君主名:(.*)\s/)[0][0]
      player[:accesscode] = div1text.scan(/\bACCESS CODE:(\d+)\s/)[0][0]

      div2 = page_loaded_agent.page.search('div.st_block_info3_body')[0]
      div2text = div2.text
      player[:title] = div2text.scan(/\b称号:(.*)\s/)[0][0]
      player[:brave_desc], player[:brave] = div2text.scan(/\b(証|武勇):(.*)\s/)[0]
      player[:seibou] = div2text.scan(/\b声望値:(.*%)\s/)[0][0] rescue nil

      div3 = page_loaded_agent.page.search('div.st_block_info3_body')[1]
      div3text = div3.text
      #/全(\d+)戦(\d+)勝\s*(\d+)敗\s*(\d+)分.*連勝数:(\d+)連勝\s*最高連勝数:(\d+)連勝\s*最新10戦:(.+)\s*全国順位:(\d+)位/m =~ div3.text
      
      player[:games] = div3text.scan(/全(\d+)戦/)[0][0].to_i rescue nil
      player[:wins] = div3text.scan(/(\d+)勝/)[0][0].to_i rescue nil
      player[:loses] = div3text.scan(/(\d+)敗/)[0][0].to_i rescue nil
      player[:draws] = div3text.scan(/(\d+)分/)[0][0].to_i rescue nil
      player[:rate] = div3text.scan(/勝率:([\d\.]+)%/)[0][0] rescue nil
      player[:consecutive_wins] = div3text.scan(/連勝数:(\d+)連勝/)[0][0].to_i rescue nil
      player[:max_consecutive_wins] = div3text.scan(/最高連勝数:(\d+)連勝/)[0][0].to_i rescue nil 
      player[:ten_games] = div3text.scan(/最新10戦:(.+)/)[0][0] rescue nil
      player[:rank] = div3text.scan(/全国順位:(\d+)位/)[0][0].to_i rescue nil

      Player.new(player)
    end

    def get_selection_info
      @agent.post('http://enbujyo.3594t.com/members/selection/selection.cgi', {
        'mode' => 'latest',
        'version' => 1
      })
      json = hack_json(@agent.page.body)
      obj = JSON.parse(json)
      rep = obj['replay'][0]

      p0, p0deck, p0loc = get_selection_info_build('p0', rep)
      p1, p1deck, p1loc = get_selection_info_build('p1', rep)

      game = WWW::Enbujyo::Game.new(p0, p0deck, p0loc, p1, p1deck, p1loc, rep)
      game
    end

    def get_selection_info_build(prefix, rep)
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

    def download_selection(movie_type = 's')
      movie_date = (Time.now - 60*60*17).strftime("%Y%m%d")  # 17時で切り替え/JST前提
      auth_get(@agent, 'http://enbujyo.3594t.com/members/selection/index.html')

      tmpname = "_enbujyo_download.#{random_string}.wmv"
      open(tmpname, 'w'){|tmp|
        tmp.print @agent.get_file("http://download.enbujyo.3594t.com/selection_download.cgi?date=#{movie_date}&type=#{movie_type}")
      }
      filename = "selection_#{movie_date}.wmv"
      if @agent.page.response['content-disposition']
        /filename="(.*\.wmv)"/ =~ @agent.page.response['content-disposition']
        filename = windows? ? $1 : NKF.nkf('-Sw', $1)
      end
      FileUtils.mv(tmpname, filename)
      puts "Downloading #{filename} has finished." unless silent?
      filename
    end

    private
    def random_string(length = 10, strings = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
      Array.new(length).map{ strings[rand(strings.size),1] }.join
    end

    def windows?
      RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    end

    def silent?
      @options[:silent]
    end

    def auto_relogin?
      @options[:auto_relogin]
    end

    def auth_get(agent, url)
      ret = agent.get(url)
      if /error/i =~ agent.page.uri.to_s or /エラー/ =~ agent.page.title 
        if auto_relogin?
          login
        else
          raise LoginError
        end
      end
      ret
    end

    def hack_json(jsonstr)
      jsonstr.sub(/^\w+=/,'').gsub(/\},.*\]/m, '}]')
    end

  end
end

