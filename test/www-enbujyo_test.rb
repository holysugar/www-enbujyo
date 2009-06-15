require 'test_helper'
require 'yaml'

class WwwEnbujyoTest < Test::Unit::TestCase
  context "WWW::Enbujyo instance" do
    setup do
      param = YAML.load_file("#{ENV['HOME']}/.enbujyorc")
      @agent = WWW::Enbujyo.new(
        :mail => param['mail'],
        :password => param['password']
      )
    end

    context "login method" do
      should "return true" do
        assert @agent.login
      end
    end

    context "player_user method" do
      should "return valid player hashdata" do
        @agent.login
        player = @agent.player_user
        puts player.description
        assert player.name
        assert player.pclass
      end
    end
  end
end

