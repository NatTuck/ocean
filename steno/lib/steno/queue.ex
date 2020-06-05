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

  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  def done(key) do
    GenServer.call(@name, {:done, key})
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
    idxs = state.queue
    |> Enum.with_index()
    |> Enum.into(%{})

    jobs = state.jobs
    |> Map.values()
    |> Enum.map(&(%Job{&1 | idx: Map.get(idxs, &1.key)}))
    |> Enum.sort_by(&({status_order(&1.status), &1.idx, &1.pri}))

    {:reply, jobs, state}
  end

  def handle_call({:put, job}, _from, state0) do
    job = %Job{job | status: :ready}
    jobs = Map.put(state0.jobs, job.key, job)

    state1 = %{
      jobs: jobs,
      queue: insert_key(state0.queue, job.key, jobs),
    }
    {:reply, :ok, state1}
  end

  def handle_call(:next, _from, state) do
    case state.queue do
      [] ->
        {:reply, nil, state}
      [key|rest] ->
        job = Map.get(state.jobs, key)
        |> Map.put(:status, :running)

        jobs = Map.put(state.jobs, job.key, job)

        {:reply, job, %{state | jobs: jobs, queue: rest}}
    end
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state.jobs, key), state}
  end

  def handle_call({:done, key}, _from, state0) do
    job = Map.get(state0.jobs, key)
    job = %Job{job | status: :done}
    state1 = put_in(state0, [:jobs, key], job)
    {:reply, job, state1}
  end

  def insert_key([], x, _), do: [x]
  def insert_key([y|ys], x, jobs) do
    aa = Map.get(jobs, x)
    bb = Map.get(jobs, y)

    if aa.pri < bb.pri do
      [x | [y|ys]]
    else
      [y | insert_key(ys, x, jobs)]
    end
  end

  def status_order(:running), do: 0
  def status_order(:ready), do: 1
  def status_order(:done), do: 2
end
