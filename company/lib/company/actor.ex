defmodule Company.Actor do
  use Ecto.Schema

  schema "actors" do
    field(:name, :string)
    many_to_many(:movies, Company.Movie, join_through: "movies_actors")
  end
end
