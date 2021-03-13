defmodule Cassian.Commands.List.Next do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  def ship?, do: true
  def caller, do: "list:next"
  def desc, do: "Play the next song in the playlist!"
  def example, do: "list:next"

  def execute(message, _args) do
    PlayManager.switch_song_with_notification(message, true)
  end
end
