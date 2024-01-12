defmodule Cassian.Services.Youtube do
  @moduledoc """
  Service module for Youtube songs.
  """

  use Cassian.Behaviours.SourceService
  
  require Logger

  def song_metadata(url) do
    with {json_body, 0} <- System.cmd("youtube-dl", [url, "--dump-json"]),
         {:ok, body = %{"extractor" => "youtube"}} <- Poison.decode(json_body) do
          
      Logger.debug("Got Youtube JSON from youtube-dl: #{inspect(body)}.")
      
      metadata =
        %Metadata{
          title: body["title"],
          author: body["uploader"],
          provider: "youtube",
          link: body["webpage_url"],
          color: "ff3333",
          thumbnail_url: body["thumbnail"],
          stream_link: url,
          stream_method: :ytdl
        }
        
        Logger.debug("Giving metadata: #{inspect(metadata)}.")
      
      {:ok, metadata}
    else
      {output, code} when is_integer(code) ->
        Logger.critical("youtube-dl failed with code: #{inspect(code)} and output: #{inspect(output)}!")
        {:error, :no_youtube_dl}
      {:error, _} ->
        Logger.critical("Youtube body failed to decode.")
        {:error, :json_decode}
      {:ok, _} ->
          Logger.debug("URL is not a youtube one: #{inspect(url)}")
    end
  end
end
