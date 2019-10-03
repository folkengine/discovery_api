defmodule DiscoveryApi.Repo.Migrations.CreateOrganizationTable do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :org_id, :string, null: false
      add :name, :string, null: false
      add :title, :string, null: false
      add :description, :string
      add :homepage, :string
      add :logo_url, :string

      timestamps()
    end

    create unique_index(:organizations, [:org_id])
  end
end
