defmodule Cassian.Commands.List do
  use Cassian.Behaviours.Command

  @moduledoc """
  General module for handling list sub-commands. List by itself doesn't do much.
  """

  alias Cassian.Commands.List

  alias Nostrum.Struct.Message

  @callback execute(message :: %Message{}, list(String.t())) :: any()

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
    end
  end
end
