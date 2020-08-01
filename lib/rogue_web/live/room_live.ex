defmodule RogueWeb.RoomLive do
  use RogueWeb, :live_view

  alias Rogue.RoomServer

  @impl Phoenix.LiveView
  def render(assigns) do
    ~L"""
    <%= if assigns[:room] do %>
      <h2>Welcome, <%= @room.players[self()].name %></h2>
      <section>
        <h3>Turn</h3>
        <p><%= @room.turn %></p>
      </section>
      <section>
        <h3>Players</h3>
        <ul>
          <%= for {_, player } <- @room.players do %>
            <li>
              <h4><%= player.name%></h4>
              <p>Position: <%=inspect(player.position)%> </p>
              <p>Position: <%=inspect(player.action)%> </p>
            </li>
          <% end %>
        </ul>
      </section>
      <section>
        <h3>Actions<h3>
        <ul>
          <li><button phx-click="move" phx-value-dir="up">Up</button></li>
          <li><button phx-click="move" phx-value-dir="down">Down</button></li>
          <li><button phx-click="move" phx-value-dir="left">Left</button></li>
          <li><button phx-click="move" phx-value-dir="right">Right</button></li>
        <ul>
      </section>
    <% else %>
    <p>Loading</p>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    if connected?(socket) do
      with {:ok, id} <- Map.fetch(params, "id"),
           {:ok, room} <-
             RoomServer.join(id) do
        {:ok, assign(socket, :room, room)}
      end
    else
      {:ok, socket}
    end
  end

  @impl Phoenix.LiveView
  def terminate(_reason, %{assigns: assigns}) do
    id = assigns[:room].id
    RoomServer.leave(id)
  end

  @impl Phoenix.LiveView
  def handle_info({:room, room}, socket) do
    {:noreply, assign(socket, :room, room)}
  end

  @impl Phoenix.LiveView

  def handle_event("move", %{"dir" => "left"}, socket), do: move(:left, socket)
  def handle_event("move", %{"dir" => "right"}, socket), do: move(:right, socket)
  def handle_event("move", %{"dir" => "up"}, socket), do: move(:up, socket)
  def handle_event("move", %{"dir" => "down"}, socket), do: move(:down, socket)
  def handle_event("move", _, socket), do: {:noreply, socket}

  defp move(direction, socket) do
    id = socket.assigns[:room].id
    {:ok, room} = RoomServer.set_action(id, {:move, direction})
    {:noreply, assign(socket, :room, room)}
  end
end
