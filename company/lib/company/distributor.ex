defmodule Company.Distributor do
  use Ecto.Schema

  schema "distributors" do
    field(:name, :string)
    belongs_to(:movies, Company.Movie)
  end
end
