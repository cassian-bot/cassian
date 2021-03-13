defmodule Cassian.Commands.Bot.Help do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.MessageManager

  @moduledoc """
  The help command. Shows a menu of commands.
  """

  @doc false
  def execute(message, _args) do
    generate_help_embed!()
    |> MessageManager.send_embed(message.channel_id)

    :ok
  end

  import Cassian.Utils.Embed
  alias Nostrum.Struct.Embed

  def generate_help_embed!() do
    create_empty_embed!()
    |> Embed.put_title("Yo! Thanks for adding me to the server!")
    |> Embed.put_description(
      "I currently don't have a propper help command as I'm a WIP. Though once it has been created it will be linked here so "
      <>
      "you can see all of my commands. Although you can start playing music with `#{Cassian.command_prefix!()}play`."
    )
    |> Embed.put_thumbnail(Cassian.get_own_avatar())
  end
end
