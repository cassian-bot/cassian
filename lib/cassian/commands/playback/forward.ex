defmodule Cassian.Commands.Playback.Forward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlaylistManager

  @doc """
  Play the playlist forward.
  """

  def execute(message, _args) do
    PlaylistManager.change_direction_with_notification(message, false)
  end
end
