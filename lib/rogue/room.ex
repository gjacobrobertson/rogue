defmodule Rogue.Room do
  use GenServer, restart: :transient

  alias Rogue.PubSub
  alias Rogue.RoomSupervisor
  alias Rogue.RoomRegistry
  alias Rogue.Player

  defstruct [:id, players: %{}, turn: 0]

  @dt 1500

  @type t() :: %__MODULE__{
          id: binary(),
          players: %{optional(pid()) => Player.t()},
          turn: integer()
        }

  @impl GenServer
  @spec init(binary()) :: {:ok, t(), {:continue, :broadcast}}
  def init(id) do
    Process.send_after(self(), :tick, @dt)
    {:ok, %__MODULE__{id: id}, {:continue, :broadcast}}
  end

  @impl GenServer
  def handle_call(:join, {from, _}, state) do
    new_state = put_in(state.players[from], Player.create())
    {:reply, {:ok, new_state}, new_state, {:continue, :broadcast}}
  end

  def handle_call(:leave, {from, _}, state) do
    {_player, new_state} = pop_in(state.players[from])

    continue =
      if(Enum.empty?(new_state.players)) do
        :exit
      else
        :broadcast
      end

    {:reply, {:ok, new_state}, new_state, {:continue, continue}}
  end

  @impl GenServer
  @spec handle_continue(atom(), t()) :: {:noreply, t()}
  def handle_continue(:broadcast, room) do
    Phoenix.PubSub.broadcast!(PubSub, "room:#{room.id}", {:room, room})
    {:noreply, room}
  end

  def handle_continue(:exit, _room) do
    Process.exit(self(), :room_empty)
  end

  @impl GenServer
  def handle_info(:tick, room) do
    next_state = update_in(room.turn, &(&1 + 1))
    Process.send_after(self(), :tick, @dt)
    {:noreply, next_state, {:continue, :broadcast}}
  end

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(options) do
    {id, opts} = Keyword.pop!(options, :id)
    GenServer.start_link(__MODULE__, id, opts)
  end

  @spec join(binary() | pid()) :: {:ok, t()} | {:error, term()}
  def join(id) when is_binary(id) do
    {:ok, room} =
      case lookup(id) do
        {:error, :room_not_found} -> create(id)
        x -> x
      end

    join(room)
  end

  def join(pid) when is_pid(pid) do
    with {:ok, room} <- GenServer.call(pid, :join),
         :ok <- Phoenix.PubSub.subscribe(PubSub, "room:#{room.id}") do
      {:ok, room}
    end
  end

  @spec leave(binary() | pid()) :: {:ok, t()}
  def leave(id) when is_binary(id) do
    with {:ok, room} <- lookup(id) do
      leave(room)
    end
  end

  def leave(pid) when is_pid(pid) do
    with {:ok, room} <- GenServer.call(pid, :leave),
         :ok <- Phoenix.PubSub.unsubscribe(PubSub, "room:#{room.id}") do
      {:ok, room}
    end
  end

  @spec lookup(binary()) :: {:ok, pid()} | {:error, term()}
  defp lookup(id) do
    case Registry.lookup(RoomRegistry, id) do
      [{room, _}] ->
        {:ok, room}

      [] ->
        {:error, :room_not_found}
    end
  end

  @spec create(binary()) :: Supervisor.on_start_child()
  defp create(id) do
    DynamicSupervisor.start_child(RoomSupervisor, {
      __MODULE__,
      id: id, name: {:via, Registry, {Rogue.RoomRegistry, id}}
    })
  end
end
