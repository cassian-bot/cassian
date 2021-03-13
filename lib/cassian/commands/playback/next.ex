defmodule Cassian.Commands.Playback.Next do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  Play the next song in the playlist.
  """

  def execute(message, _args) do
    PlayManager.switch_song_with_notification(message, true)
  end
end
