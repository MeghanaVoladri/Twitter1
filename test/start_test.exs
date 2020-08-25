defmodule Proj4Test do
  use ExUnit.Case, async: false
  doctest Proj4.Start

  setup do
    {:ok, server_pid} = Task.start(fn -> Proj4.Server.start_link() end)
    :ets.new(:register, [:set, :public, :named_table])
    :ets.new(:clients_directory, [:set, :public, :named_table])
    :ets.new(:tweets, [:set, :public, :named_table])
    :ets.new(:mentions, [:set, :public, :named_table])
    :ets.new(:subscribed, [:set, :public, :named_table])
    :ets.new(:followers, [:set, :public, :named_table])
    {:ok, server: server_pid}
  end

  test "User registration" do
    Proj4.Server.register("6", self())

    assert :ets.lookup(:clients_directory, "6") == [
             {"6", self()}
           ]

    assert_received {:registerConfirmation}
  end

  test "Check for entries with Hashtag1" do
    Proj4.Server.register("5", self())
    Proj4.Server.handle_tweet("Tweet1 @1 #Hashtag1", "5")

    assert :ets.lookup(:mentions, "#Hashtag1") == [
             {"#Hashtag1",
              [
                "Tweet1 @1 #Hashtag1"
              ]}
           ]
  end

  test "Multiple users tweeting with same #Hashtag1" do
    Proj4.Server.register("5", self())
    Proj4.Server.register("6", self())
    Proj4.Server.handle_tweet("Tweet1by5 @1 #Hashtag1", "5")
    Proj4.Server.handle_tweet("Tweet2by5 @4 #Hashtag1", "5")
    Proj4.Server.handle_tweet("Tweet1by6 @1 #Hashtag1", "6")

    assert :ets.lookup(:mentions, "#Hashtag1") == [
             {"#Hashtag1",
              [
                "Tweet1by6 @1 #Hashtag1",
                "Tweet2by5 @4 #Hashtag1",
                "Tweet1by5 @1 #Hashtag1"
              ]}
           ]
  end

  test "Add Subscribers" do
    Proj4.Server.register("5", self())
    Proj4.Server.register("6", self())
    Proj4.Server.register("7", self())
    Proj4.Server.handle_add_subscriber("5", "6")
    Proj4.Server.handle_add_subscriber("5", "7")

    assert :ets.lookup(:followers, "5") == [
             {"5",
              [
                "7",
                "6"
              ]}
           ]
  end

  test "Add Subscribed" do
    Proj4.Server.register("5", self())
    Proj4.Server.register("6", self())
    Proj4.Server.register("7", self())
    Proj4.Server.handle_subscribers("5", ["6", "7"])

    assert :ets.lookup(:subscribed, "5") == [
             {"5",
              [
                ["6", "7"]
              ]}
           ]
  end

  test "Get subscribed tweets" do
    Proj4.Server.register("10", self())
    Proj4.Server.register("12", self())
    Process.sleep(1000)
    Proj4.Server.handle_tweet("Tweet1by @Client_1 #Hashtag1", "12")
    Process.sleep(1000)
    Proj4.Server.handle_subscribers("10", "12")
    Process.sleep(1000)
    Proj4.Server.handle_subscribed_tweets("10")
    Process.sleep(1000)
    assert_received {:registerConfirmation}
    assert_received {:registerConfirmation}
    assert_received {:registerConfirmation}

    assert_received {:handle_subscribed_atom,
                     [
                       "Tweet1by @Client_1 #Hashtag1"
                     ]}
  end

  test "Disconnect" do
    Proj4.Server.register("15", self())
    assert_received {:registerConfirmation}
    Proj4.Server.handle_disconnect_client("15")

    assert :ets.lookup(:clients_directory, "15") == [
             {"15", nil}
           ]
  end

  test "Get all tweets" do
    Proj4.Server.register("15", self())
    Proj4.Server.handle_tweet("Tweet1by @Client_1 #Hashtag1", "15")
    Proj4.Server.handle_tweet("Tweet2by @Client_4 #Hashtag1", "15")
    Proj4.Server.handle_tweet("Tweet3by @Client_1 #Hashtag1", "15")
    assert :ets.lookup(:tweets, "15") == [
      {"15",
       [
         "Tweet3by @Client_1 #Hashtag1",
         "Tweet2by @Client_4 #Hashtag1",
         "Tweet1by @Client_1 #Hashtag1"
       ]}
    ]

  end

  test "Get Subscribed list" do
    Proj4.Server.register("16", self())
    Proj4.Server.register("17", self())
    Proj4.Server.register("18", self())
    Proj4.Server.handle_subscribed_tweets("16")
    Proj4.Server.handle_subscribers("16", "17")
    Proj4.Server.handle_subscribers("16", "18")
    assert :ets.lookup(:subscribed, "16") == [
      {"16",
       [
         "18","17"
       ]}
    ]
  end

  test "Add subscribed" do
    Proj4.Server.register("5", self())
    Proj4.Server.register("6", self())
    :ets.insert(:followers, {"5", "6"})
    assert :ets.lookup(:followers, "5") == [
             {"5",  "6"}
           ]
  end

  test "Add subscribers" do
    Proj4.Server.register("5", self())
    Proj4.Server.register("6", self())
    Proj4.Server.handle_add_subscriber("5","6")
    assert :ets.lookup(:followers, "5") == [
             {"5", ["6"]}
           ]
  end

  test "Creating random tweet" do
    Proj4.Server.register("6", self())
    Proj4.Server.handle_tweet("bla @bla #bla", "6")

    assert :ets.lookup(:tweets, "6") == [
             {"6",
              [
                "bla @bla #bla"
              ]}
           ]
  end

  test "user creating multiple tweets" do
    Proj4.Server.register("5", self())
    Proj4.Server.handle_tweet("Tweet1 @Client_1 #Hashtag1", "5")
    Proj4.Server.handle_tweet("Tweet2 @Client_2 #Hashtag2", "5")

    assert :ets.lookup(:tweets, "5") == [
             {"5",
              [
                "Tweet2 @Client_2 #Hashtag2",
                "Tweet1 @Client_1 #Hashtag1"
              ]}
           ]
  end

  test "Add hashtag" do
    Proj4.Server.insert_hashtags("#Hashtag", "Tweet @Client_1 #Hashtag")
    assert :ets.lookup(:mentions, "#Hashtag") == [
      {"#Hashtag",
       [
         "Tweet @Client_1 #Hashtag"
       ]}
    ]
  end

  test "lookup hashtag" do
    Proj4.Server.register("5", self())
    :ets.insert(:mentions,{"#Hashtag", ["Tweet @Client_5 #Hashtag"]})
    Proj4.Server.handle_tweet_hashtags("#Hashtag","5")
    assert_received {:registerConfirmation}    
    assert_received {:handle_hashtag_atom,["Tweet @Client_5 #Hashtag"]}
  end

  test "lookup mention" do
    Proj4.Server.register("5",self())
    :ets.insert(:mentions,{"5", ["Tweet @Client_5 #Hashtag"]})
    Proj4.Server.handle_tweet_mentions("5")
    assert_received {:registerConfirmation}    
    assert_received {:query_mentions, ["Tweet @Client_5 #Hashtag"]}
  end

end
