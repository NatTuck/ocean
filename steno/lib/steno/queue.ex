defmodule Steno.Queue do
  use GenServer

  alias Steno.Job

  # There is a single global job queue process.
  #
  # The state has two components:
  #  - jobs: A map of job_id to job
  #  - queue: A list of job_id in queue order

  # Jobs stick around in the jobs map while they run and
  # for a while afterwards.

  @name {:global, __MODULE__}

  @doc """
  Start the job queue process.

  This should be run on each node, resulting in one instance
  of the queue process running somewhere.
  """
  def start do
    Singleton.start_child(__MODULE__, [], __MODULE__)
  end

  @doc """

  """
  def list do
    GenServer.call(@name, :list)
  end

  def put(job) do
    GenServer.call(@name, {:put, job})
  end

  def next() do
    GenServer.call(@name, :next)
  end

  def get(job_id) do
    GenServer.call(@name, {:get, job_id})
  end

  @impl true
  def init(_) do
    state = %{
      jobs: %{},
      queue: [],
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state.jobs, state}
  end

  def handle_call({:put, job}, _from, state0) do
    job = %Job{job | status: :ready}

    state1 = %{
      jobs: Map.put(state0.jobs, job.key, job),
      queue: state0.queue ++ [job.key],
    }
    {:reply, :ok, state1}
  end

  def handle_call(:next, _from, state) do
    case state.queue do
      [] ->
        {:reply, nil, state}
      [key|rest] ->
        {:reply, Map.get(state.jobs, key), Map.put(state, :queue, rest)}
    end
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state.jobs, key), state}
  end
end
