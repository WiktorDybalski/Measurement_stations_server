defmodule Pollutiondb.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :date, :date
      add :type, :string
      add :value, :float
      add :station_id, references(:stations, on_delete: :delete_all)
      add :time, :time
    end
  end
end

