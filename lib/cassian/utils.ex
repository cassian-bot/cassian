defmodule Cassian.Utils do
  @moduledoc """
  Module for general utils...
  """

  alias Cassian.Services.{YoutubeService, SoundCloudService}

  @doc """
  Get the user avatar url.
  """
  @spec user_avatar(user :: Nostrum.Struct.User) :: String.t()
  def user_avatar(user) do
    "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}"
  end

  @doc """
  Check whether a link is a YouTube one.
  """
  @spec song_metadata(link :: String.t()) :: {true, metadata :: Hash} | {false, :noop}
  def song_metadata(link) do

    case YoutubeService.oembed_song_data(link) do
      {:ok, metadata} ->
        {true, metadata}

      _ ->
        case SoundCloudService.oembed_song_data(link) do
          {:ok, metadata} ->
            {true, metadata}

          _ ->
            {false, :noop}
        end
    end
  end
end
