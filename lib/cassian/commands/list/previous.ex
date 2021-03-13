defmodule Cassian.Commands.List.Previous do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  def ship?, do: true
  def caller, do: "list:previous"
  def desc, do: "Play the previous song in the playlist!"

  def execute(message, _args) do
    PlayManager.switch_song_with_notification(message, false)
  end
end
