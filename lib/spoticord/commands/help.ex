defmodule Spoticord.Commands.Help do
  use Spoticord.Command

  @moduledoc """
  The help command. Shows a menu of commands.
  """

  def description, do: "Show this menu!"

  @doc false
  def execute(message, _args) do
    Nostrum.Api.create_message(
      message.channel_id,
      embed: generate_help_embed!()
    )

    :ok
  end

  alias Spoticord.Utils
  alias Nostrum.Struct.Embed

  def generate_help_embed!() do
    embed =
      Utils.create_empty_embed!()
      |> Embed.put_title("Help!")
      |> Embed.put_description("Help for all of the commands!")
      |> Embed.put_thumbnail(Spoticord.get_own_avatar)

    Enum.reduce(Spoticord.Command.commands!, embed, &add_command/2)
  end

  def add_command({name, module}, embed), do:
    Embed.put_field(embed, "#{Spoticord.command_prefix!()}#{name}", module.description, true)
end
