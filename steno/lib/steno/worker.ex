defmodule Steno.Worker do
  use GenServer

  alias Steno.Queue

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def schedule_poll do
    Process.send_after(self(), :poll, 1000)
  end

  @impl true
  def init(state0) do
    schedule_poll()
    {:ok, state0}
  end

  @impl true
  def handle_info(:poll, state) do
    if job = Queue.get() do
      IO.inspect({:run_job, job})
    end
    schedule_poll()
    {:noreply, state}
  end
end
