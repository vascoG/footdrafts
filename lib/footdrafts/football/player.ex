defmodule FootDrafts.Football.Player do
  use Ecto.Schema

  import Ecto.Changeset

  alias FootDrafts.Football.{Club, PlayerRating, PlayerStat}

  @type t :: %__MODULE__{}

  schema "players" do
    field :name, :string
    field :position, :string
    field :nationality, :string
    field :birth_date, :date
    field :birth_city, :string
    field :external_id, :string

    belongs_to :club, Club
    has_one :competition, through: [:club, :competition]
    has_many :player_stats, PlayerStat
    has_many :player_ratings, PlayerRating

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :name,
      :position,
      :nationality,
      :birth_date,
      :birth_city,
      :external_id,
      :club_id
    ])
    |> validate_required([:name, :external_id, :club_id])
    |> foreign_key_constraint(:club_id)
    |> unique_constraint(:external_id)
  end
end
