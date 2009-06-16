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
        player = @agent.get_player_user
        assert player.name
        assert player.title
      end
    end

    context "get_selection_info method" do
      should "return valid game data" do
        @agent.login
        game = @agent.get_selection_info
        assert game.player0.is_a? WWW::Enbujyo::Player
        assert game.player1.is_a? WWW::Enbujyo::Player
        assert game.deck0.is_a? WWW::Enbujyo::Deck
        assert game.deck1.is_a? WWW::Enbujyo::Deck
        assert game.location0.is_a? WWW::Enbujyo::Location
        assert game.location1.is_a? WWW::Enbujyo::Location
      end
    end
  end
end

