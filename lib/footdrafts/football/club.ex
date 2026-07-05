defmodule FootDrafts.Football.Club do
  use Ecto.Schema

  import Ecto.Changeset

  alias FootDrafts.Football.{Competition, Player}

  @type t :: %__MODULE__{}

  schema "clubs" do
    field :name, :string
    field :country, :string
    field :external_id, :string

    belongs_to :competition, Competition
    has_many :players, Player

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(club, attrs) do
    club
    |> cast(attrs, [:name, :country, :external_id])
    |> validate_required([:name, :external_id])
    |> foreign_key_constraint(:competition_id)
    |> unique_constraint(:external_id)
  end
end
