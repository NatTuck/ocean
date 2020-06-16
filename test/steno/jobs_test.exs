defmodule Steno.JobsTest do
  use Steno.DataCase

  alias Steno.Jobs

  describe "jobs" do
    alias Steno.Jobs.Job

    @valid_attrs %{desc: "some desc", gra_url: "some gra_url", key: "some key", meta: "some meta", output: "some output", sbx_cfg: "some sbx_cfg", sub_url: "some sub_url", user: "some user"}
    @update_attrs %{desc: "some updated desc", gra_url: "some updated gra_url", key: "some updated key", meta: "some updated meta", output: "some updated output", sbx_cfg: "some updated sbx_cfg", sub_url: "some updated sub_url", user: "some updated user"}
    @invalid_attrs %{desc: nil, gra_url: nil, key: nil, meta: nil, output: nil, sbx_cfg: nil, sub_url: nil, user: nil}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Jobs.create_job(@valid_attrs)
      assert job.desc == "some desc"
      assert job.gra_url == "some gra_url"
      assert job.key == "some key"
      assert job.meta == "some meta"
      assert job.output == "some output"
      assert job.sbx_cfg == "some sbx_cfg"
      assert job.sub_url == "some sub_url"
      assert job.user == "some user"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, %Job{} = job} = Jobs.update_job(job, @update_attrs)
      assert job.desc == "some updated desc"
      assert job.gra_url == "some updated gra_url"
      assert job.key == "some updated key"
      assert job.meta == "some updated meta"
      assert job.output == "some updated output"
      assert job.sbx_cfg == "some updated sbx_cfg"
      assert job.sub_url == "some updated sub_url"
      assert job.user == "some updated user"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end
end
