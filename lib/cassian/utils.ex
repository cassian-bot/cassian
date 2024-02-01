defmodule Cassian.Utils do
  @moduledoc """
  Module for general utils...
  """

  alias Cassian.Structs.Metadata
  alias Cassian.Services.{Youtube, SoundCloud}

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
  @spec song_metadata(link :: String.t()) :: {:ok, metadata :: Metadata.t()} | {:error, :no_metadata}
  def song_metadata(link) do
    [Youtube, SoundCloud]
    |> Enum.find_value({:error, :no_metadata}, &check_for_data(&1, link))
  end
  
  @doc """
  Create an interaction response for events which can take a little bit longer. This will keep it like that
  for roughly 15 minutes.
  """
  @spec notify_longer_response(interaction :: Nostrum.Struct.Interaction.t(), flags :: integer()) :: no_return()
  def notify_longer_response(interaction, flags \\ 64) do
    Nostrum.Api.create_interaction_response(interaction, %{type: 5, data: %{flags: flags}})
  end
  
  defp check_for_data(module, link) do
    case module.song_metadata(link) do
      {:ok, data} ->
        {:ok, data}

      _ ->
        nil
    end
  end
end
