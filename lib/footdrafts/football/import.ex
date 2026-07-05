defmodule FootDrafts.Football.Import do
  @moduledoc false

  alias FootDrafts.Football

  @type competition_attrs :: %{
          required(:name) => String.t(),
          optional(:country) => String.t() | nil,
          optional(:tier) => integer() | nil,
          required(:external_id) => String.t()
        }

  @type club_attrs :: %{
          required(:name) => String.t(),
          optional(:country) => String.t() | nil,
          required(:external_id) => String.t(),
          required(:players) => [player_attrs()]
        }

  @type player_attrs :: %{
          required(:name) => String.t(),
          optional(:position) => String.t() | nil,
          optional(:nationality) => String.t() | nil,
          optional(:birth_date) => Date.t() | nil,
          optional(:birth_city) => String.t() | nil,
          required(:external_id) => String.t()
        }

  @type competition_payload :: %{
          required(:competition) => competition_attrs(),
          required(:clubs) => [club_attrs()]
        }

  @type import_result :: %{
          competition: FootDrafts.Football.Competition.t(),
          clubs: non_neg_integer(),
          players: non_neg_integer()
        }

  @spec import_competition!(String.t()) :: import_result()
  def import_competition!(competition_code) do
    payload = fetch_competition_payload!(competition_code)

    {:ok, {competition, clubs, players}} =
      FootDrafts.Repo.transaction(fn ->
        competition = Football.upsert_competition!(payload.competition)

        {club_count, player_count} =
          Enum.reduce(payload.clubs, {0, 0}, fn club_payload, {clubs, players} ->
            club =
              club_payload
              |> Map.drop([:players])
              |> Map.put(:competition_id, competition.id)
              |> Football.upsert_club!()

            imported_players =
              Enum.map(club_payload.players, fn player_payload ->
                player_payload
                |> Map.put(:club_id, club.id)
                |> Football.upsert_player!()
              end)

            {clubs + 1, players + length(imported_players)}
          end)

        {competition, club_count, player_count}
      end)

    %{competition: competition, clubs: clubs, players: players}
  end

  @spec fetch_competition_payload!(String.t()) :: competition_payload()
  defp fetch_competition_payload!(competition_code) do
    normalized_code = String.upcase(String.trim(competition_code))

    # TODO: Replace this stubbed payload with a Req call to football-data.org and
    # map the API response into the competition/clubs/players shape defined here.
    %{
      competition: %{
        name: "#{normalized_code} Competition",
        country: "Unknown",
        tier: 1,
        external_id: normalized_code
      },
      clubs: [
        %{
          name: "#{normalized_code} City",
          country: "Unknown",
          external_id: "#{normalized_code}-club-1",
          players: [
            %{
              name: "#{normalized_code} Keeper",
              position: "Goalkeeper",
              nationality: "Unknown",
              birth_date: ~D[1998-01-01],
              birth_city: "Unknown",
              external_id: "#{normalized_code}-player-1"
            },
            %{
              name: "#{normalized_code} Forward",
              position: "Forward",
              nationality: "Unknown",
              birth_date: ~D[2000-03-15],
              birth_city: "Unknown",
              external_id: "#{normalized_code}-player-2"
            }
          ]
        },
        %{
          name: "#{normalized_code} United",
          country: "Unknown",
          external_id: "#{normalized_code}-club-2",
          players: [
            %{
              name: "#{normalized_code} Midfielder",
              position: "Midfielder",
              nationality: "Unknown",
              birth_date: ~D[1999-06-30],
              birth_city: "Unknown",
              external_id: "#{normalized_code}-player-3"
            }
          ]
        }
      ]
    }
  end
end
