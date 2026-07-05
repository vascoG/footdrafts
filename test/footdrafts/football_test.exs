defmodule FootDrafts.FootballTest do
  use FootDrafts.DataCase, async: true

  alias FootDrafts.Football
  alias FootDrafts.Football.{Club, Competition, Player, PlayerRating}
  alias FootDrafts.Repo

  test "list_players/1 returns worldwide players with club and competition preloaded" do
    premier_league = competition_fixture(%{external_id: "PL", name: "Premier League"})
    la_liga = competition_fixture(%{external_id: "LL", name: "La Liga"})

    arsenal = club_fixture(premier_league, %{external_id: "ARS", name: "Arsenal"})
    madrid = club_fixture(la_liga, %{external_id: "RMA", name: "Real Madrid"})

    saka = player_fixture(arsenal, %{external_id: "SAKA", name: "Bukayo Saka"})
    mbappe = player_fixture(madrid, %{external_id: "MBAPPE", name: "Kylian Mbappe"})

    players = Football.list_players(:worldwide)

    assert Enum.map(players, & &1.id) == [saka.id, mbappe.id]
    assert Enum.all?(players, &Ecto.assoc_loaded?(&1.club))
    assert Enum.all?(players, &Ecto.assoc_loaded?(&1.competition))
  end

  test "list_players/1 filters by competition id" do
    premier_league = competition_fixture(%{external_id: "PL", name: "Premier League"})
    la_liga = competition_fixture(%{external_id: "LL", name: "La Liga"})

    arsenal = club_fixture(premier_league, %{external_id: "ARS", name: "Arsenal"})
    madrid = club_fixture(la_liga, %{external_id: "RMA", name: "Real Madrid"})

    saka = player_fixture(arsenal, %{external_id: "SAKA", name: "Bukayo Saka"})
    _mbappe = player_fixture(madrid, %{external_id: "MBAPPE", name: "Kylian Mbappe"})

    assert [player] = Football.list_players(premier_league.id)
    assert player.id == saka.id
    assert player.club.competition_id == premier_league.id
    assert player.competition.id == premier_league.id
  end

  test "hidden_rating_for/2 only returns hidden rating values" do
    competition = competition_fixture(%{external_id: "PL", name: "Premier League"})
    club = club_fixture(competition, %{external_id: "ARS", name: "Arsenal"})
    player = player_fixture(club, %{external_id: "SAKA", name: "Bukayo Saka"})

    Repo.insert!(%PlayerRating{player_id: player.id, season: "2025", rating: Decimal.new("92.4")})

    assert Decimal.equal?(Football.hidden_rating_for(player.id, "2025"), Decimal.new("92.4"))
    assert Football.hidden_rating_for(player.id, "2024") == nil
  end

  defp competition_fixture(attrs) do
    %Competition{}
    |> Competition.changeset(attrs)
    |> Repo.insert!()
  end

  defp club_fixture(competition, attrs) do
    %Club{competition_id: competition.id}
    |> Club.changeset(attrs)
    |> Repo.insert!()
  end

  defp player_fixture(club, attrs) do
    %Player{club_id: club.id}
    |> Player.changeset(attrs)
    |> Repo.insert!()
  end
end
