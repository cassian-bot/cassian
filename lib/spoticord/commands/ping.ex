defmodule Spoticord.Commands.Ping do
  use Spoticord.Command

  @moduledoc """
  The ping command. Shows how many ms was needed to perform the request.
  """

  def description, do: "Show the delay!"

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
      embed: generate_ping_embed!(request_recieved_diff)
    )

    :ok
  end

  alias Spoticord.Utils
  alias Nostrum.Struct.Embed

  def generate_ping_embed!(diff) do
    Utils.create_empty_embed!()
    |> Embed.put_title("Pong!")
    |> Embed.put_description("Command took `#{diff}ms` to execute!")
  end
end
