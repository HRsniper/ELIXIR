defmodule Company.Character do
  use Ecto.Schema

  schema "characters" do
    field(:name, :string)
    belongs_to(:movies, Company.Movie)
  end
end
