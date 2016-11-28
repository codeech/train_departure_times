defmodule Traindepartures.Schedule do
  use Phoenix.Channel

  def join("train_departures_schedule", _message, socket) do
      {:ok, socket}
  end

  def handle_in("new_train_info", %{"body" => body}, socket) do
      {:noreply, socket}
  end

  def handle_out("new_train_info", payload, socket) do
      push socket, "new_train_info", payload
      {:noreply, socket}
  end
end
