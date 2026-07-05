defmodule FootDrafts.Repo.Migrations.CreateFootballDataFoundation do
  use Ecto.Migration

  def change do
    create table(:competitions) do
      add :name, :string, null: false
      add :country, :string
      add :tier, :integer
      add :external_id, :string, null: false

      timestamps()
    end

    create unique_index(:competitions, [:external_id])

    create table(:clubs) do
      add :name, :string, null: false
      add :country, :string
      add :external_id, :string, null: false
      add :competition_id, references(:competitions, on_delete: :restrict), null: false

      timestamps()
    end

    create unique_index(:clubs, [:external_id])
    create index(:clubs, [:competition_id])

    create table(:players) do
      add :name, :string, null: false
      add :position, :string
      add :nationality, :string
      add :birth_date, :date
      add :birth_city, :string
      add :external_id, :string, null: false
      add :club_id, references(:clubs, on_delete: :restrict), null: false

      timestamps()
    end

    create unique_index(:players, [:external_id])
    create index(:players, [:club_id])

    create table(:player_stats) do
      add :player_id, references(:players, on_delete: :delete_all), null: false
      add :season, :string, null: false
      add :goals, :integer, null: false, default: 0
      add :assists, :integer, null: false, default: 0
      add :appearances, :integer, null: false, default: 0
      add :minutes_played, :integer, null: false, default: 0

      timestamps()
    end

    create index(:player_stats, [:player_id])
    create unique_index(:player_stats, [:player_id, :season])

    create table(:player_ratings) do
      add :player_id, references(:players, on_delete: :delete_all), null: false
      add :season, :string, null: false
      add :rating, :decimal, null: false

      timestamps()
    end

    create index(:player_ratings, [:player_id])
    create unique_index(:player_ratings, [:player_id, :season])
  end
end
