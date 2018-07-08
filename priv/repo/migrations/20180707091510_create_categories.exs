defmodule AwesomeElixir.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change() do
    create table(:categories) do
      add :name, :string, null: false, default: ""
      add :description, :string, null: false, default: ""

      timestamps()
    end

    create unique_index(:categories, [:name])
  end
end
