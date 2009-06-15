# -*- mode:ruby; coding:utf-8 -*-

module WWW
  class Enbujyo
    module Util
      ch_number_table = {
        '〇' => 0,
        '一' => 1,
        '二' => 2,
        '三' => 3,
        '四' => 4,
        '五' => 5,
        '六' => 6,
        '七' => 7,
        '八' => 8,
        '九' => 9,
        '十' => 10,
      }
      def self.ch_to_i(chinesenumber)
        ch_number_table[chinesenumber]
      end
    end
  end
end


