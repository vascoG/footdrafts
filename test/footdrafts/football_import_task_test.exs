defmodule FootDrafts.FootballImportTaskTest do
  use FootDrafts.DataCase, async: false

  import ExUnit.CaptureIO

  alias FootDrafts.Football.{Club, Competition, Player, PlayerRating}
  alias FootDrafts.Repo

  test "mix football_data.import imports the stubbed payload idempotently" do
    first_run_output = capture_io(fn -> Mix.Tasks.FootballData.Import.run(["pl"]) end)

    assert first_run_output =~ "Imported PL Competition (PL): 2 clubs, 3 players"
    assert Repo.aggregate(Competition, :count, :id) == 1
    assert Repo.aggregate(Club, :count, :id) == 2
    assert Repo.aggregate(Player, :count, :id) == 3

    second_run_output = capture_io(fn -> Mix.Tasks.FootballData.Import.run(["PL"]) end)

    assert second_run_output =~ "Imported PL Competition (PL): 2 clubs, 3 players"
    assert Repo.aggregate(Competition, :count, :id) == 1
    assert Repo.aggregate(Club, :count, :id) == 2
    assert Repo.aggregate(Player, :count, :id) == 3
  end

  test "mix football_data.import raises with no competition code" do
    assert_raise Mix.Error, ~r/usage: mix football_data.import <competition_code>/, fn ->
      Mix.Tasks.FootballData.Import.run([])
    end
  end

  test "mix football_data.import EPL imports top clubs with ratings" do
    output = capture_io(fn -> Mix.Tasks.FootballData.Import.run(["EPL"]) end)

    assert output =~ "Imported Premier League (EPL): 5 clubs, 75 players"

    competition = Repo.get_by!(Competition, external_id: "EPL")

    clubs =
      Club
      |> Repo.all()
      |> Enum.filter(&(&1.competition_id == competition.id))
      |> Enum.map(& &1.name)

    assert Enum.sort(clubs) == [
             "Arsenal",
             "Chelsea",
             "Liverpool",
             "Manchester City",
             "Manchester United"
           ]

    assert Repo.get_by!(Player, external_id: "EPL-MCI-HAALAND").name == "Erling Haaland"
    assert Repo.get_by!(Player, external_id: "EPL-LIV-SALAH").name == "Mohamed Salah"
    assert Repo.get_by!(Player, external_id: "EPL-ARS-SAKA").name == "Bukayo Saka"
    assert Repo.get_by!(Player, external_id: "EPL-MUN-BFERNANDES").name == "Bruno Fernandes"
    assert Repo.get_by!(Player, external_id: "EPL-CHE-PALMER").name == "Cole Palmer"

    haaland = Repo.get_by!(Player, external_id: "EPL-MCI-HAALAND")
    haaland_rating = Repo.get_by!(PlayerRating, player_id: haaland.id, season: "2026")
    assert Decimal.equal?(haaland_rating.rating, Decimal.new("91"))
  end
end
