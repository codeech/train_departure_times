defmodule Traindepartures.BroadCastTrainSchedule do
  use GenServer
  alias Traindepartures.Utils, as: Utils

  @train_table_refresh_interval_mins 3

  def start_link() do
    GenServer.start_link(__MODULE__, %{:train_info => %{}})
  end

  def init(state) do
    schedule_departure_table_update()
    {:ok, state}
  end

  def handle_info(:update_departure_table, state) do
    new_train_info = update_departure_table(state)
    schedule_departure_table_update()
    {:noreply, %{:train_info => new_train_info}}
  end

  defp update_departure_table(state) do
    state = Utils.get_departure_table_template_args()
    # TODO: only broadcast html if the state has changed.
    # I.e. Utils.get_departure_table_template_args() and state are different
    updated_train_info_html = Phoenix.View.render_to_string(Traindepartures.PageView, Utils.train_table_template, state)
    Traindepartures.Endpoint.broadcast! "train_departures_schedule", "new_train_info", %{body: updated_train_info_html}
    state
  end

  defp schedule_departure_table_update do
    Process.send_after(self(), :update_departure_table, 1_000 * 60 * @train_table_refresh_interval_mins)
  end
end
