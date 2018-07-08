defmodule AwesomeElixir.List.Category.Validator do
  @moduledoc false

  alias AwesomeElixir.List.Category
  import Ecto.Changeset

  @required_fields [:name, :description]

  @spec changeset(%Category{}, map) :: Ecto.Changeset.t()
  def changeset(category, params \\ %{}) do
    category
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
