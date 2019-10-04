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

  def create_or_update(%SmartCity.Organization{} = org) do
    create_or_update(org.id, Map.from_struct(org))
  end

  def create_or_update(org_id, changes \\ %{}) do
    case Repo.get_by(Organization, org_id: org_id) do
      nil -> %Organization{org_id: org_id}
      organization -> organization
    end
    |> Organization.changeset(changes)
    |> Repo.insert_or_update()
  end

  def get_organization(org_id) do
    Organization
    |> Repo.get_by(org_id: org_id)
    |> create_org(org_id)
  end

  defp create_org(nil, _org_id), do: nil
  defp create_org(%Organization{} = repo_org, org_id) do
    {:ok, org} = repo_org
    |> Map.from_struct()
    |> Map.put(:id, org_id)
    |> SmartCity.Organization.new()

    org
  end

end
