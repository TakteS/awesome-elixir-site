defmodule AwesomeElixir.List.Lib.Validator do
  @moduledoc false

  import Ecto.Changeset
  alias AwesomeElixir.List.Lib

  @required_fields [:name, :description, :url, :stars_count, :last_commit_date, :category_id]

  @spec changeset(%Lib{}, map) :: Ecto.Changeset.t()
  def changeset(lib, params \\ %{}) do
    lib
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
    |> unique_constraint(:url)
  end
end
