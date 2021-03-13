defmodule Cassian.Commands.Music.Playlist.Previous do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Play the previous song.
  """

  def example do
    "previous"
  end

  def short_desc do
    "Play the previous song in the playlist."
  end

  def long_desc do
    short_desc()
  end

  def execute(message, _args) do
    PlayManager.switch_song_with_notification(message, false)
  end
end
