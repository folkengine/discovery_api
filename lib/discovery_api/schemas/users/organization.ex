defmodule DiscoveryApi.Schemas.Organizations.Organization do
  @moduledoc """
  Ecto schema respresentation of the Organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field(:org_id, :string)
    field(:orgName, :string)
    field(:orgTitle, :string)
    field(:description, :string)
    field(:homepage, :string)
    field(:logoUrl, :string)

    timestamps()
  end

  @doc false
  def changeset(organization, changes) do
    organization
    |> cast(changes, [:org_id, :orgName, :orgTitle, :description, :homepage, :logoUrl])

    # |> validate_required([:org_id])
    # |> unique_constraint(:org_id)
  end
end
