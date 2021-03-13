defmodule Cassian.Commands.Playback.Repeat do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.{PlayManager, MessageManager}

  import Cassian.Utils.Embed

  @doc """
  Set the type of repeat for a song.
  """

  def execute(message, args) do
    type = Enum.at(args, 0)

    if type in ["one", "none", "all"] do
      PlayManager.change_repeat_with_notification(message, String.to_atom(type), true)
    else
      bad_error(message)
    end
  end

  def bad_error(message) do
    generate_error_embed(
      "Not correct type!",
      "The specified repeat type was not correct. You need to put `one`, `none` or `all`."
    )
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end
end
