defmodule Cassian.Servers.SoundCloudToken do
  @moduledoc """
  Server which stores the SoundCloud `client_id`, automatically refreshes it every 15 minutes.
  """

  use GenServer
  require Logger

  # 15 minutes~
  @timeout 900_000

  # API

  @doc """
  Get the current SoundCloud client ID.
  """
  @spec client_id() :: Sting.t()
  def client_id do
    GenServer.call(__MODULE__, :client_id)
  end

  # Server-side

  @impl true
  def handle_call(:client_id, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:timeout, state) do
    Logger.debug("Got timeout with state #{state}")
    state = acquire_new_client_id!()
    Logger.debug("New client id is: #{state}")
    {:noreply, state, @timeout}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [nil], name: __MODULE__)
  end

  @impl true
  def init(_),
    do: {:ok, acquire_new_client_id!(), @timeout}

  defp acquire_new_client_id!() do
    scripts =
      HTTPoison.get!("https://soundcloud.com/discover")
      |> Map.get(:body)
      |> Floki.parse_document!()
      |> Floki.find("script")

    {"script", [_head | [{"src", source}]], _} = Enum.at(scripts, length(scripts) - 2)

    body = HTTPoison.get!(source).body

    Regex.run(~r/(?<=,client_id:\")(.*)(?=\",env:)/, body) |> List.first()
  end
end
