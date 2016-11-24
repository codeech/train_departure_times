defmodule Traindepartures.RoomChannel do
  use Phoenix.Channel

  def join("room:train_departures", _message, socket) do
      {:ok, socket}
  end

  def handle_in("new_train_info", %{"body" => body}, socket) do
      #IO.puts "handle_in"
      {:noreply, socket}
  end

  def handle_out("new_train_info", payload, socket) do
      #IO.puts "handle_out"
      push socket, "new_train_info", payload
      {:noreply, socket}
  end
end