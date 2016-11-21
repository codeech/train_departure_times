defmodule Traindepartures.Utils do
  @moduledoc """
      Provides utility functions for the purposes of converting
      the Departures.csv to an appropriate elixir data structure
  """

  @us_east_coast_timezone "America/New_York"
  def us_east_coast_timezone, do: @us_east_coast_timezone

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