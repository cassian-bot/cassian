defmodule Cassian.Commands.Playback.Backward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlaylistManager

  @doc """
  Play the playlist backwards.
  """

  def execute(message, _args) do
    PlaylistManager.change_direction_with_notification(message, true)
  end
end
