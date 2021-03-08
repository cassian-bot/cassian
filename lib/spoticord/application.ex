defmodule Artificer.Application do
  use Application

  @doc false
  def start(_type, _args) do
    # Using a dynamic supervisor here so I can add children
    # later as well!
    result = DynamicSupervisor.start_link(name: Artificer.Supervisor, strategy: :one_for_one)
    add_children()
    result
  end

  @doc false
  def add_children() do
    alias Artificer.Consumer

    children = [
      %{
        id: Consumer,
        start: {Consumer, :start_link, []}
      },
      %{
        id: Artificer.CommandCache,
        start: {ConCache, :start_link, [[name: :command_cache, ttl_check_interval: false]]}
      }
    ]

    children
    |> Enum.each(fn child -> DynamicSupervisor.start_child(Artificer.Supervisor, child) end)
  end
end
