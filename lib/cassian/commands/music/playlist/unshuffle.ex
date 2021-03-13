defmodule Cassian.Commands.Music.Playlist.Unshuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Unshuffle.
  """

  def example do
    "unshuffle"
  end

  def short_desc do
    "Unshuffle the playlist."
  end

  def long_desc do
    "You can unshuffle the playlist this way."
  end

  def execute(message, _args) do
    PlayManager.unshuffle_and_notify(message)
  end
end
