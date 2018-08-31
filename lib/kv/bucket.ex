defmodule KV.BucketAgent do
  use Agent

  @doc """
  Starts a new bucket
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the bucket by key
  """
  def get(bucket, key) do
    # Agent.get(bucket, fn map -> map[key] end)
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the value for the given key
  """
  def put(bucket, key, value) do
    # Agent.update(bucket, fn map -> Map.put(map, key, value) end)
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end

defmodule KV.BucketTask do
  def start_link do
    Task.start_link fn -> loop(%{}) end
  end

  def loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, Map.get(map, key)
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
    
  end
end