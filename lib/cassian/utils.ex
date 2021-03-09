defmodule Cassian.Utils do
  @moduledoc """
  Module for general utils...
  """

  @doc """
  Get the user avatar url.
  """
  @spec user_avatar(user :: Nostrum.Struct.User) :: String.t()
  def user_avatar(user) do
    "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png"
  end

  @doc """
  Check whether a link is a YouTube one.
  """
  @spec youtube_link?(url :: String.t()) :: boolean()
  def youtube_link?(url) do
    url =
      "https://www.youtube.com/oembed?url=#{url}&format=json"

    headers = [
      "User-agent": "#{Cassian.username!()} #{Cassian.version!}",
      "Accept": "Application/json; Charset=utf-8"
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        true
      _ ->
        false
    end
  end
end
