defmodule AwesomeElixir.List.Category do
  @moduledoc false

  use Ecto.Schema
  alias AwesomeElixir.List.Lib

  schema "categories" do
    has_many :libs, Lib, on_delete: :delete_all

    field :name, :string
    field :description, :string

    timestamps()
  end
end
