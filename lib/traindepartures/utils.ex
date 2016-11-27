defmodule Traindepartures.Utils do
  @moduledoc """
      Provides utility functions for the purposes of converting
      the Departures.csv to an appropriate elixir data structure
  """

  @us_east_coast_timezone "America/New_York"
  def us_east_coast_timezone, do: @us_east_coast_timezone

  @csv_url "http://developer.mbta.com/lib/gtrtfs/Departures.csv"
  def csv_url, do: @csv_url

  @train_table_template "traintable.html"
  def train_table_template, do: @train_table_template

  def getdeparturetabletemplateargs() do
      departureinfo = getdepartureinfo()
      stations = departureinfo |> Map.keys() |> Enum.sort()
      %{departureinfo: departureinfo, stations: stations}
  end

  def getdepartureinfo() do
      response = HTTPotion.get @csv_url
      if response.status_code == 200 do
	  [headers | trains] = CSVLixir.parse(response.body)
	  # ScheduledTime is given as seconds since epoch (1970.01.01). Make it pretty
	  format_functions = %{
		"ScheduledTime": fn (x) -> format_epoch_to_12_hour_AMPM(x) end,
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

	  train_map_list = make_map_list(headers, trains, format_functions)
	  Enum.group_by(train_map_list, fn x -> x.origin end)
      else
	  %{}
      end
  end

  @doc """
       TrainDepartures.Utils.make_map_list

       Given a list of headers and a list of lists
       of the same length as headers, return a list
       of maps (one for each list in lists) with
       keys from headers and values each list.
       Also takes a map of header_element => anonymous_function/1,
       used to format each value that corresponds to header_element.
       

       E.g.
       Input:
	   headers = ["Longitude", "Latitude"]
	   lists = [
	      ["42.617735", "-70.659680"],
	      ["-25.107888", "132.808167"]
	   ]
       Output:
	   [
		%{longitude: "42.617735", latitude: "-70.659680"}
		%{longitude: "-25.107888", latitude: "132.808167"}
	   ]
  """
  def make_map_list(headers, lists, format_functions \\ %{}) do
      if lists != [] do
      	 lists |> Enum.map(&make_map(headers, &1, format_functions))
      else
	 []
      end
  end

  @doc """
       TrainDepartures.Utils.make_map

       See make_map_list
  """
  def make_map(headers, list, format_functions \\ %{}, map \\ %{})

  def make_map([next_key | keys], [next_val | values], format_functions, map) do
      format_function = Map.get(format_functions, String.to_atom(next_key)) || fn(x) -> x end

      # apply any formatting
      next_val = format_function.(next_val)

      # If the key is a string, make it an atom
      next_key = if (is_binary(next_key)), do: String.to_atom(String.downcase(next_key)), else: next_key

      map = Map.put(map, next_key, next_val)
      make_map(keys, values, format_functions, map)
  end

  def make_map([], [], %{}, map) do
      map
  end

  @doc """
      Traindepartures.Utils.format_epoch_to_12_hour_AMPM
      Convert at date given in seconds since 1970.01.01 to its 12 hour AM/PM
      representation. 

      timezone_string is a Timex recognized timezome
      - see https://hexdocs.pm/timex/getting-started.html
  """
  def format_epoch_to_12_hour_AMPM(epoch, timezone_string \\ @us_east_coast_timezone) do
      require Timex

      {integer_epoch, _} = Integer.parse(epoch)
      time = integer_epoch |> DateTime.from_unix!()

      timezone = Timex.Timezone.get(timezone_string, Timex.now)
      datetime = Timex.Timezone.convert(time, timezone)

      Timex.format!(datetime, "{h12}:{0m} {AM}")
  end
end