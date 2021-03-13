defmodule Cassian.Commands.Playback.Stop do
  use Cassian.Behaviours.Command
  alias Cassian.Managers.PlayManager

  @doc """
  Stop the music for the bot.
  """

  def execute(message, _args) do
    PlayManager.stop_and_notify(message)
  end
end
