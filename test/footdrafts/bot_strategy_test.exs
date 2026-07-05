defmodule FootDrafts.BotStrategyTest do
  use ExUnit.Case, async: true

  alias FootDrafts.BotStrategy

  @players %{
    1 => %{rating: 95},
    2 => %{rating: 90},
    3 => %{rating: 88},
    4 => %{rating: 86},
    5 => %{rating: 84},
    6 => %{rating: 82},
    7 => %{rating: 80},
    8 => %{rating: 78},
    9 => %{rating: 76},
    10 => %{rating: 74}
  }

  test "hard picks the top rated legal player" do
    assert BotStrategy.pick_player_id(Map.keys(@players), @players, :hard) == 1
  end

  test "medium picks from top 5" do
    pick = BotStrategy.pick_player_id(Map.keys(@players), @players, :medium)
    assert pick in [1, 2, 3, 4, 5]
  end

  test "easy picks from ranks 3 through 10" do
    pick = BotStrategy.pick_player_id(Map.keys(@players), @players, :easy)
    assert pick in [3, 4, 5, 6, 7, 8, 9, 10]
  end

  test "easy falls back when less than 3 legal players exist" do
    legal_ids = [1, 2]
    pick = BotStrategy.pick_player_id(legal_ids, @players, :easy)
    assert pick in legal_ids
  end

  test "returns nil when there are no legal players" do
    assert BotStrategy.pick_player_id([], @players, :medium) == nil
  end
end
