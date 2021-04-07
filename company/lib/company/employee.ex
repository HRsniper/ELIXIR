defmodule Company.Employee do
  use Ecto.Schema

  schema "employees" do
    field(:name, :string)
    field(:age, :integer, default: 0)
  end
end
