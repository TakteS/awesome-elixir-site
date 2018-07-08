defmodule AwesomeElixirWeb.PageView do
  use AwesomeElixirWeb, :view

  @spec generate_category_id(String.t()) :: String.t()
  def generate_category_id(category_name) do
    category_name
    |> String.replace(~r/[\p{P}\p{S}]/, " ", trim: true)
    |> String.replace(" ", "-", trim: true)
    |> String.replace("--", "-")
    |> String.downcase()
  end

  @spec updated_days_ago(DateTime.t()) :: integer
  def updated_days_ago(date) do
    today = Timex.now()
    Timex.diff(today, date, :days)
  end
end
