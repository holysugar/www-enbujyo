require 'test_helper'

class WwwEnbujyoTest < Test::Unit::TestCase
  context "WWW::Enbujyo instance" do
    setup do
      @agent = WWW::Enbujyo.new(
        :mail => 'XXX',
        :password => 'XXX'
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
        assert player[:name]
        assert player[:class]
        assert player[:games]
      end
    end
  end
end

