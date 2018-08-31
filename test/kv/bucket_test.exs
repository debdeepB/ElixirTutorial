defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket_agent} = KV.BucketAgent.start_link([])
    {:ok, bucket_task} = KV.BucketTask.start_link
    %{bucket_agent: bucket_agent, bucket_task: bucket_task}
  end

  test "stores values by key using Agent", %{bucket_agent: bucket_agent} do
    assert KV.BucketAgent.get(bucket_agent, "milk") == nil

    KV.BucketAgent.put(bucket_agent, "milk", 3)
    assert KV.BucketAgent.get(bucket_agent, "milk") == 3
  end

  test "stores values by key using Tasks", %{bucket_task: bucket_task} do
    import IEx.Helpers
    send bucket_task, {:put, :hello, :world}
    send bucket_task, {:get, :hello, self()}
    IO.inspect flush()
  end

end