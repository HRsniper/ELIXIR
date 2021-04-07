defmodule Company.Employee do
  use Ecto.Schema

  import Ecto.Changeset

  schema "employees" do
    field(:name, :string)
    field(:age, :integer, default: 0)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2)
    |> validate_fictional_name()
  end

  @fictional_names ["Black Panther", "Wonder Woman", "Spiderman", "Flash"]

  def validate_fictional_name(changeset) do
    name = get_field(changeset, :name)

    if name in @fictional_names do
      changeset
    else
      add_error(changeset, :name, "is not a superhero")
    end
  end

  def set_name_if_anonymous(changeset) do
    name = get_field(changeset, :name)

    if is_nil(name) do
      put_change(changeset, :name, "Anonymous")
    else
      changeset
    end
  end

  def registration_changeset(struct, params) do
    struct
    |> cast(params, [:name, :age])
    |> set_name_if_anonymous()
  end

  def set_employee(struct, params) do
    struct
    |> registration_changeset(params)
    |> validate_fictional_name()
    |> Company.Repo.insert!()
  end
end
