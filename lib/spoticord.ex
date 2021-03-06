defmodule Spoticord do
  def command_prefix!(server_id \\ nil) do
    Application.get_env(:spoticord, :prefix)
  end
end
