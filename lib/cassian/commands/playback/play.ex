defmodule Cassian.Commands.Playback.Play do
  require Logger
  alias Nostrum.Struct.Embed
  use Cassian.Behaviours.Command

  import Cassian.Utils
  alias Cassian.Utils.Voice, as: VoiceUtils
  alias Cassian.Managers.PlayManager

  # Main logic pipe
  
  def application_command_definition() do
    %{
      name: "play",
      description: "Play a song or queue it.",
      options: [
        %{
          type: 3,
          name: "query",
          required: true,
          description: "Name of the song of URL for it."
        }
      ]
    }
  end

  def execute(interaction) do
    {embed, flags} =
      with {:ok, {_guild_id, voice_id}} <- VoiceUtils.sender_voice_id(interaction),
           {:ok, query} <- fetch_query(interaction.data.options),
           {:ok, metadata} <- song_metadata(query),
           {:ok, _} <- VoiceUtils.join_or_switch_voice(interaction.guild_id, voice_id),
           :ok <- PlayManager.insert!(interaction.guild_id, interaction.channel_id, metadata) do
        PlayManager.play_if_needed(interaction.guild_id)
        {
          EmbedUtils.create_empty_embed!()
          |> Embed.put_title("Enqueued the song")
          |> Embed.put_description("It'll start playing soon..."),
          1 <<< 6
        }
      else
        {:error, :not_in_voice} ->
          no_channel_error()
        {:error, :no_metadata} ->
          invalid_link_error()
        {:error, :failed_to_join} ->
          no_permissions_error()
        {:error, :failed_to_get_stream}
          invalid_link_error()
      end
    
    %{type: 4, data: %{embeds: [embed], flags: flags}}
  end
  
  defp fetch_query(options) do
    option =
      options
      |> Enum.find(fn option -> String.equivalent?(option.name, "query") end)
    
    case option do
      nil ->
        {:error, :no_metadata}
      
      _ ->
        {:ok, option.value}
    end
  end

  # Error handlers

  @doc """
  Generate and send the embed for when a user isn't in a voice channel.
  """
  def no_channel_error() do
    {
      EmbedUtils.generate_error_embed(
        "Hey you... You're not in a voice channel.",
        "I can't play any music if you're not a voice channel. Join one first."
      ),
      1 <<< 6
    }
  end

  @doc """
  Generate and send the embed for when the bot doesn't have permissions to view, connect or
  speak in a channel.
  """
  def no_permissions_error() do
    {
      EmbedUtils.generate_error_embed(
        "And how do you think that's possible?",
        "I don't have the permissions to play music there or something else really messed me up."
      ),
      1 <<< 6
    }
  end

  @doc """
  Tell the user that the link is not valid.
  """
  def invalid_link_error() do
    {
      EmbedUtils.generate_error_embed(
        "Yeah, that won't work.",
        "The link you tried to provide me isn't working. Recheck it."
      ),
      1 <<< 6
    }
  end
end
