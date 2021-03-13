defmodule Cassian.Commands.Help do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.MessageManager

  @moduledoc """
  The help command. Shows a menu of commands.
  """

  def example do
    "help <part>"
  end

  def short_desc do
    "This command!"
  end

  def long_desc do
    nil
  end

  @doc false
  def execute(message, _args) do
    generate_help_embed!()
    |> MessageManager.send_embed(message.channel_id)

    :ok
  end

  import Cassian.Utils.Embed
  alias Nostrum.Struct.Embed

  def generate_help_embed!() do
    embed =
      create_empty_embed!()
      |> Embed.put_title("Help!")
      |> Embed.put_description("Help for all of the commands!")
      |> Embed.put_thumbnail(Cassian.get_own_avatar())

    Enum.reduce(Cassian.commands!(), embed, &add_command/2)
  end

  def add_command({_caller, module}, embed),
    do:
      Embed.put_field(
        embed,
        "`#{Cassian.command_prefix!()}#{module.example}`",
        "#{module.short_desc}",
        false
      )
end
