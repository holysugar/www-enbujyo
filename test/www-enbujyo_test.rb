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
        game = @agent.get_selection_info[0]
        assert game.player0.is_a? WWW::Enbujyo::Player
        assert game.player1.is_a? WWW::Enbujyo::Player
        assert game.deck0.is_a? WWW::Enbujyo::Deck
        assert game.deck1.is_a? WWW::Enbujyo::Deck
        assert game.location0.is_a? WWW::Enbujyo::Location
        assert game.location1.is_a? WWW::Enbujyo::Location
      end

      should "return special valid game data" do
        @agent.login
        game = @agent.get_selection_info(:feature)[0]
        assert game.player0.is_a? WWW::Enbujyo::Player
        assert game.player1.is_a? WWW::Enbujyo::Player
        assert game.deck0.is_a? WWW::Enbujyo::Deck
        assert game.deck1.is_a? WWW::Enbujyo::Deck
        assert game.location0.is_a? WWW::Enbujyo::Location
        assert game.location1.is_a? WWW::Enbujyo::Location
      end

      should "return valid archive game data" do
        @agent.login
        games = @agent.get_selection_info(:archive)
        assert_operator(10, :<, games.length) # usually 30
        game = games[0]
        assert game.player0.is_a? WWW::Enbujyo::Player
        assert game.player1.is_a? WWW::Enbujyo::Player
        assert game.deck0.is_a? WWW::Enbujyo::Deck
        assert game.deck1.is_a? WWW::Enbujyo::Deck
        assert game.location0.is_a? WWW::Enbujyo::Location
        assert game.location1.is_a? WWW::Enbujyo::Location
      end

      should "return valid archive game data in a day" do
        @agent.login
        games = @agent.get_selection_info(:archive, 3.days.ago.to_date)
        game = games[0]
        assert_equal(3.days.ago.to_date, game.publish_date)
        assert game.player0.is_a? WWW::Enbujyo::Player
        assert game.player1.is_a? WWW::Enbujyo::Player
        assert game.deck0.is_a? WWW::Enbujyo::Deck
        assert game.deck1.is_a? WWW::Enbujyo::Deck
        assert game.location0.is_a? WWW::Enbujyo::Location
        assert game.location1.is_a? WWW::Enbujyo::Location
      end
    end

    context "my_movies method" do
      should "return my movie information list" do
        @agent.login
        movies = @agent.my_movies
        assert_operator(5, :>=, movies.length)
      end
    end

  end
end

