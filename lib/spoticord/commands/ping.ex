defmodule Spoticord.Commands.Ping do
  use Spoticord.Command

  def on_command(message, _args) do
  {:ok, time, _} =
    message.timestamp
    |> DateTime.from_iso8601

  diff =
    DateTime.utc_now
    |> DateTime.diff(time, :millisecond)

  text = "Time difference is `#{diff}ms`."

    alias Nostrum.Api
    Api.create_message(message.channel_id, embed: generate_ping_embed!(text))
  :ok
  end

  def generate_ping_embed!(message) do
    import Nostrum.Struct.Embed

     %Nostrum.Struct.Embed{}
    |> put_title("Pong!")
    |> put_description(message)
  end
end