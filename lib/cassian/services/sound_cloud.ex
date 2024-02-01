defmodule Cassian.Services.SoundCloud do
  @moduledoc """
  Service module for SoundCloud songs.
  """

  use Cassian.Behaviours.SourceService
  
  require Logger

  def song_metadata(url) do
    with {json_body, 0} <- System.cmd("youtube-dl", [url, "--dump-json"]),
         {:ok, body = %{"extractor" => "soundcloud"}} <- Poison.decode(json_body) do
      Logger.debug(inspect(body))
      
      metadata =
        %Metadata{
          title: body["title"],
          author: body["uploader"],
          provider: "soundcloud",
          link: body["webpage_url"],
          color: "ff9033",
          thumbnail_url: body["thumbnail"],
          stream_link: url,
          stream_method: :ytdl
        }
      
      {:ok, metadata}
    else
      {output, code} when is_integer(code) ->
        Logger.critical("youtube-dl failed with code: #{inspect(code)} and output: #{inspect(output)}!")
        {:error, :no_youtube_dl}
      {:error, _} ->
        Logger.critical("SoundCloud body failed to decode.")
        {:error, :json_decode}
      {:ok, _} ->
        Logger.debug("URL is not a soundcloud one: #{inspect(url)}")
    end
  end
end
