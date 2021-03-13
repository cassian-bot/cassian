defmodule Cassian.Commands.Playback.Backward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  Play the playlist backwards.
  """

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, true)
  end
end
