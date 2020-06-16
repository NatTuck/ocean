defmodule Steno.Container.Server do
  use GenServer

  import Steno.Text, only: [corrupt_invalid_utf8: 1]

  alias Steno.Itty
  alias Steno.Queue
  alias Steno.Job

  alias Steno.Container.Image

  def start_link(key) do
    GenServer.start_link(__MODULE__, key)
  end

  def start(key) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [key]},
      restart: :temporary,
    }
    DynamicSupervisor.start_child(Steno.Container.Sup, spec)
  end

  def wait(pid) do
    ref = Process.monitor(pid)
    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    end
  end

  def get_uuid(pid) do
    GenServer.call(pid, :get_uuid)
  end

  @impl true
  def init(key) do
    job = Queue.get(key)
    dsc = job.driver["script"]

    priv = to_string(:code.priv_dir(:steno))
    script = Path.join(priv, "scripts/#{dsc}.pl")
    driver = Path.join(priv, "scripts/#{dsc}-driver.pl")

    {:ok, base, hash} = Image.prepare(job, driver)
    env = Job.env(job)
    |> Map.put("DIR", base)
    |> Map.put("TAG", hash)

    #IO.inspect {:env, env}

    {:ok, uuid} = Itty.start(script, env)

    {:ok, %{exit: status, output: data}} = Itty.open(uuid)

    state = %{
      key: key,
      uuid: uuid,
      data: data,
    }

    if status do
      Process.send_after(self(), {:exit, status}, 10)
    end

    {:ok, state}
  end

  @impl true
  def handle_call(:get_uuid, _from, state) do
    {:reply, {:ok, state.uuid}, state}
  end

  @impl true
  def handle_info({:output, item}, state) do
    IO.inspect({:autograde, :output, item})
    state = Map.update!(state, :data, &([item | &1]))
    {:noreply, state}
  end

  def handle_info({:exit, status}, state) do
    {:ok, result} = Itty.close(state.uuid)

    log = state.data
    |> Enum.sort_by(fn {serial, _, _} -> serial end)
    |> Enum.map(fn {serial, stream, text} ->
      %{
        serial: serial,
        stream: stream,
        text: corrupt_invalid_utf8(text),
      }
    end)

    Queue.done(state.key, inspect(status), log)

    {:stop, :normal, state}
  end
end
