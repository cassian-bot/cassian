defmodule Cassian.Commands.Playback.Shuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlaylistManager

  @doc """
  Shuffle and reshuffle.
  """

  def execute(message, _args) do
    PlaylistManager.shuffle_and_notify(message)
  end
end
