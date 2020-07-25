defmodule RogueWeb.PageLive do
  use RogueWeb, :live_view

  @impl Phoenix.LiveView
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <%= live_patch to: Routes.live_path(@socket, RogueWeb.RoomLive, UUID.uuid4()) do %>
    Start
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
