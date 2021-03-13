defmodule Cassian.Commands.Ping do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.MessageManager

  @moduledoc """
  The ping command. Shows how many ms was needed to perform the request.
  """

  def example do
    "ping"
  end

  def short_desc do
    "Show how many `ms` was needed in order for the bot to respond."
  end

  def long_desc do
    short_desc()
  end

  @doc false
  def execute(message, _args) do
    {:ok, request_time, _} =
      message.timestamp
      |> DateTime.from_iso8601()

    recieved_time = DateTime.utc_now()

    request_recieved_diff =
      recieved_time
      |> DateTime.diff(request_time, :millisecond)

    generate_ping_embed!(request_recieved_diff)
    |> MessageManager.send_embed(message.channel_id)

    :ok
  end

  import Cassian.Utils.Embed
  alias Nostrum.Struct.Embed

  def generate_ping_embed!(diff) do
    create_empty_embed!()
    |> Embed.put_title("Pong!")
    |> Embed.put_description("Command took `#{diff}ms` to execute!")
  end
end
