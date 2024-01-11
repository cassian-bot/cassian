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
    Logger.debug("Got timeout!")
    state = acquire_new_client_id()
    {:noreply, state, @timeout}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [nil], name: __MODULE__)
  end

  @impl true
  def init(_),
    do: {:ok, acquire_new_client_id(), @timeout}

  defp acquire_new_client_id() do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get("https://soundcloud.com/discover"),
         {:ok, value} <- generate_new_client_id(body) do
          Logger.debug("Acquired new soundcloud token.")
          value
    else
      _ ->
        Logger.warning ("Failed to retrieve token!")
        nil 
    end
  end
  
  defp generate_new_client_id(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find("script[src][crossorigin]")
    |> Stream.map(&filter_scripts/1)
    |> Stream.reject(&is_nil/1)
    |> Enum.reverse() # Generally client_id is near the end script from experience
    |> Enum.find_value(fn script ->
      with {:ok, response = %HTTPoison.Response{status_code: 200}} <- HTTPoison.get(script),
            regex_code <- Regex.run(~r/client_id:\"(.*)\",env:/, response.body),
            false <- is_nil(regex_code) do
        {:ok, List.last(regex_code)}
      else
        _ ->
          nil
      end
    end)
  end
  
  defp filter_scripts({"script", [_, {"src", script}], _}) do
    script
  end
  
  defp filter_scripts(_) do
    nil
  end
end
