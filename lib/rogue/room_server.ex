defmodule Rogue.RoomServer do
  use GenServer, restart: :transient

  alias Rogue.PubSub
  alias Rogue.RoomSupervisor
  alias Rogue.RoomRegistry
  alias Rogue.Room

  @dt 1500

  @impl GenServer
  @spec init(binary()) :: {:ok, Room.t(), {:continue, :broadcast}}
  def init(id) do
    Process.send_after(self(), :tick, @dt)
    {:ok, %Room{id: id}, {:continue, :broadcast}}
  end

  @impl GenServer
  def handle_call(:join, {from, _}, state) do
    reply = Room.join(state, from)

    new_state =
      case reply do
        {:ok, room} -> room
        _ -> state
      end

    {:reply, reply, new_state, {:continue, :broadcast}}
  end

  def handle_call(:leave, {from, _}, state) do
    new_state = Room.leave(state, from)

    continue =
      if(Enum.empty?(new_state.players)) do
        :exit
      else
        :broadcast
      end

    {:reply, {:ok, new_state}, new_state, {:continue, continue}}
  end

  def handle_call({:set_action, action}, {from, _}, state) do
    new_state = Room.set_action(state, from, action)
    {:reply, {:ok, new_state}, new_state, {:continue, :broadcast}}
  end

  @impl GenServer
  @spec handle_continue(atom(), Room.t()) :: {:noreply, Room.t()}
  def handle_continue(:broadcast, room) do
    Phoenix.PubSub.broadcast!(PubSub, "room:#{room.id}", {:room, room})
    {:noreply, room}
  end

  def handle_continue(:exit, _room) do
    DynamicSupervisor.terminate_child(RoomSupervisor, self())
  end

  @impl GenServer
  def handle_info(:tick, room) do
    next_state = Room.tick(room)
    Process.send_after(self(), :tick, @dt)
    {:noreply, next_state, {:continue, :broadcast}}
  end

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(options) do
    {id, opts} = Keyword.pop!(options, :id)
    GenServer.start_link(__MODULE__, id, opts)
  end

  @spec join(binary() | pid()) :: {:ok, Room.t()} | {:error, term()}
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

  @spec leave(binary() | pid()) :: {:ok, Room.t()}
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

  def set_action(id, action) when is_binary(id) do
    with {:ok, room} <- lookup(id) do
      GenServer.call(room, {:set_action, action})
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
