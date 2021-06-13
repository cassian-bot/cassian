defmodule Cassian.Services.YoutubeService do
  @moduledoc """
  Service module which corresponds to YouTube calls.
  """

  alias Cassian.Structs.Metadata

  @doc """
  Create metadata from a youtube song.
  """
  @spec oembed_song_data(url :: String.t()) :: {:ok, %Metadata{}} | {:error, Integer.t()}
  def oembed_song_data(url) do
    link = "https://www.youtube.com/oembed"

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

        # Doing some sanitization for the link so that we get a singleton song...
        url =
          "https://www.youtube.com/watch?v=#{
            Regex.run(~r/(?<=\/vi\/)(.*)(?=\/)/, body.thumbnail_url)
          }"

        body = %Metadata{
          title: body.title,
          author: body.author_name,
          provider: "youtube",
          link: url,
          color: "ff3333",
          thumbnail_url: body.thumbnail_url,
          stream_link: url,
          stream_method: :ytdl
        }

        {:ok, body}

      {_, %HTTPoison.Response{status_code: code}} ->
        {:error, code}
    end
  end

  @doc """
  Get a list of metadatas from a youtube playlist.
  """
  @spec playlist_information(link :: String.t()) ::
          {:ok, list(%Metadata{})}
          | {:error, :invalid}
          | {:error, :broken}
          | {:error, :no_playlist}
  def playlist_information(link) do
    %URI{query: query} = URI.parse(link)

    case URI.decode_query(query || "") |> Map.get("list") do
      nil ->
        {:error, :invalid}

      list ->
        url = "https://www.youtube.com/embed/videoseries"

        params = %{
          list: list
        }

        headers = [
          "User-agent": "#{Cassian.username!()} #{Cassian.version!()}"
        ]

        case HTTPoison.get(url, headers, params: params) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            response =
              Regex.scan(~r/(?<=ytcfg\.set\().*?(?=\);)/, body)
              |> Poison.decode!(keys: :atoms)
              |> Map.get(:PLAYER_VARS)
              |> Map.get(:embedded_player_response)

            case response |> Poison.decode() do
              {:ok, json} ->
                songs =
                  json
                  |> Map.get("embedPreview")
                  |> Map.get("thumbnailPreviewRenderer")
                  |> Map.get("playlist")
                  |> Map.get("playlistPanelRenderer")
                  |> Map.get("contents")
                  |> Enum.map(&playlist_element_to_meta/1)

                {:ok, songs}

              {:error, _} ->
                {:error, :no_playlist}
            end

          _ ->
            {:error, :broken}
        end
    end
  end

  # Transform to meta...
  defp playlist_element_to_meta(element) do
    element = element["playlistPanelVideoRenderer"]

    %Metadata{
      title: element["title"]["runs"] |> List.first() |> Map.get("text"),
      author: element["longBylineText"]["runs"] |> List.first() |> Map.get("text"),
      provider: "youtube",
      link: "https://www.youtube.com/watch?v=#{element["videoId"]}",
      color: "ff3333",
      thumbnail_url: element["thumbnail"]["thumbnails"] |> List.last() |> Map.get("url"),
      stream_link: "https://www.youtube.com/watch?v=#{element["videoId"]}",
      stream_method: :ytdl
    }
  end
end
