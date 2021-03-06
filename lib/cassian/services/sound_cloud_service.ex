defmodule Cassian.Services.SoundCloudService do
  @moduledoc """
  Service module which does most of the calls for the SoundCloud API.
  """

  alias Cassian.Structs.Metadata

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

    case HTTPoison.get(link, headers, params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body =
          body
          |> Poison.decode!(keys: :atoms)

        body = %Metadata{
          title: body.title,
          author: body.author_name,
          provider: "soundcloud",
          link: url,
          color: "ff9033",
          thumbnail_url: body.thumbnail_url,
          stream_link: nil,
          stream_method: :url
        }

        {:ok, body}

      {_, %HTTPoison.Response{status_code: code}} ->
        {:error, code}
    end
  end

  @doc """
  Get the SoundCloud raw stream from a SoundCloud url.
  """
  @spec stream_from_url(url :: String.t()) :: {:ok, String.t()} | {:error, any()}
  def stream_from_url(url) do
    case acquire_track_id(url) do
      {:ok, track_id} ->
        case get_progressive_link(track_id) do
          {:ok, progressive_transcoding} ->
            stream_url(progressive_transcoding)

          {:error, _} ->
            nil
        end

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
      {"Content-Type", "*/*"}
    ]

    params = %{
      url: url,
      format: "json"
    }

    case HTTPoison.get("https://soundcloud.com/oembed", headers,
           params: params,
           follow_redirect: true
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {
          :ok,
          # Woohoo Regex magic
          Regex.run(~r/(?<=tracks%2F)(.*)(?=&show_artwork)/, body) |> List.first()
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

    # Some information is here
    case HTTPoison.get(url, %{}, params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # Doesn't look safe but as long as SoundCloud IS giving an OK response the JSON is okay...
        url =
          Poison.decode!(body, %{keys: :atoms}).media.transcodings
          |> Enum.filter(fn transcoding -> transcoding.format.protocol == "progressive" end)
          |> List.first()
          |> Map.get(:url)

        {:ok, url}

      _ ->
        {:error, nil}
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

    case HTTPoison.get(progressive_transcoding_url, %{}, params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Poison.decode!(keys: :atoms) |> Map.get(:url)}

      _ ->
        {:error, nil}
    end
  end
end
