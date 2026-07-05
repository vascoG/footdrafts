defmodule FootDrafts.Football.PlayerRating do
  use Ecto.Schema

  import Ecto.Changeset

  alias FootDrafts.Football.Player

  @type t :: %__MODULE__{}

  schema "player_ratings" do
    field :season, :string
    field :rating, :decimal

    belongs_to :player, Player

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(player_rating, attrs) do
    player_rating
    |> cast(attrs, [:player_id, :season, :rating])
    |> validate_required([:player_id, :season, :rating])
    |> foreign_key_constraint(:player_id)
    |> unique_constraint([:player_id, :season])
  end
end
