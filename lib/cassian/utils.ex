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
  Get the song metadata if it's from a valid provider
  """
  @spec song_metadata(link :: String.t()) :: {:ok, metadata :: Hash} | {:error, :no_metadata}
  def song_metadata(link) do
    [YoutubeService, SoundCloudService]
    |> Enum.find_value({:error, :no_metadata}, &check_for_data(&1, link))
  end
  
  defp check_for_data(module, link) do
    case module.oembed_song_data(link) do
      {:ok, data} ->
        {:ok, data}

      _ ->
        nil
    end
  end
end
