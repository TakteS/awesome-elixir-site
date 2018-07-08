defmodule AwesomeElixir.List do
  @moduledoc "List's context module."

  alias AwesomeElixir.Repo
  alias AwesomeElixir.List.{Category, Lib}
  alias AwesomeElixir.List.Category.Validator, as: ListValidator
  alias AwesomeElixir.List.Lib.UseCase.CreateOrUpdate, as: CreateOrUpdateLib
  import Ecto.Query, only: [from: 2]

  defdelegate create_or_update_lib(params), to: CreateOrUpdateLib, as: :run

  @doc "Updates category if already exists or creates new one."
  @spec create_or_update_category(map) :: {:ok, %Category{}} | {:error, Ecto.Changeset.t()}
  def create_or_update_category(%{"name" => name} = params) when not (name in [nil, ""]) do
    category = Repo.get_by(Category, name: params["name"])
    if category, do: update_category(category, params), else: create_category(params)
  end

  @doc "Finds all categories with libraries and (optionally) filters libraries by stars count."
  @spec create_or_update_category(integer | nil) :: [%Category{}]
  def create_or_update_category(params), do: create_category(params)

  def find_categories_with_libs(stars_count \\ nil)

  def find_categories_with_libs(nil),
    do: from(c in Category, join: l in Lib, on: l.category_id == c.id, preload: [libs: l]) |> Repo.all()

  def find_categories_with_libs(stars_count) do
    from(c in Category, join: l in Lib, on: l.category_id == c.id and l.stars_count >= ^stars_count, preload: [libs: l])
    |> Repo.all()
  end

  defp update_category(category, params), do: category |> ListValidator.changeset(params) |> Repo.update()

  defp create_category(params), do: %Category{} |> ListValidator.changeset(params) |> Repo.insert()
end
