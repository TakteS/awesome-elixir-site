defmodule AwesomeElixir.Service.SchedulerTest do
  use AwesomeElixir.DataCase
  alias AwesomeElixir.Service.{Scheduler, UpdateList}

  setup do
    start_supervised(UpdateList)
    start_supervised({Scheduler, 2000})

    bypass = Bypass.open()

    github_settings = Application.get_env(:awesome_elixir, :github)

    updated_settings =
      github_settings
      |> Keyword.put(:api_url, "http://localhost:#{bypass.port}")
      |> Keyword.put(:readme_url, "http://localhost:#{bypass.port}/readme.md")

    Application.put_env(:awesome_elixir, :github, updated_settings)

    on_exit fn ->
      Application.put_env(:awesome_elixir, :github, github_settings)
    end

    {:ok, bypass: bypass}
  end

  test "schedule list updating every N milliseconds", %{bypass: bypass} do
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

    # Check that UpdateList's state is empty
    assert [] = UpdateList.lookup()

    # Wait 2 seconds and check that UpdateList.parse/1 was called
    :timer.sleep(2000)
    refute UpdateList.lookup() == []
  after
    stop_supervised(UpdateList)
    stop_supervised(Scheduler)
  end
end
