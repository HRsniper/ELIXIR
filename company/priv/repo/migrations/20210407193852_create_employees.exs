defmodule Company.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add(:name, :string, null: false)
      add(:age, :integer, default: 0)
    end
  end
end
