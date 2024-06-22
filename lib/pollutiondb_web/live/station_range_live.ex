defmodule PollutiondbWeb.StationRangeLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket = assign(socket, stations: Station.get_all(), lon_min: -180, lon_max: 180, lat_min: -90, lat_max: 90)
    {:ok, socket}
  end

  defp to_float(value, default \\ 0.0) do
    case Float.parse(value) do
      {float_value, _rest} -> float_value
      :error -> default
    end
  end

  def handle_event("update", %{"lon_min" => lon_min, "lon_max" => lon_max, "lat_min" => lat_min, "lat_max" => lat_max}, socket) do
    stations = Station.find_by_location_range(to_float(lon_min), to_float(lon_max), to_float(lat_min), to_float(lat_max))
    socket = assign(socket, stations: stations, lon_min: lon_min, lon_max: lon_max, lat_min: lat_min, lat_max: lat_max)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <div class="forms">
        <div class="form-section">
          <h2>Search station by location range</h2>
          <form phx-change="update">
            <label>Longitude min: <input type="range" name="lon_min" min="-180" max="180" value={@lon_min}/></label><br/>
            <label>Longitude max: <input type="range" name="lon_max" min="-180" max="180" value={@lon_max}/></label><br/>
            <label>Latitude min: <input type="range" name="lat_min" min="-90" max="90" value={@lat_min}/></label><br/>
            <label>Latitude max: <input type="range" name="lat_max" min="-90" max="90" value={@lat_max}/></label><br/>
          </form>
        </div>
      </div>
      <div class="results">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Longitude</th>
              <th>Latitude</th>
            </tr>
          </thead>
          <tbody>
            <%= for station <- @stations do %>
              <tr>
                <td><%= station.name %></td>
                <td><%= station.lon %></td>
                <td><%= station.lat %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
