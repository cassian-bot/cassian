defmodule Cassian.Commands.Help do
  use Cassian.Behaviours.Command

  @moduledoc """
  The help command. Shows a menu of commands.
  """

  def ship?, do: true
  def caller, do: "help"
  def desc, do: "Show this menu!"

  @doc false
  def execute(message, _args) do
    Nostrum.Api.create_message(
      message.channel_id,
      embed: generate_help_embed!()
    )

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

    Enum.reduce(Cassian.commands!, embed, &add_command/2)
  end

  def add_command({caller, module}, embed), do:
    Embed.put_field(embed, "#{Cassian.command_prefix!()}#{caller}", module.desc, false)
end
