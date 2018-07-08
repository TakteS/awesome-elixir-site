defmodule AwesomeElixir.Repo.Migrations.CreateLibs do
  use Ecto.Migration

  def change() do
    create table(:libs) do
      add :name, :string, null: false, default: ""
      add :description, :string, null: false, default: ""
      add :url, :string, null: false, default: ""
      add :stars_count, :integer, null: false, default: 0
      add :last_commit_date, :utc_datetime, null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:libs, [:name])
    create unique_index(:libs, [:url])
  end
end
