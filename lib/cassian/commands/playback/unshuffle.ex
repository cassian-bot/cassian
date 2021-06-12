defmodule Cassian.Commands.Music.Playlist.Unshuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlaylistManager

  @doc """
  Unshuffle music for the playlist.
  """

  def execute(message, _args) do
    PlaylistManager.unshuffle_and_notify(message)
  end
end
