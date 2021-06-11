defmodule Cassian.Services.SoundCloudService do
  @moduledoc """
  Service module which does most of the calls for the SoundCloud API.
  """

  @client_id Application.get_env(:cassian, :sound_cloud_id)

  @doc """
  Get the SoundCloud raw stream from a SoundCloud url.
  """
  @spec stream_from_url(url :: String.t()) :: {:ok, String.t()} | {:error, any()}
  def stream_from_url(url) do
    case acquire_track_id(url) do
      {:ok, track_id} ->
        get_track_information(track_id)

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

    case HTTPoison.get("https://soundcloud.com/oembed", headers, params: params, follow_redirect: true) do
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

  def get_track_information(track_id) do
    url = "https://api-v2.soundcloud.com/tracks/#{track_id}"

    params = %{
      client_id: @client_id
    }

    # Some information is here
    HTTPoison.get(url, %{}, params: params)
  end
end
