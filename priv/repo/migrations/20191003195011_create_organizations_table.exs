defmodule DiscoveryApi.Repo.Migrations.CreateOrganizationTable do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add(:id, :string, null: false, primary_key: true)
      add(:name, :string, null: false)
      add(:title, :string, null: false)
      add(:description, :string)
      add(:homepage, :string)
      add(:logo_url, :string)
      add(:ldap_dn, :string)

      timestamps()
    end
  end
end
