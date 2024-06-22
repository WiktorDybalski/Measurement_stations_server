defmodule Pollutiondb.Reading do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query

  schema "readings" do
    field(:date, :date)
    field(:time, :time)
    field(:type, :string)
    field(:value, :float)
    belongs_to(:station, Pollutiondb.Station)
  end

  defp changeset(reading, data) do
    reading
    |> Ecto.Changeset.cast(data, [:date, :time, :type, :value, :station_id])
    |> validate_required([:date, :time, :type, :value, :station_id])
  end

  def add_now(station, type, value) do
    %Pollutiondb.Reading{}
    |> changeset(%{
      date: Date.utc_today(),
      time: Time.utc_now(),
      type: type,
      value: value,
      station_id: station.id
    })
    |> Pollutiondb.Repo.insert()
  end

  def add(reading) do
    Pollutiondb.Repo.insert(reading)
  end

  def get_by_date(date) do
    Pollutiondb.Repo.all(Ecto.Query.where(Pollutiondb.Reading, date: ^date))
  end

  def get_10_latest_readings do
    Ecto.Query.from(r in Pollutiondb.Reading, limit: 10, order_by: [desc: r.date, desc: r.time])
    |> Pollutiondb.Repo.all()
    |> Pollutiondb.Repo.preload(:station)
  end

  def get_10_latest_readings_by_day(date) do
    Ecto.Query.from(r in Pollutiondb.Reading,  limit: 10, where: r.date == ^date, order_by: [desc: r.time])
    |> Pollutiondb.Repo.all()
    |> Pollutiondb.Repo.preload(:station)
  end
end