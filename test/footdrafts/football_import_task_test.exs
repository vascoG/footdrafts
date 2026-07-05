defmodule FootDrafts.FootballImportTaskTest do
  use FootDrafts.DataCase, async: false

  import ExUnit.CaptureIO

  alias FootDrafts.Football.{Club, Competition, Player}
  alias FootDrafts.Repo

  test "mix football_data.import imports the stubbed payload idempotently" do
    first_run_output = capture_io(fn -> Mix.Tasks.FootballData.Import.run(["pl"]) end)

    assert first_run_output =~ "Imported PL Competition (PL): 2 clubs, 3 players"
    assert Repo.aggregate(Competition, :count) == 1
    assert Repo.aggregate(Club, :count) == 2
    assert Repo.aggregate(Player, :count) == 3

    second_run_output = capture_io(fn -> Mix.Tasks.FootballData.Import.run(["PL"]) end)

    assert second_run_output =~ "Imported PL Competition (PL): 2 clubs, 3 players"
    assert Repo.aggregate(Competition, :count) == 1
    assert Repo.aggregate(Club, :count) == 2
    assert Repo.aggregate(Player, :count) == 3
  end

  test "mix football_data.import raises with no competition code" do
    assert_raise Mix.Error, ~r/usage: mix football_data.import <competition_code>/, fn ->
      Mix.Tasks.FootballData.Import.run([])
    end
  end
end
