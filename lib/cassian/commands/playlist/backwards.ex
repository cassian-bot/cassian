defmodule Cassian.Commands.Playlist.Backwards do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  def ship?, do: true
  def caller, do: "music:reverse"
  def desc, do: "Play the playlst in reverse order!"

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, true)
  end
end
