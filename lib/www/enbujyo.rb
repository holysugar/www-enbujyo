# -*- mode:ruby; coding:utf-8 -*-
$KCODE = 'u'

require 'mechanize'
require 'logger'
require 'tempfile'
require 'fileutils'
require 'nkf'

require 'www/enbujyo/player'

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

    def player_user(reload = false)
      if reload or not @player_user
        auth_get(@agent, 'http://enbujyo.3594t.com/members/player/index.html')
        @player_user = get_player_data(@agent)
      end
      @player_user
    end

    def get_player_data(page_loaded_agent)
      player = {}

      div1 = page_loaded_agent.page.search('div.st_block_info3')[0]
      player[:username_url] = div1.search('img')[0]['src']
      player[:name] = div1.text.scan(/\b君主名:(.*)\s/)[0][0]
      player[:accesscode] = div1.text.scan(/\bACCESS CODE:(\d+)\s/)[0][0]

      div2 = page_loaded_agent.page.search('div.st_block_info3_body')[0]
      player[:class] = div2.text.scan(/\b称号:(.*)\s/)[0][0]
      player[:akashi] = div2.text.scan(/\b証:(.*)\s/)[0][0] rescue nil
      player[:buyuu] = div2.text.scan(/\b武勇:(.*)\s/)[0][0] rescue nil
      player[:seibou] = div2.text.scan(/\b声望値:(.*)\s/)[0][0] rescue nil

      div3 = page_loaded_agent.page.search('div.st_block_info3_body')[1]
      /全(\d+)戦(\d+)勝\s*(\d+)敗\s*(\d+)分.*連勝数:(\d+)連勝\s*最高連勝数:(\d+)連勝\s*最新10戦:(.+)\s*全国順位:(\d+)位/m =~ div3.text
      player[:games] = $1.to_i
      player[:wins] = $2.to_i
      player[:loses] = $3.to_i
      player[:draws] = $4.to_i
      player[:consecutive_wins] = $5.to_i
      player[:max_consecutive_wins] = $6.to_i
      player[:ten_games] = $7
      player[:rank] = $8.to_i

      player
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

  end
end

