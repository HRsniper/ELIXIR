defmodule Company.Distributor do
  use Ecto.Schema

  schema "distributors" do
    field(:name, :string)
    belongs_to(:movie, Company.Movie, references: :id)
  end
end
