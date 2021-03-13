defmodule Cassian.Commands.Music.Playlist.Next do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Play the next song in the list.
  """

  def example do
    "next"
  end

  def short_desc do
    "Play the next song in the list."
  end

  def long_desc do
    short_desc()
  end

  def execute(message, _args) do
    PlayManager.switch_song_with_notification(message, true)
  end
end
