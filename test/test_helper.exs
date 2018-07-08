Supervisor.stop(AwesomeElixir.Supervisor)
AwesomeElixir.Repo.start_link()
AwesomeElixirWeb.Endpoint.start_link()
{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Application.ensure_all_started(:bypass)

Ecto.Adapters.SQL.Sandbox.mode(AwesomeElixir.Repo, :manual)
