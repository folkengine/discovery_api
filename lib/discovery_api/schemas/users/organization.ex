defmodule DiscoveryApi.Schemas.Users.Organization do
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

    timestamps()
  end

  @doc false
  def changeset(organization, changes) do
    organization
    |> cast(changes, [:org_id, :name, :title])

    # |> validate_required([:org_id])
    # |> unique_constraint(:org_id)
  end
end
