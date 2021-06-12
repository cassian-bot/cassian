defmodule Cassian.Application do
  use Application

  @doc false
  def start(_type, _args) do
    # Using a dynamic supervisor here so I can add children
    # later as well!
    result = DynamicSupervisor.start_link(name: Cassian.Supervisor, strategy: :one_for_one)
    add_children()
    result
  end

  @doc false
  def add_children() do
    alias Cassian.Consumer

    children =
      [
        %{
          id: Consumer,
          start: {Consumer, :start_link, []}
        },
        Cassian.Servers.SoundCloudToken
      ] ++ web_child!()

    children
    |> Enum.each(fn child -> DynamicSupervisor.start_child(Cassian.Supervisor, child) end)
  end

  @doc false
  defp web_child! do
    if Application.get_env(:cassian, :web_enabled) == "true" do
      [
        Plug.Cowboy.child_spec(
          scheme: :http,
          plug: CassianWeb.Endpoint,
          options: [port: Application.get_env(:cassian, :port) |> String.to_integer()]
        )
      ]
    else
      []
    end
  end
end
