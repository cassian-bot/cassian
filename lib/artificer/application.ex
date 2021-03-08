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

    children =
      if Application.get_env(:artificer, :web_enabled) do
        children ++ [
          Plug.Cowboy.child_spec(
            scheme: (if (Mix.env == :prod), do: :https, else: :http),
            plug: ArtificerWeb.Endpoint,
            options: [port: Application.get_env(:artificer, :port)]
          )
        ]
      else
        children
      end

    children
    |> Enum.each(fn child -> DynamicSupervisor.start_child(Artificer.Supervisor, child) end)
  end
end
