defmodule Steno.Container.Image do
  require EEx

  import Steno.Text, only: [sha256: 1]

  @base "/tmp/steno/images"

  def prepare(job, driver) do
    cfg = job.container

    text = dockerfile(
      cfg["base"],
      cfg["packages"],
      cfg["user_commands"]
    )
    hash = sha256(text)

    base = Path.join(@base, hash)
    File.mkdir_p!(base)

    path = Path.join(base, "Dockerfile")
    unless File.exists?(path) do
      File.write!("#{base}/Dockerfile", text)
    end

    drvp = Path.join(base, "driver.pl")
    unless File.exists?(drvp) do
      File.copy(driver, drvp)
    end

    {:ok, base, hash}
  end

  EEx.function_from_file(
    :def,
    :dockerfile,
    Path.join(__DIR__, "dockerfile.eex"),
    [:base, :packages, :user_commands]
  )
end
