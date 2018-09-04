defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, shopping_bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(shopping_bucket, "milk", 1)
    assert KV.Bucket.get(shopping_bucket, "milk") == 1

    KV.Registry.create(registry, "electronics_bucket")
    assert {:ok, electronics_bucket} = KV.Registry.lookup(registry, "electronics_bucket")

    KV.Bucket.put(electronics_bucket, "macbook", 2)
    assert KV.Bucket.get(electronics_bucket, "macbook") == 2
  end

  test "removes bucket on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    # Do a call to ensure the registry processed the DOWN message
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    # abnormal shutdown of the "shopping" bucket
    Agent.stop(bucket, :shutdown)
    # Do a call to ensure the registry processed the DOWN message
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
