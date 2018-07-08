defmodule AwesomeElixirWeb.PageController do
  use AwesomeElixirWeb, :controller
  alias AwesomeElixir.List

  def index(conn, params) do
    content = List.find_categories_with_libs(params["min_stars"])
    render(conn, "index.html", content: content)
  end
end
