defmodule Traindepartures.PageController do
  use Traindepartures.Web, :controller
  alias Traindepartures.Utils, as: Utils

  @csv_url "http://developer.mbta.com/lib/gtrtfs/Departures.csv"

  def index(conn, _params) do
      render conn, "index.html", getdeparturetabletemplateargs()
  end

  def departureinfoupdate(conn, _params) do
      conn
      |> put_layout(false)
      |> render("traintable.html", getdeparturetabletemplateargs())
  end

  defp getdeparturetabletemplateargs() do
      departureinfo = getdepartureinfo()
      stations = departureinfo |> Map.keys() |> Enum.sort()
      %{departureinfo: departureinfo, stations: stations}
  end

  defp getdepartureinfo() do
      require HTTPotion
      response = HTTPotion.get @csv_url
      
      require CSVLixir
      [headers | trains] = CSVLixir.parse(response.body)
      # ScheduledTime is given as seconds since epoch (1970.01.01). Make it pretty
      format_functions = %{
            "ScheduledTime": fn (x) -> Utils.format_epoch_to_12_hour_AMPM(x) end,
	    "Lateness": fn (x) ->
		  {integer_lateness, _} = Integer.parse(x)
		  formatted_lateness =
		  cond do
		      integer_lateness == 0 -> ""
		      integer_lateness > 0 -> Integer.to_string(div(integer_lateness, 60)) <> " mins"
		  end
		  formatted_lateness
	    end
      }

      train_map_list = Utils.make_map_list(headers, trains, format_functions)
      Enum.group_by(train_map_list, fn x -> x.origin end)
  end
end
