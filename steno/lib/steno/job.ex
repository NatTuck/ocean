defmodule Steno.Job do
  # Key must be unique.
  # For inkfish, it could be "#{sub_id}-#{run#}"

  # Status is one of:
  #   :ready, :running, :done

  defstruct key: nil, pri: 1, dat: %{}, status: :ready
end
