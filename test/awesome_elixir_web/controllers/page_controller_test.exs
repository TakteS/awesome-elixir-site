defmodule AwesomeElixirWeb.PageControllerTest do
  use AwesomeElixirWeb.ConnCase
  import AwesomeElixir.Factory

  setup do
    conn = build_conn()

    [cat1, cat2] = insert_pair(:category)
    insert(:lib, category: cat1, stars_count: 100)
    insert(:lib, category: cat2, stars_count: 50)

    {:ok, conn: conn, cat1: cat1, cat2: cat2}
  end

  describe "GET /" do
    test "renders :index template", ctx do
      conn = get(ctx.conn, page_path(ctx.conn, :index))
      assert html_response(conn, 200) =~ ctx.cat1.name
      assert html_response(conn, 200) =~ ctx.cat2.name
      assert conn.private.phoenix_template == "index.html"
    end

    test "empty categories don't renders", ctx do
      conn = get(ctx.conn, page_path(ctx.conn, :index), %{min_stars: 100})
      assert html_response(conn, 200) =~ ctx.cat1.name
      refute html_response(conn, 200) =~ ctx.cat2.name
      assert conn.private.phoenix_template == "index.html"
    end
  end
end
