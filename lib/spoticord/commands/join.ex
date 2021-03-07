defmodule Spoticord.Commands.Join do
  use Spoticord.Behaviours.Command

  alias Spoticord.Utils

  def caller, do: "join"
  def desc, do: "Join the current voice channel!"

  def execute(message, _args) do
    case Utils.get_sender_voice_id(message) do
      {:ok, {guild_id, voice_id}} ->
        # So you're in a voice channel I see...
        # Utils.allowed_voice?(guild_id, voice_id)
        # |> IO.inspect(labal: "Perms")

        Utils.join_or_switch_voice(guild_id, voice_id)
        |> IO.inspect(label: "Voice response")
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
end
