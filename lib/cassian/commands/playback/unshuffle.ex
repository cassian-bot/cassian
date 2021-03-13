defmodule Cassian.Commands.Music.Playlist.Unshuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  Unshuffle music for the playlist.
  """

  def execute(message, _args) do
    PlayManager.unshuffle_and_notify(message)
  end
end
