defmodule Rogue.Room do
  defstruct [:id, players: %{}, turn: 0, width: 10, height: 10]

  alias Rogue.Player

  @type t() :: %__MODULE__{
          id: binary(),
          players: %{optional(pid()) => Player.t()},
          turn: integer()
        }

  @max_players 4

  @spec tick(t()) :: t()
  def tick(room) do
    room
    |> apply_actions()
    |> increment_turn()
  end

  @spec join(t(), pid()) :: {:ok, t()} | {:error, term()}
  def join(room, pid) do
    cond do
      Enum.count(room.players) >= @max_players ->
        {:error, :room_full}

      Map.has_key?(room.players, pid) ->
        {:error, :already_joined}

      true ->
        tile = find_empty_tile(room)
        {:ok, put_in(room.players[pid], Player.create(tile))}
    end
  end

  @spec leave(t(), pid()) :: t()
  def leave(room, pid) do
    {_player, next} = pop_in(room.players[pid])
    next
  end

  @spec set_action(t(), pid(), Player.action()) :: t()
  def set_action(room, pid, action) do
    put_in(room.players[pid].action, action)
  end

  @spec increment_turn(t()) :: t()
  defp increment_turn(room) do
    update_in(room.turn, &(&1 + 1))
  end

  @spec apply_actions(t()) :: t()
  defp apply_actions(room) do
    Enum.reduce(room.players, room, &act/2)
  end

  @spec act({pid(), Player.t()}, t()) :: t()
  defp act({pid, %Player{action: action} = player}, room) do
    case action do
      {:move, dir} -> teleport(room, pid, Player.move(player, dir))
      _ -> room
    end
    |> set_action(pid, nil)
  end

  @spec teleport(t(), pid(), Player.position()) :: t()
  defp teleport(room, pid, tile) do
    if free_tile?(room, tile) do
      put_in(room.players[pid].position, tile)
    else
      room
    end
  end

  @spec free_tile?(t(), Player.position()) :: boolean()
  defp free_tile?(_room, {x, y}) when x < 1 or y < 1, do: false

  defp free_tile?(%__MODULE__{width: width, height: height}, {x, y}) when x > width or y > height,
    do: false

  defp free_tile?(room, {x, y} = tile) do
    x > 0 and x <= room.width and y
    Enum.all?(room.players, fn {_pid, player} -> player.position != tile end)
  end

  @spec random_tile(t()) :: Player.position()
  defp random_tile(room) do
    x = Enum.random(0..room.width)
    y = Enum.random(0..room.height)
    {x, y}
  end

  @spec find_empty_tile(t()) :: Player.position()
  defp find_empty_tile(room) do
    Stream.repeatedly(fn -> random_tile(room) end)
    |> Enum.find(&free_tile?(room, &1))
  end
end
