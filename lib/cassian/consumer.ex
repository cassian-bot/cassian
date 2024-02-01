defmodule Cassian.Consumer do
  @moduledoc """
  The main consumer module. This handles all of the events
  from nostrum and redirects them to the modules which use them.
  """

  use Nostrum.Consumer

  alias Cassian.Consumers.{Command, VoiceEvent}

  @doc false
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when is_nil(interaction.user.bot) do
    Command.handle_interaction(interaction)
    :ok
  end

  @doc false
  def handle_event({:READY, user_data, _}) do
    Enum.each(user_data.guilds, &Command.generate_commands/1)
    Nostrum.Api.update_status(:online, "music 🎶", 2)
    :ok
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
end
