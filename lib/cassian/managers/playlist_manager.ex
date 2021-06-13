defmodule Cassian.Managers.PlaylistManager do
  @moduledoc """
  Module for managing the playlists themselves.
  """

  alias Cassian.Structs.{VoiceState, Playlist}
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Cassian.Managers.MessageManager
  alias Nostrum.Struct.{Message, Embed}

  @doc """
  Change the repeat of the playlist. If `allow_update` is false, then
  setting the repeat to the current repeat will set it to `:none`, else
  it will just set it to the specific value.
  """
  @spec change_repeat(
          guild_id :: Snowflake.t(),
          type :: :none | :one | :all,
          allow_update :: boolean()
        ) :: {:ok, :none | :all | :one} | {:error, :noop}
  def change_repeat(guild_id, type, allow_update \\ false) do
    case Playlist.show(guild_id) do
      {:ok, playlist} ->
        new_status =
          if playlist.repeat == type and !allow_update do
            :none
          else
            type
          end

        playlist
        |> Map.put(:repeat, new_status)
        |> Playlist.put()

        {:ok, new_status}

      {:error, :noop} ->
        :error
    end
  end

  @doc """
  Add a song to the playlist.
  """
  def insert!(guild_id, channel_id, metadata) do
    Playlist.insert!(guild_id, metadata)

    VoiceState.get!(guild_id)
    |> Map.put(:channel_id, channel_id)
    |> notify_enqueued(metadata)
    |> VoiceState.put()
  end

  @doc """
  Notify state a song is enqueued. Will be moved.
  """
  def notify_enqueued(state, metadata) do
    unless state.status == :noop do
      alias Cassian.Utils.Embed, as: EmbedUtils
      alias Nostrum.Struct.Embed

      embed =
        EmbedUtils.create_empty_embed!()
        |> EmbedUtils.put_color_on_embed(metadata.color)
        |> Embed.put_url(metadata.link)
        |> Embed.put_title("Enqueued: #{metadata.title}")

      MessageManager.send_dissapearing_embed(embed, state.channel_id)
    end

    state
  end

  @doc """
  Alter the index, the index will be incremented or decremented depending
  on the current playlist direction.
  """
  def alter_index(guild_id) do
    case Playlist.show(guild_id) do
      {:ok, playlist} ->
        index = playlist.index + if playlist.reverse, do: -1, else: 1

        index =
          case playlist.repeat do
            :none ->
              index

            :one ->
              playlist.index

            :all ->
              keep_in_bounds(index, playlist.elements)
          end

        playlist
        |> Map.put(:index, index)
        |> Playlist.put()

      {:error, :noop} ->
        nil
    end
  end

  @doc """
  Check whether the index is in bounds.
  """
  @spec in_bound?(index :: Integer.t(), ordered :: list()) :: boolean()
  def in_bound?(index, ordered) do
    index >= 0 and index < length(ordered)
  end

  @doc """
  Keep the index in bounds. Loop around if not in bound.
  """
  @spec keep_in_bounds(index :: Integer.t(), ordered :: list()) :: Integer.t()
  def keep_in_bounds(index, ordered) do
    size = length(ordered)
    index = if index >= size, do: 0, else: index
    if index < 0, do: size - 1, else: index
  end

  @doc """
  Clear/delete the queue for a guild_id.
  """
  def clear!(guild_id) do
    Playlist.delete(guild_id)
  end

  @doc """
  Change the direction of the playlist. Safely return if this is done.
  """
  @spec change_direction(guild_id :: Snowflake.t(), reverse :: boolean()) :: :ok | :noop
  def change_direction(guild_id, reverse) do
    case Playlist.show(guild_id) do
      {:ok, playlist} ->
        playlist
        |> Map.put(:reverse, reverse)
        |> Playlist.put()

        :ok

      {:error, :noop} ->
        :noop
    end
  end

  @doc """
  Chaange the direction of the playlist and send a notification.
  """
  @spec change_direction_with_notification(message :: %Message{}, reverse :: boolean()) ::
          :ok | :noop
  def change_direction_with_notification(message, reverse) do
    title_part = if reverse, do: "in reverse", else: "normally"

    case change_direction(message.guild_id, reverse) do
      :ok ->
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Playing #{title_part}.")
        |> Embed.put_description("The current playlist will play #{title_part}.")

      :noop ->
        EmbedUtils.generate_error_embed(
          "There is no playlist.",
          "I can't change the direction of the playlist if it doesn't exist."
        )
    end
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  @doc """
  Change the direction of the playlist and send a notification. If the type of
  repeat is the same as the current one, it will be set to :none unless you set `allow_update` to true.
  """
  @spec change_repeat_with_notification(
          message :: %Message{},
          type :: :none | :one | :all,
          allow_update :: boolean()
        ) :: :ok | :noop
  def change_repeat_with_notification(message, type, allow_update \\ false) do
    case change_repeat(message.guild_id, type, allow_update) do
      {:ok, type} ->
        {message, description} =
          case type do
            :none ->
              {"Not repeating the playlist.", "The playlist will not be repeated."}

            :one ->
              {"Repeating one.", "Only the current song will be repeated."}

            :all ->
              {"Repeating is on.", "The whole playlist will be repeated."}
          end

        EmbedUtils.create_empty_embed!()
        |> Embed.put_title(message)
        |> Embed.put_description(description)

      :error ->
        EmbedUtils.generate_error_embed(
          "There is no playlist.",
          "I can't change the repeat of the playlist if it doesn't exist."
        )
    end
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  @doc """
  Shuffle the playlist.
  """
  @spec shuffle(guild_id :: Snowflake.t()) :: :ok | :noop
  def shuffle(guild_id) do
    if Playlist.exists?(guild_id) do
      Playlist.shuffle(guild_id)
      :ok
    else
      :noop
    end
  end

  @doc """
  Shuffle the playlist and notify a channel that is has been shuffled.
  """
  @spec shuffle_and_notify(message :: %Message{}) :: :ok | :noop
  def shuffle_and_notify(message) do
    case shuffle(message.guild_id) do
      :ok ->
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Shuffled the music.")

      :error ->
        EmbedUtils.generate_error_embed(
          "There is no playlist.",
          "You can't shuffle the playlist if none exists."
        )
    end
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  @doc """
  Unshuffle the playlist.
  """
  @spec unshuffle(guild_id :: Snowflake.t()) :: :ok | :noop | :no
  def unshuffle(guild_id) do
    case Playlist.show(guild_id) do
      {:ok, playlist} ->
        if playlist.shuffle do
          Playlist.unshuffle(guild_id)
          :ok
        else
          :no
        end

      {:error, :noop} ->
        :noop
    end
  end

  @doc """
  Unshuffle the playlist and notify a channel that is has been shuffled.
  """
  @spec unshuffle_and_notify(message :: %Message{}) :: :ok | :noop
  def unshuffle_and_notify(message) do
    case unshuffle(message.guild_id) do
      :ok ->
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Unshuffled the music.")

      :noop ->
        EmbedUtils.generate_error_embed(
          "There is no playlist.",
          "You can't unshuffle the playlist if none exists."
        )

      :no ->
        EmbedUtils.generate_error_embed(
          "Not shuffled.",
          "You can't unshuffle the playlist which isn't shuffled."
        )
    end
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end
end
