defmodule AwesomeElixirWeb.PageViewTest do
  use AwesomeElixirWeb.ConnCase, async: true
  alias AwesomeElixirWeb.PageView

  test "generate_category_id/1" do
    assert PageView.generate_category_id("name") == "name"
    assert PageView.generate_category_id("category name") == "category-name"

    assert PageView.generate_category_id("category, name-with-characters_and-numbers 6") ==
             "category-name-with-characters-and-numbers-6"
  end

  test "updated_days_ago/1" do
    today = Timex.now()
    two_days_ago = Timex.shift(today, days: -2)
    eight_days_ago = Timex.shift(today, days: -8)

    assert PageView.updated_days_ago(today) == 0
    assert PageView.updated_days_ago(two_days_ago) == 2
    assert PageView.updated_days_ago(eight_days_ago) == 8
  end
end
