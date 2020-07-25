defmodule RogueWeb.RoomLive do
  use RogueWeb, :live_view

  alias Rogue.Room

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
            <li><%= player.name%></li>
          <% end %>
        </ul>
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
             Room.join(id) do
        {:ok, assign(socket, :room, room)}
      end
    else
      {:ok, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:room, room}, socket) do
    {:noreply, assign(socket, :room, room)}
  end

  @impl Phoenix.LiveView
  def terminate(_reason, %{assigns: assigns}) do
    id = assigns[:room].id
    Room.leave(id)
  end
end
