defmodule DiscoveryApi.Schemas.Organizations do
  @moduledoc """
  Interface for reading and writing the Organization schema.
  """
  alias DiscoveryApi.Repo
  alias DiscoveryApi.Schemas.Organizations.Organization

  def list_organizations do
    # Repo.all(User)
  end

  # Why is this needed?
  # def create(organization_attrs) do
  # %User{}
  # |> User.changeset(user_attrs)
  # |> Repo.insert()
  # end

  def create_or_update(org_id, changes \\ %{}) do
    case Repo.get_by(Organization, org_id: org_id) do
      nil -> %Organization{org_id: org_id}
      organization -> organization
    end
    |> Organization.changeset(changes)
    |> Repo.insert_or_update()
  end

  def get_organization(org_id), do: Repo.get_by(Organization, org_id: org_id)
end
