defmodule Friends.Repo.Migrations.CreateDistributors do
  use Ecto.Migration

  def change do
    create table(:distributors) do
      add(:name, :string)
      add(:movie_id, references(:movies))
    end

    create unique_index(:distributors, [:movie_id])
  end
end
