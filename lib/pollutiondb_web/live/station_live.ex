defmodule PollutiondbWeb.StationLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket = assign(socket, stations: Station.get_10(), name: "", lon: "", lat: "", query: "")
    {:ok, socket}
  end

  defp to_float(value, default \\ 0.0) do
    case Float.parse(value) do
      {float_value, _rest} -> float_value
      :error -> default
    end
  end

  def handle_event("insert", %{"name" => name, "lon" => lon, "lat" => lat}, socket) do
    Station.add(name, to_float(lon, 0.0), to_float(lat, 0.0))
    socket = assign(socket, stations: Station.get_all(), name: "", lon: "", lat: "", query: "")
    {:noreply, socket}
  end

  def handle_event("find", %{"query" => query}, socket) do
    stations =
      if query == "" do
        Station.get_all()
      else
        Station.find_by_name(query)
      end

    socket = assign(socket, stations: stations, query: query, name: "", lon: "", lat: "")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <div class="forms">
        <div class="form-section">
          <h2>Search station by name</h2>
          <form phx-change="find">
            <label>Station name: <input type="text" name="query" value={@query} /></label>
          </form>
        </div>
        <div class="form-section">
          <h2>Create new station</h2>
          <form phx-submit="insert">
            <label>Name: <input type="text" name="name" value={@name} /></label><br/>
            <label>Longitude: <input type="number" name="lon" step="0.1" value={@lon} /></label><br/>
            <label>Latitude: <input type="number" name="lat" step="0.1" value={@lat} /></label><br/>
            <input type="submit" value="Create" />
          </form>
        </div>
      </div>

      <div class="results">
        <table>
          <thead>
            <tr>
              <th>Name</th><th>Longitude</th><th>Latitude</th>
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
