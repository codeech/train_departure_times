defmodule Traindepartures.BroadCastTrainSchedule do
    use GenServer

    @traintable_refresh_interval_mins 5

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
    	 IO.puts "do_work(state)"
	 require HTTPotion
	 #response = HTTPotion.get "http://developer.mbta.com/lib/gtrtfs/Departures.csv"
	 response = HTTPotion.get "http://localhost:4000/departureinfoupdate"
    	 Traindepartures.Endpoint.broadcast! "room:train_departures", "new_train_info", %{body: response.body}
	 {:noreply, state}
    end

    defp schedule_work do
    	 Process.send_after(self(), :work, 1_000 * 60 * @traintable_refresh_interval_mins)
    end
end