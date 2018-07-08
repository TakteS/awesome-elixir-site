defmodule AwesomeElixir.Service.UpdateList do
  @moduledoc "GenServer that parses awesome elixir's readme.md file and updates categories and libraries in DB."

  use GenServer
  alias AwesomeElixir.List
  alias AwesomeElixir.Operation.ParseLibrariesList
  require Logger

  ## Client

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @doc "Show GenServer's state."
  def lookup(), do: GenServer.call(__MODULE__, :lookup)

  @doc "Parse awesome list and set result as state."
  def parse(url \\ nil) do
    url = if url, do: url, else: Application.get_env(:awesome_elixir, :github)[:readme_url]
    GenServer.cast(__MODULE__, {:parse, url})
  end


  ## Server

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_call(:lookup, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:parse, url}, state) do
    new_state =
      case ParseLibrariesList.run(url) do
        {:ok, libs} ->
          {:noreply, libs, libs}

        error ->
          error |> inspect() |> Logger.error()
          {:noreply, state, state}
      end

    schedule_work()
    new_state
  end

  @impl true
  def handle_info(:update, []) do
    schedule_work()
    {:noreply, []}
  end

  def handle_info(:update, [h | t]) do
    category_params = %{"name" => h.category, "description" => h.description}

    case List.create_or_update_category(category_params) do
      {:ok, category} -> update_libs(h.libs, category.id)
      error -> error |> inspect() |> Logger.error()
    end

    schedule_work()
    {:noreply, t}
  end

  defp update_libs(libs, category_id) do
    for lib <- libs do
      params = Map.put(lib, :category_id, category_id)

      case List.create_or_update_lib(params) do
        {:ok, _lib} -> :ok
        error -> error |> inspect() |> Logger.error()
      end
    end
  end

  defp schedule_work(), do: Process.send_after(self(), :update, 1000)
end
