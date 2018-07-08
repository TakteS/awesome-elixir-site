defmodule AwesomeElixir.Service.UpdateListTest do
  use AwesomeElixir.DataCase
  alias AwesomeElixir.Repo
  alias AwesomeElixir.List.Category
  alias AwesomeElixir.List.Lib
  alias AwesomeElixir.Service.UpdateList

  setup do
    start_supervised(UpdateList)
    bypass = Bypass.open()

    github_settings = Application.get_env(:awesome_elixir, :github)
    updated_settings = Keyword.put(github_settings, :api_url, "http://localhost:#{bypass.port}")

    Application.put_env(:awesome_elixir, :github, updated_settings)

    on_exit fn ->
      Application.put_env(:awesome_elixir, :github, github_settings)
    end

    {:ok, bypass: bypass}
  end

  describe "parse/1" do
    test "parse list and schedule categories and libs updation", %{bypass: bypass} do
      Bypass.expect(bypass, fn %{request_path: request_path} = conn ->
        resp =
          cond do
            request_path == "/readme.md" ->
              File.read!("test/fixtures/readme.md")

            String.ends_with?(request_path, "/commits") ->
              ~S([{"commit": {"author": {"date": "2018-07-05T20:04:34Z"}}}])

            String.starts_with?(request_path, "/repos") ->
              ~S({"id": 1234, "stargazers_count": 10})

            true ->
              "ok"
          end

        Plug.Conn.resp(conn, 200, resp)
      end)

      # There is nothing in process state
      assert [] = UpdateList.lookup()
      assert :ok = UpdateList.parse("http://localhost:#{bypass.port}/readme.md")

      # Waiting untill readme.md parsed
      :timer.sleep(50)
      # Check that state was updated with parsed categories
      assert [_cat1, _cat2] = UpdateList.lookup()

      :timer.sleep(900)
      # First category was updated
      assert [_cat1] = UpdateList.lookup()

      :timer.sleep(1000)
      # Second category was updated
      assert [] = UpdateList.lookup()

      cat1 = Repo.get_by(Category, name: "Actors")
      assert cat1
      assert Repo.get_by(Lib, name: "dflow", category_id: cat1.id)
      assert Repo.get_by(Lib, name: "exactor", category_id: cat1.id)

      cat2 = Repo.get_by(Category, name: "Algorithms and Data structures")
      assert cat2
      assert Repo.get_by(Lib, name: "array", category_id: cat2.id)
      assert Repo.get_by(Lib, name: "aruspex", category_id: cat2.id)
    after
      stop_supervised(UpdateList)
    end
  end
end
