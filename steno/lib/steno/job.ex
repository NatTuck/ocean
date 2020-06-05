defmodule Steno.Job do
  # Key:
  #  - Is unique, new replaces old.
  #  - For Inkfish: "#{7 digit sub_id}"

  # Pri:
  #  - Jobs will be sorted in ascending order by pri.
  #  - Could be useful to make this attempt #.

  # Status is one of:
  #   :ready, :running, :done

  defstruct key: nil, pri: 10, idx: nil, data: %{}, status: :ready
end
