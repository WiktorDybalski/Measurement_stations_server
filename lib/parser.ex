defmodule Parser do
  def parser_one_line(line) do
    [datetime, type, val, id, address, cords] = String.split(line, ";")

    %{
      id: id,
      cords:
        cords
        |> String.split(",")
        |> Enum.map(&String.to_float/1)
        |> List.to_tuple(),
      address: address,
      type: type,
      value: String.to_float(val),
      datetime: parse_datetime(datetime)
    }
  end

  defp parse_datetime(datetime) do
    datetime
    |> String.slice(0..-2//1)
    |> String.split(["T", "-", ":", "."])
    |> convert_to_tuple()
  end

  defp convert_to_tuple([year, month, day, hour, minute, second | _]) do
    {
      {String.to_integer(year), String.to_integer(month), String.to_integer(day)},
      {String.to_integer(hour), String.to_integer(minute), String.to_integer(second)}
    }
  end

  def identify_stations(data) do
    data
    |> Enum.map(fn station -> {station.address, station.cords} end)
    |> Enum.uniq_by(fn x -> x end)
  end

  defp parseReadings(data) do
    data
    |> Enum.map(fn %{
                     id: _id,
                     type: type,
                     value: value,
                     address: _address,
                     cords: {lon, lat},
                     datetime: datetime
                   } ->
      %Pollutiondb.Reading{
        date: parseDate(elem(datetime, 0)),
        time: parseTime(elem(datetime, 1)),
        type: type,
        value: value,
        station:
          Pollutiondb.Station.find_by_location(lon, lat)
          |> List.first()
      }
    end)
  end

  defp parseDate({year, month, day}) do
    Date.new!(year, month, day)
  end

  defp parseTime({hour, minutes, seconds}) do
    Time.new!(hour, minutes, seconds)
  end

  def load_data(path) do
    # Load and parse data
    data =
      File.read!(path)
      |> String.split("\n")
      |> Enum.filter(&(String.trim(&1) != ""))
      |> Enum.uniq()
      |> Enum.map(&Parser.parser_one_line/1)

    # Identify unique stations
    stations = identify_stations(data)

    # Add stations to pollution_gen_server database
    for {name, cords} <- stations do
      Pollutiondb.Station.add(name, cords |> elem(0), cords |> elem(1))
    end

    readings = parseReadings(data)

    # Add values to pollution_gen_server database
    for reading <- readings do
      Pollutiondb.Reading.add(reading)
    end
  end
end

#path = "C:/Users/wikto/pollutiondb/priv/data/AirlyData-ALL-50k.csv"
