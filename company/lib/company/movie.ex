defmodule Company.Movie do
  use Ecto.Schema

  schema "movies" do
    field(:title, :string)
    field(:tagline, :string)
    has_many(:characters, Company.Character)
    has_one(:distributor, Company.Distributor)
    many_to_many(:actors, Company.Actor, join_through: "movies_actors")
  end
end
