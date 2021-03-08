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
    ] ++ web_child!()

    children
    |> Enum.each(fn child -> DynamicSupervisor.start_child(Artificer.Supervisor, child) end)
  end

  @doc false
  defp web_child! do
    if Application.get_env(:artificer, :web_enabled) == "true" do
      [
        Plug.Cowboy.child_spec(
          scheme: scheme!(),
          plug: ArtificerWeb.Endpoint,
          options: [port: Application.get_env(:artificer, :port) |> String.to_integer()] ++ cert_options!()
        )
      ]
    else
      []
    end
  end

  @doc false
  defp scheme! do
    if https?() do
      :https
    else
      :http
    end
  end

  @doc false
  def https? do
    Application.get_env(:artificer, :force_https) == "true" # || Mix.env == :prod
  end

  defp cert_options! do
    if https?() do
      [certfile: Application.get_env(:artificer, :cert), keyfile: Application.get_env(:artificer, :cert_key), cipher_suite: :strong]
    else
      []
    end
  end
end
