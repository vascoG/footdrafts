defmodule FootDrafts.Football do
  @moduledoc """
  Data access for competitions, clubs, players, and draft-facing player data.
  """

  import Ecto.Query

  alias FootDrafts.Repo
  alias FootDrafts.Football.{Club, Competition, Player, PlayerRating}

  @type player_scope :: :worldwide | pos_integer()

  @spec list_players(player_scope()) :: [Player.t()]
  def list_players(:worldwide) do
    Player
    |> order_by([player], asc: player.name)
    |> Repo.all()
    |> Repo.preload([:club, :competition])
  end

  def list_players(competition_id) when is_integer(competition_id) do
    Player
    |> join(:inner, [player], club in assoc(player, :club))
    |> where([_player, club], club.competition_id == ^competition_id)
    |> order_by([player, _club], asc: player.name)
    |> Repo.all()
    |> Repo.preload([:club, :competition])
  end

  @spec hidden_rating_for(pos_integer(), String.t()) :: Decimal.t() | nil
  def hidden_rating_for(player_id, season) do
    PlayerRating
    |> Repo.get_by(player_id: player_id, season: season)
    |> case do
      nil -> nil
      rating -> rating.rating
    end
  end

  @spec upsert_competition!(map()) :: Competition.t()
  def upsert_competition!(attrs) do
    %Competition{}
    |> Competition.changeset(attrs)
    |> Repo.insert!(
      conflict_target: :external_id,
      on_conflict: {:replace, [:name, :country, :tier, :updated_at]},
      returning: true
    )
  end

  @spec upsert_club!(map()) :: Club.t()
  def upsert_club!(attrs) do
    %Club{competition_id: Map.get(attrs, :competition_id)}
    |> Club.changeset(attrs)
    |> Repo.insert!(
      conflict_target: :external_id,
      on_conflict: {:replace, [:name, :country, :competition_id, :updated_at]},
      returning: true
    )
  end

  @spec upsert_player!(map()) :: Player.t()
  def upsert_player!(attrs) do
    %Player{club_id: Map.fetch!(attrs, :club_id)}
    |> Player.changeset(Map.delete(attrs, :club_id))
    |> Repo.insert!(
      conflict_target: :external_id,
      on_conflict:
        {:replace,
         [
           :name,
           :position,
           :nationality,
           :birth_date,
           :birth_city,
           :club_id,
           :updated_at
         ]},
      returning: true
    )
  end

  @spec upsert_player_rating!(map()) :: PlayerRating.t()
  def upsert_player_rating!(attrs) do
    %PlayerRating{player_id: Map.fetch!(attrs, :player_id)}
    |> PlayerRating.changeset(Map.delete(attrs, :player_id))
    |> Repo.insert!(
      conflict_target: [:player_id, :season],
      on_conflict: {:replace, [:rating, :updated_at]},
      returning: true
    )
  end
end
