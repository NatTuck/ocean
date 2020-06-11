defmodule Steno.Container do
  alias Steno.Container.Server

  @doc """
  Start the autograding process given a grade_id.

  Returns {:ok, pid, uuid} for the associated Itty.
  """
  def start(key) do
    {:ok, pid} = Server.start(key)
    {:ok, uuid} = Server.get_uuid(pid)
    {:ok, pid, uuid}
  end

  def wait(pid) do
    Server.wait(pid)
  end
end
