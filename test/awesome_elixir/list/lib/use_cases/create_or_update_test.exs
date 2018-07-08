defmodule AwesomeElixir.List.Lib.UseCase.CreateOrUpdateTest do
  use AwesomeElixir.DataCase
  alias AwesomeElixir.Repo
  alias AwesomeElixir.List.Lib
  alias AwesomeElixir.List.Lib.UseCase.CreateOrUpdate
  import AwesomeElixir.Factory

  describe "run/1" do
    setup do
      bypass = Bypass.open()
      category_id = insert(:category).id

      github_settings = Application.get_env(:awesome_elixir, :github)
      updated_settings = Keyword.put(github_settings, :api_url, "http://localhost:#{bypass.port}")

      Application.put_env(:awesome_elixir, :github, updated_settings)

      on_exit fn ->
        Application.put_env(:awesome_elixir, :github, github_settings)
      end

      {:ok, bypass: bypass, category_id: category_id}
    end

    test "create new lib when params are valid", %{bypass: bypass, category_id: category_id} do
      Bypass.expect(bypass, fn %{request_path: request_path} = conn ->
        resp =
          cond do
            String.ends_with?(request_path, "/commits") ->
              ~S([{"commit": {"author": {"date": "2018-07-05T20:04:34Z"}}}])

            String.starts_with?(request_path, "/repos") ->
              ~S({"id": 1234, "stargazers_count": 10})

            true ->
              "ok"
          end

        Plug.Conn.resp(conn, 200, resp)
      end)

      params = %{
        name: "lib_name",
        description: "Description",
        url: "https://github.com/test/repo",
        category_id: category_id
      }

      assert {:ok, %Lib{} = lib} = CreateOrUpdate.run(params)
      assert lib.name == params.name
      assert lib.description == params.description
      assert lib.url == params.url
      assert lib.category_id == category_id
      assert lib.stars_count == 10
      assert lib.last_commit_date == Timex.to_datetime({{2018, 7, 5}, {20, 4, 34}})
    end

    test "update existing lib when params are valid", %{bypass: bypass} do
      lib = insert(:lib)

      Agent.start_link(fn -> 0 end, name: :bypass_calls)

      Bypass.expect(bypass, fn conn ->
        resp =
          case Agent.get(:bypass_calls, & &1) do
            0 -> ~S({"id": 1234, "stargazers_count": 100})
            1 -> ~S([{"commit": {"author": {"date": "2018-08-05T20:04:34Z"}}}])
          end

        Agent.update(:bypass_calls, &(&1 + 1))
        Plug.Conn.resp(conn, 200, resp)
      end)

      params = %{name: lib.name, description: "New description", url: lib.url}

      assert {:ok, %Lib{} = updated_lib} = CreateOrUpdate.run(params)
      assert updated_lib.id == lib.id
      assert updated_lib.name == lib.name
      assert updated_lib.url == lib.url
      assert updated_lib.description == params.description
      assert updated_lib.category_id == lib.category_id
      assert updated_lib.stars_count == 100
      assert updated_lib.last_commit_date == Timex.to_datetime({{2018, 8, 5}, {20, 4, 34}})
    end

    test "with invalid params", %{bypass: bypass} do
      Agent.start_link(fn -> 0 end, name: :bypass_calls)

      Bypass.expect(bypass, fn conn ->
        resp =
          case Agent.get(:bypass_calls, & &1) do
            0 -> ~S({"id": 1234, "stargazers_count": 100})
            1 -> ~S([{"commit": {"author": {"date": "2018-08-05T20:04:34Z"}}}])
          end

        Agent.update(:bypass_calls, &(&1 + 1))
        Plug.Conn.resp(conn, 200, resp)
      end)

      assert {:error, %Ecto.Changeset{valid?: false}} =
               CreateOrUpdate.run(%{name: "", url: "https://github.com/test/repo"})

      assert [] = Repo.all(Lib)
    end

    test "when repo is not exists", %{bypass: bypass, category_id: category_id} do
      Bypass.expect(bypass, &Plug.Conn.resp(&1, 200, ~S({})))

      params = %{
        name: "lib_name",
        description: "Description",
        url: "https://github.com/test/repo",
        category_id: category_id
      }

      assert {:error, :repo_not_exists} = CreateOrUpdate.run(params)
      assert [] = Repo.all(Lib)
    end
  end
end
