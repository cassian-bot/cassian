defmodule Cassian.Commands.List.Shuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Shuffle and reshuffle.
  """

  def example do
    "list shuffle"
  end

  def short_desc do
    "Shuffle the playlist."
  end

  def long_desc do
    "You can shuffle and reshuffle the playlist. It will always refer to the current song playing after reshuffling!"
  end

  def execute(message, _args) do
    PlayManager.shuffle_and_notify(message)
  end
end
