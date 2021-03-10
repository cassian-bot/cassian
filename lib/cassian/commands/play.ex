defmodule Cassian.Commands.Play do
  use Cassian.Behaviours.Command

  import Cassian.Utils
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Cassian.Utils.Voice, as: VoiceUtils

  def ship?, do: true
  def caller, do: "play"
  def desc, do: "Play music in your voice channel!"

  def execute(message, args) do
    link = Enum.fetch!(args, 0)

    case youtube_metadata(link) do
      {false, :noop} ->
        Nostrum.Api.create_message!(message.channel_id, embed: not_valid_embed())

      {true, metadata} ->
        handle_song(message, link, metadata)
    end
  end

  def handle_song(message, link, metadata) do
    case VoiceUtils.get_sender_voice_id(message) do
      {:ok, {guild_id, voice_id}} ->
        if VoiceUtils.can_connect?(guild_id, voice_id) do
          if Nostrum.Voice.playing?(guild_id) do
            Cassian.Servers.Queue.insert!(guild_id, link)

            Nostrum.Api.create_message!(message.channel_id,
              embed:
                youtube_video_embed(
                  metadata,
                  link,
                  "Enqueue",
                  "The song will play as soon as the current is stopped."
                )
            )
          else
            handle_voice(guild_id, voice_id, message, link, metadata)
          end
        else
          Nostrum.Api.create_message!(message.channel_id, embed: no_perms_embed())
        end

      {:error, :noop} ->
        Nostrum.Api.create_message!(message.channel_id, embed: no_channel_embed())
    end
  end

  alias Nostrum.Struct.Embed

  def handle_voice(guild_id, voice_id, message, link, metadata) do
    VoiceUtils.join_or_switch_voice(guild_id, voice_id)
    VoiceUtils.play_when_ready(link, guild_id, 50)
    Nostrum.Api.create_message!(message.channel_id, embed: youtube_video_embed(metadata, link))
  end

  def youtube_video_embed(
        metadata,
        link,
        action \\ "Playing",
        description \\ "The music should start soon."
      ) do
    EmbedUtils.create_empty_embed!()
    |> Cassian.Utils.Embed.put_color_on_embed("#ff0000")
    |> Embed.put_title("#{action}: #{metadata["title"]}")
    |> Embed.put_description(description)
    |> Embed.put_url(link)
  end

  def not_valid_embed() do
    EmbedUtils.create_empty_embed!()
    |> EmbedUtils.put_error_color_on_embed()
    |> Embed.put_title("There is an issue my friend...")
    |> Embed.put_description(
      "It looks like that song is not present in my library. Maybe you misswrote it?"
    )
  end

  def no_channel_embed() do
    EmbedUtils.create_empty_embed!()
    |> EmbedUtils.put_error_color_on_embed()
    |> Embed.put_title("Hold it right there!")
    |> Embed.put_description("You're not in a voice channel! You won't bamboozle _me_ this time!")
  end

  def no_perms_embed() do
    EmbedUtils.create_empty_embed!()
    |> EmbedUtils.put_error_color_on_embed()
    |> Embed.put_title("I kind of can't... y'know?")
    |> Embed.put_description(
      "I don't have the permissions to join the voice channel. **I** don't have?! ***The audacity!***"
    )
  end
end
