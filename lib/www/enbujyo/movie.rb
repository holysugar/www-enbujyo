# -*- mode:ruby; coding:utf-8 -*-
require 'www/enbujyo/helper'

module WWW
  class Enbujyo
    class Movie
      include WWW::Enbujyo::Utils
      STATES = [:none, :accepted, :encoding, :completed, :downloaded, :unavailable]
      RESULT = [:win, :draw, :lose]

      # needed
      attr_reader :title, :date, :result, :status

      # maybe nil
      attr_reader :encoded_at, :requested_at, :bought_at, :published_at
      attr_reader :download_limit, :download_left
      attr_reader :thumbnail
      attr_reader :url, :delete_url
      attr_reader :id
      attr_reader :game
      attr_reader :yours

      def initialize(agent, info, game, max_download = 5)
        @agent = agent

        @game = game

        @title = info[:title] or warn 'Movie: title not found'
        @date = info[:date] or warn 'Movie: date not found'
        @result = info[:result]
        @result = case info[:result]
                  when /勝利/ : :win
                  when /敗北/ : :lose
                  when /分/   : :draw
                  else
                    warn 'Movie: result not found'
                  end

        @status = case info[:encode_status]
        when /受付中/ : :accepted
        when /エンコード中/ : :encoding
        else
          if info[:yours]
            :yours
          elsif info[:download_left].nil?
            :completed
          elsif info[:download_left] > 0
            :downloaded
          else
            :unavailable
          end
        end

        @encoded_at = info[:encoded_at]
        @requested_at = info[:requested_at]
        @bought_at = info[:bought_at]
        @published_at = info[:published_at]
        @download_limit = info[:download_limit]
        @download_left = info[:download_left]
        @thumbnails = info[:thumbnails]

        @url = info[:url] || info[:purchase_url] 
        @id = Movie.url_to_id(@url) if @url
        @delete_url = info[:delete_url]
      end

      def download
        unless @url
          warn "Can't download this movie yet."
          return false
        end
        case @status
        when :completed
          download_completed(@url)
        when :downloaded
          if /download-conf.html/ =~ @url 
            download_completed(@url)
          else
            download_downloaded(@url)
          end
        else
          warn "Can't download this movie."
          return false
        end
      end

      def downloadable?
        [:downloaded, :completed].include? @status
      end

      def self.url_to_id(url)
        url.scan(/u=(.*)/).to_s
      end

      private
      def download_completed(url)
        page = @agent.auth_get url
        # XXX: 動画券がないときの処理.
        link = page.links.find{|l| /download-ok\.html/ =~ l.href }
        if link
          download_downloaded(page.uri + link.href)
        else
          warn "Download link is not found in #{page.uri}"
          false
        end
      end

      def download_downloaded(url)
        page = @agent.auth_get url
        link = page.links.find{|l| /download.cgi/ =~ l.href }
        if link
          download_movie(@agent, page.uri + link.href)
        else
          warn "Download link is not found in #{page.uri}"
          false
        end
      end
    end
  end
end
 
