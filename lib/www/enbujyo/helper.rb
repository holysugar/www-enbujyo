module WWW
  class Enbujyo
    module ExtendedAgent
      def auth_get(url)
        baseurl = URI.parse('http://enbujyo.3594t.com/')
        url = (baseurl + url).to_s
        ret = get(url)
        if /error/i =~ page.uri.to_s or /エラー/ =~ page.title 
          if self.autologin?
            login
            ret = get(url)
            if /error/i =~ page.uri.to_s or /エラー/ =~ page.title 
              raise LoginError
            end
          else
            raise LoginError
          end
        end
        ret
      end
      def autologin=(b)
        @autologin = b
      end
      def autologin?
        @autologin
      end
    end

    module Utils
      module_function
      def random_string(length = 10, strings = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
        Array.new(length).map{ strings[rand(strings.size),1] }.join
      end

      def download_movie(agent, url, options = {})
        puts "Downloading #{url} ..."
        tmpname = "_enbujyo_download.#{random_string}.wmv"
        open(tmpname, 'w'){|tmp|
          tmp.print agent.get_file(url)
        }
        if options[:filename]
          filename = options[:filename]
        elsif agent.page.response['content-disposition']
          /filename="(.*?)"/ =~ agent.page.response['content-disposition']
          if $1
            filename = windows? ? $1 : NKF.nkf('-Sw', $1) # cp932 -> utf-8
          end
        end
        if filename
          FileUtils.mv(tmpname, filename)
        else
          filename = tmpname
        end
        puts "Downloading #{filename} has finished."
        filename
      end

      def windows?
        RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
      end

      def hack_json(jsonstr)
        jsonstr.sub(/^\w+=/,'').gsub(/\},.*\]/m, '}]')
      end
    end
  end
end



