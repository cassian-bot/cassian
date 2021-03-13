defmodule Cassian.Commands.Playback.Shuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  Shuffle and reshuffle.
  """

  def execute(message, _args) do
    PlayManager.shuffle_and_notify(message)
  end
end
