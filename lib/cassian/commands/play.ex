defmodule Cassian.Commands.Play do
  use Cassian.Behaviours.Command

  import Cassian.Utils
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Cassian.Utils.Voice, as: VoiceUtils

  alias Nostrum.Api

  def ship?, do: true
  def caller, do: "play"
  def desc, do: "Play music in your voice channel!"

  def execute(message, args) do
    link = Enum.fetch!(args, 0)

    case youtube_metadata(link) do
      {true, metadata} ->
        VoiceUtils.get_sender_voice_id(message)
        |> handle_request(message: message, link: link, metadata: metadata)

      {false, :noop} ->
        Api.create_message!(message.channel_id, embed: not_valid_embed())
    end
  end

  # Handle connect request

  @doc """
  Handle the request for the command. The first argument is pattern-matched whether
  someone is in a channel. See `Cassian.Utils.Voice.get_sender_voice_id/1`
  for info about the first argument.

  It either continues with the request or notifies the user that
  they can't play music if they're not in a voice channel..
  """
  def handle_request({:ok, {guild_id, voice_id}}, values) do
    values = values ++ [guild_id: guild_id, voice_id: voice_id]

    VoiceUtils.can_connect?(guild_id, voice_id)
    |> handle_connect(values)
  end

  @doc false
  def handle_request({:error, :noop}, values), do:
    Nostrum.Api.create_message!(extract(values, :message).channel_id, embed: no_channel_embed())

  @doc """
  Try to play the song if you have permissions. First argument is meant whether
  you have permissions to play in the voice channel.
  """
  def handle_connect(true, values) do
    Nostrum.Voice.playing?(extract(values, :guild_id))
    |> handle_play(values)
  end

  @doc false
  def handle_connect(false, values), do:
    Api.create_message!(extract(values, :message).channel_id, embed: no_perms_embed())

  # Handle play

  @doc """
  Play or enqueue the song.
  """
  def handle_play(false, values) do
    handle_voice(values)
  end

  @doc false
  def handle_play(true, values) do
    Cassian.Servers.Queue.insert!(extract(values, :guild_id), extract(values, :link))

    Api.create_message!(extract(values, :message).channel_id,
      embed:
        youtube_video_embed(
          extract(values, :metadata),
          extract(values, :link),
          "Enqueue",
          "The song will play as soon as the current is stopped."
        )
    )
  end

  #

  alias Nostrum.Struct.Embed

  def handle_voice(values) do
    VoiceUtils.join_or_switch_voice(
      extract(values, :guild_id),
      extract(values, :voice_id)
    )
    VoiceUtils.play_when_ready!(
      extract(values, :link),
      extract(values, :guild_id)
    )
    Api.create_message!(
      extract(values, :message).channel_id,
      embed: youtube_video_embed(
        extract(values, :metadata),
        extract(values, :link)
      )
    )
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

  @doc false
  defp extract(values, atom) do
    Keyword.fetch!(values, atom)
  end
end
