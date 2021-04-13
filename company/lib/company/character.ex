defmodule Company.Character do
  use Ecto.Schema

  schema "characters" do
    field(:name, :string)
    belongs_to(:movie, Company.Movie, references: :id)
  end
end
