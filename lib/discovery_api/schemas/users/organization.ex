defmodule DiscoveryApi.Schemas.Organizations.Organization do
  @moduledoc """
  Ecto schema respresentation of the Organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field(:org_id, :string)
    field(:name, :string)
    field(:title, :string)
    field(:description, :string)
    field(:homepage, :string)
    field(:logo_url, :string)
    field(:ldap_dn, :string)

    timestamps()
  end

  def changeset(organization, changes) do
    organization
    |> cast(changes, [:org_id, :name, :title, :description, :homepage, :logo_url, :ldap_dn])
    |> validate_required([:org_id, :name, :title])
    |> unique_constraint(:org_id)
  end
end
