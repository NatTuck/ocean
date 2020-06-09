defmodule Steno.Job do
  # Key:
  #  - Is unique, new replaces old.
  #  - For Inkfish: "#{7 digit sub_id}"

  # Pri:
  #  - Jobs will be sorted in ascending order by pri.
  #  - Could be useful to make this attempt #.

  # Status is one of:
  #   :ready, :running, :done
  #
  # Data contains:
  #   - sandbox: {...}   # Sandbox config
  #   - driver: ""       # URL of driver script
  #   - env: { }         # Environment vars for driver

  defstruct key: nil, pri: 10, idx: nil, container: %{}, driver: %{}, status: :ready

  def keys() do
    struct(__MODULE__, %{})
    |> Map.drop([:__struct__])
    |> Map.keys
  end
end
