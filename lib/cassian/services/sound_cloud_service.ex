defmodule Cassian.Services.SoundCloudService do
  @moduledoc """
  Service module which does most of the calls for the SoundCloud API.
  """

  alias Cassian.Structs.Metadata
  
  require Logger

  defdelegate client_id(), to: Cassian.Servers.SoundCloudToken

  @doc """
  Get the metadata for the song from the oembed... embed...
  """
  @spec oembed_song_data(url :: String.t()) :: {:ok, %Metadata{}} | {:error, any()}
  def oembed_song_data(url) do
    link = "https://soundcloud.com/oembed"

    headers = [
      "User-agent": "#{Cassian.username!()} #{Cassian.version!()}",
      Accept: "Application/json; Charset=utf-8"
    ]

    params = %{
      url: url,
      format: :json
    }

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(link, headers, params: params),
         {:ok, body} <- Poison.decode(body, %{keys: :atoms}) do
      metadata = %Metadata{
        title: body.title,
        author: body.author_name,
        provider: "soundcloud",
        link: url,
        color: "ff9033",
        thumbnail_url: body.thumbnail_url,
        stream_link: nil,
        stream_method: :url
      }

      {:ok, metadata}

    else
      {_, %HTTPoison.Response{status_code: code}} ->
        {:error, code}
        
      {_, %HTTPoison.Error{}} ->
        {:error, -1}
        
      {_, _} ->
        {:error, -2}
    end
  end

  @doc """
  Get the SoundCloud raw stream from a SoundCloud url.
  """
  @spec stream_from_url(url :: String.t()) :: {:ok, String.t()} | {:error, any()}
  def stream_from_url(url) do
    Logger.debug("Stream from url called with: #{inspect(url)}")
    with {:ok, track_id} <- acquire_track_id(url),
         {:ok, transcoding} <- get_progressive_link(track_id) do
      stream_url(transcoding)
    else    
      _ ->
        {:error, nil}
    end
  end

  @doc """
  Get the SoundCloud track id from a SoundCloud url.
  """
  @spec acquire_track_id(url :: String.t()) :: {:ok, String.t()} | {:error, any()}
  def acquire_track_id(url) do
    headers = [
      # I honestly have no clue what is the content type...
      {"Content-Type", "application/json"}
    ]

    params = %{
      url: url,
      format: "json"
    }
    
    response =
      HTTPoison.get("https://soundcloud.com/oembed", headers,
        params: params,
        follow_redirect: true
      )
      
    Logger.debug("Got SoundCloud acquire_track_id/1 response: #{inspect(response)}")

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        track_id =
          Regex.run(~r/tracks%2F(.*)&show_artwork/, body)
          |> List.last()
          
        Logger.debug("SoundCloud track_id is: #{inspect(track_id)}.")
        
        {
          :ok,
          # Woohoo Regex magic
          track_id
        }

      _ ->
        {:error, nil}
    end
  end

  @spec get_progressive_link(track_id :: String.t()) :: {:ok, String.t()} | {:error, any()}
  def get_progressive_link(track_id) do
    url = "https://api-v2.soundcloud.com/tracks/#{track_id}"

    params = %{
      client_id: client_id()
    }
    
    response = HTTPoison.get(url, %{}, params: params)

    # Some information is here
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         {:ok, decoded} <- Poison.decode(body, %{keys: :atoms}),
         {:ok, url} <- acquire_link_from_body(decoded) do
        {:ok, url}
    else
      _ ->
        Logger.error("Failed to get correct response, it's: #{inspect(response)}")
        {:error, nil}
    end
  end
  
  defp acquire_link_from_body(body) do
    transcoding =
      body.media.transcodings
      |> Enum.find(fn transcoding -> transcoding.format.protocol == "progressive" end)
      |> Map.get(:url)
      
    case transcoding do
      nil ->
        {:error, nil}
      value ->
        {:ok, value}
    end
  end

  @doc """
  Get the stream URL from the transcoded-progressive url.
  """
  @spec stream_url(progressive_transcoding_url :: String.t()) ::
          {:ok, String.t()} | {:error, any()}
  def stream_url(progressive_transcoding_url) do
    params = %{
      client_id: client_id()
    }
    
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(progressive_transcoding_url, %{}, params: params),
         {:ok, decoded} <- Poison.decode(body, %{keys: :atoms}),
         value <- Map.get(decoded, :url),
         false <- is_nil(value) do
      {:ok, value}
    else
      _ ->
        {:error, nil}  
    end
  end
end
