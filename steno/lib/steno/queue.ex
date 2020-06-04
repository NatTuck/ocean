defmodule Steno.Queue do
  use GenServer

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

  def pop() do
    GenServer.call(@name, :pop)
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

  def handle_call({:put, job}, _from, state) do
    {:reply, :ok, jobs ++ [job]}
  end

  def handle_call(:pop, _from, state) do
    case jobs do
      [] ->
        {:reply, nil, jobs}
      [job|rest] ->
        {:reply, job, rest}
    end
  end
end
