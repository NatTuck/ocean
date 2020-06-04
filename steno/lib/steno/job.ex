defmodule Steno.Job do
  # Status is one of:
  #   :ready, :running, :done

  defstruct uid: nil, key: nil, pri: 1, dat: %{}, status: :ready
end
