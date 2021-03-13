defmodule Cassian.Commands.Playlist.Backward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  def ship?, do: true
  def caller, do: "music:backward"
  def desc, do: "Play the playlst in backward order!"

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, true)
  end
end
