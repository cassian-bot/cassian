defmodule Spoticord.Commands.Join do
  use Spoticord.Behaviours.Command

  alias Spoticord.Utils

  def caller, do: "join"
  def desc, do: "Join the current voice channel!"

  def execute(message, _args) do
    case Utils.get_sender_voice_id(message) do
      {:ok, {guild_id, voice_id}} ->
        if Utils.can_connect?(guild_id, voice_id) do
          Utils.join_or_switch_voice(guild_id, voice_id)
        else
          Nostrum.Api.create_message!(message.channel_id, embed: no_perms_embed())
        end

      {:error, :noop} ->
        Nostrum.Api.create_message!(message.channel_id, embed: no_channel_embed())
    end
  end

  alias Nostrum.Struct.Embed

  def no_channel_embed() do
    Utils.create_empty_embed!()
    |> Utils.put_color_on_embed("#ff0033")
    |> Embed.put_title("Hold it right there!")
    |> Embed.put_description("You're not in a voice channel! You won't bamboozle _me_ this time!")
  end

  def no_perms_embed() do
    Utils.create_empty_embed!()
    |> Utils.put_color_on_embed("#ff0033")
    |> Embed.put_title("I kind of can't... y'know?")
    |> Embed.put_description("I don't have the permissions to join the voice channel. **I** don't have?! ***The audacity!***")
  end
end
