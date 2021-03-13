defmodule Cassian.Commands.Music.Playlist.Backward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Play the list backwards.
  """

  def example do
    "backward"
  end

  def short_desc do
    "Play the playlist backward."
  end

  def long_desc do
    "Play the list backward. Newly added songs will play first."
  end

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, true)
  end
end
