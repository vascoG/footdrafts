defmodule FootDrafts.Football.PlayerStat do
  use Ecto.Schema

  import Ecto.Changeset

  alias FootDrafts.Football.Player

  @type t :: %__MODULE__{}

  schema "player_stats" do
    field :season, :string
    field :goals, :integer, default: 0
    field :assists, :integer, default: 0
    field :appearances, :integer, default: 0
    field :minutes_played, :integer, default: 0

    belongs_to :player, Player

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(player_stat, attrs) do
    player_stat
    |> cast(attrs, [:player_id, :season, :goals, :assists, :appearances, :minutes_played])
    |> validate_required([:player_id, :season])
    |> foreign_key_constraint(:player_id)
    |> unique_constraint([:player_id, :season])
  end
end
