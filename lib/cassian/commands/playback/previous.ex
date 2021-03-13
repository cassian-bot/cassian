defmodule Cassian.Commands.Playback.Previous do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  Play the previous song.
  """

  def execute(message, _args) do
    PlayManager.switch_song_with_notification(message, false)
  end
end
