defmodule Steno.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :key, :string
      add :user, :string
      add :desc, :string
      add :sbx_cfg, :text
      add :sub_url, :string
      add :gra_url, :string
      add :meta, :text
      add :output, :text

      timestamps()
    end

  end
end
