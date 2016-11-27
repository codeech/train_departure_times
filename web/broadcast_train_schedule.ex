defmodule Traindepartures.BroadCastTrainSchedule do
    use GenServer
    alias Traindepartures.Utils, as: Utils

    @train_table_refresh_interval_mins 5

    def start_link() do
    	GenServer.start_link(__MODULE__, [])
    end

    def init([]) do
    	schedule_work()
	{:ok, []}
    end
    
    def handle_info(:work, state) do
    	state = do_work(state)
	schedule_work()
	{:noreply, state}
    end

    defp do_work(state) do
	 updated_train_info = Utils.getdeparturetabletemplateargs()
	 updated_train_info_html = Phoenix.View.render_to_string(Traindepartures.PageView, Utils.train_table_template, updated_train_info)
    	 Traindepartures.Endpoint.broadcast! "room:train_departures", "new_train_info", %{body: updated_train_info_html}
	 {:noreply, state}
    end

    defp schedule_work do
    	 Process.send_after(self(), :work, 1_000 * 60 * @train_table_refresh_interval_mins)
    end
end