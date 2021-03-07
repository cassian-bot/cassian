defmodule Spoticord.Commands.Ping do
  use Spoticord.Command

  @moduledoc """
  The ping command. Shows how many ms was needed to perform the request.
  """

  @doc false
  def execute(message, _args) do
    {:ok, request_time, _} =
      message.timestamp
      |> DateTime.from_iso8601

    recieved_time = DateTime.utc_now

    request_recieved_diff =
      recieved_time
      |> DateTime.diff(request_time, :millisecond)


    Nostrum.Api.create_message(
      message.channel_id,
      embed: generate_ping_embed!("Pong took `#{request_recieved_diff}ms` to respond!")
    )

    :ok
  end

  @doc false
  def generate_ping_embed!(message) do
    import Nostrum.Struct.Embed

    %Nostrum.Struct.Embed{}
    |> put_title("Pong!")
    |> put_description(message)
  end
end
