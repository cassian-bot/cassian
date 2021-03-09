defmodule Artificer.Commands.Play do
  use Artificer.Behaviours.Command

  alias Artificer.Utils

  def ship?, do: true
  def caller, do: "play"
  def desc, do: "Play music in your voice channel!"

  def execute(message, args) do
    link = Enum.fetch!(args, 0)

    unless Utils.youtube_link?(link) do
      Nostrum.Api.create_message!(message.channel_id, embed: not_valid_embed())
    else
      case Utils.get_sender_voice_id(message) do
        {:ok, {guild_id, voice_id}} ->
          if Utils.can_connect?(guild_id, voice_id) do
            handle_voice(guild_id, voice_id, message, args)
          else
            Nostrum.Api.create_message!(message.channel_id, embed: no_perms_embed())
          end
        {:error, :noop} ->
          Nostrum.Api.create_message!(message.channel_id, embed: no_channel_embed())
      end
    end
  end

  alias Nostrum.Struct.Embed

  def handle_voice(guild_id, voice_id, _message, args) do
    Utils.join_or_switch_voice(guild_id, voice_id)
    Utils.play_when_ready(Enum.fetch!(args, 0), guild_id, 50)
  end

  def not_valid_embed() do
    Utils.create_empty_embed!()
    |> Utils.put_error_color_on_embed()
    |> Embed.put_title("There is an issue my friend...")
    |> Embed.put_description("It looks like that song is not present in my library. Maybe you misswrote it?")
  end

  def no_channel_embed() do
    Utils.create_empty_embed!()
    |> Utils.put_error_color_on_embed()
    |> Embed.put_title("Hold it right there!")
    |> Embed.put_description("You're not in a voice channel! You won't bamboozle _me_ this time!")
  end

  def no_perms_embed() do
    Utils.create_empty_embed!()
    |> Utils.put_error_color_on_embed()
    |> Embed.put_title("I kind of can't... y'know?")
    |> Embed.put_description("I don't have the permissions to join the voice channel. **I** don't have?! ***The audacity!***")
  end
end
