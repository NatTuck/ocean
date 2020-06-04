defmodule StenoWeb.FallbackView do
  use StenoWeb, :view

  @doc """
  Traverses and translates changeset errors.
  """
  def translate_errors(changeset) do
    changeset
  end

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end
end
