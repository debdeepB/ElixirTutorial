defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  We are going to solve this issue by defining a new supervisor that will
  spawn and supervise all buckets. Opposite to the previous Supervisor we 
  defined, the children are not known upfront, but they are rather started
  dynamically.
  """
  def init(:ok) do
    children = [
      {KV.Registry, name: KV.Registry},
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
