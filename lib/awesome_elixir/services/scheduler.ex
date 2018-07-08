defmodule AwesomeElixir.Service.Scheduler do
  @moduledoc "GenServer that schedules UpdateList job each N milliseconds."

  use GenServer
  alias AwesomeElixir.Service.UpdateList

  ## Client

  def start_link(delay), do: GenServer.start_link(__MODULE__, delay, name: __MODULE__)


  ## Server

  @impl true
  def init(delay) do
    schedule_work(delay)
    {:ok, delay}
  end

  @impl true
  def handle_info(:work, delay) do
    UpdateList.parse()
    schedule_work(delay)

    {:noreply, delay}
  end

  defp schedule_work(delay), do: Process.send_after(self(), :work, delay)
end
