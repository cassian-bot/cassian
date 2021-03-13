defmodule Cassian.Commands.List do
  use Cassian.Behaviours.Command

  alias Cassian.{Managers.MessageManager, Commands.List}
  import Cassian.Utils.Embed

  @moduledoc """
  General module for handling list sub-commands. List by itself doesn't do much.
  """

  def example do
    "list [backward|forward|next|previous|repeat|shuffle|unshuffle]"
  end

  def short_desc do
    "General commands for playlists."
  end

  def long_desc do
    "General commands for playlists."
  end

  def execute(message, args) do
    case Enum.at(args, 0) do
      "backward" ->
        List.Backward.execute(message, args)

      "forward" ->
        List.Forward.execute(message, args)

      "next" ->
        List.Next.execute(message, args)

      "previous" ->
        List.Previous.execute(message, args)

      "repeat" ->
        List.Repeat.execute(message, args)

      "shuffle" ->
        List.Shuffle.execute(message, args)

      "unshuffle" ->
        List.Unshuffle.execute(message, args)

      _ ->
        notify_unknown(message)
    end
  end

  defp notify_unknown(message) do
    generate_error_embed(
      "Unknown command.",
      "The specified sub-command wasn't found. Try `#{}help list for more info,"
      )
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end
end
