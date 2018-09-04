defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    {:ok, bucket_task} = KV.BucketTask.start_link()
    %{bucket: bucket, bucket_task: bucket_task}
  end

  test "stores values by key using Agent", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3

    assert KV.Bucket.delete(bucket, "milk") == 3
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "stores values by key using Tasks", %{bucket_task: bucket_task} do
    import IEx.Helpers
    send(bucket_task, {:put, :hello, :world})
    send(bucket_task, {:get, :hello, self()})
    IO.inspect(flush())
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
