defmodule AwesomeElixir.List.Lib do
  @moduledoc false

  use Ecto.Schema
  alias AwesomeElixir.List.Category

  schema "libs" do
    belongs_to :category, Category

    field :name, :string
    field :description, :string
    field :url, :string
    field :stars_count, :integer
    field :last_commit_date, :utc_datetime

    timestamps()
  end
end
