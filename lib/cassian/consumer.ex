defmodule Cassian.Consumer do
  @moduledoc """
  The main consumer module. This handles all of the events
  from nostrum and redirects them to the modules which use them.
  """

  use Nostrum.Consumer

  alias Cassian.Consumers.{Command, VoiceEvent}

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  @doc false
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when is_nil(interaction.user.bot) do
    Command.handle_interaction(interaction)
  end

  @doc false
  def handle_event({:READY, user_data, _}) do
    Enum.each(user_data.guilds, &generate_commands/1)
    Nostrum.Api.update_status("", "music 🎶", 2)
  end

  @doc false
  def handle_event({:VOICE_SPEAKING_UPDATE, data, _}) do
    VoiceEvent.voice_speaking_update(data)
  end

  @doc false
  def handle_event({:VOICE_STATE_UPDATE, data, _}) do
    VoiceEvent.voice_state_update(data)
  end

  @doc false
  def handle_event(_) do
    :noop
  end

  @doc """
  Checks whether the command is for this bot. Returns a boolean.
  """
  @spec is_cassian_command?(message :: Nostrum.Struct.Message) :: boolean()
  def is_cassian_command?(message) do
    message.content
    |> String.trim_leading()
    |> String.downcase()
    |> String.starts_with?(Cassian.command_prefix!())
  end

  defp generate_commands(%Nostrum.Struct.Guild.UnavailableGuild{id: guild_id}) do
    Nostrum.Api.create_guild_application_command(guild_id, Cassian.Commands.Bot.Help.application_command_definition())
  end

end
