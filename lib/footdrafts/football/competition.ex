defmodule FootDrafts.Football.Competition do
  use Ecto.Schema

  import Ecto.Changeset

  alias FootDrafts.Football.Club

  @type t :: %__MODULE__{}

  schema "competitions" do
    field :name, :string
    field :country, :string
    field :tier, :integer
    field :external_id, :string

    has_many :clubs, Club

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(competition, attrs) do
    competition
    |> cast(attrs, [:name, :country, :tier, :external_id])
    |> validate_required([:name, :external_id])
    |> unique_constraint(:external_id)
  end
end
