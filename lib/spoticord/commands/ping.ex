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
      embed: generate_ping_embed!(message.author, request_recieved_diff)
    )

    :ok
  end

  alias Spoticord.Utils
  alias Nostrum.Struct.Embed

  def generate_ping_embed!(author, diff) do
    Utils.create_empty_embed!()
    |> Embed.put_title("Pong!")
    |> Embed.put_description("Command took `#{diff}ms` to execute!")
    |> Embed.put_author(author.username, nil, Utils.user_avatar(author))
  end
end
