defmodule Cassian.Behaviours.SourceService do 
  @moduledoc """
  The general service for a source of audio.
  """

  @doc """
  Try to get metadata for a specific song if it's supported.
  """
  @callback song_metadata(url :: String.t()) :: {:ok, %Cassian.Structs.Metadata{}} | {:error, :not_found}
  
  defmacro __using__(_) do
    quote do
      @behaviour Cassian.Behaviours.SourceService
      alias Cassian.Structs.Metadata
    end
  end
end
