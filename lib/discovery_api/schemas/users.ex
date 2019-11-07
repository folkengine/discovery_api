defmodule DiscoveryApi.Schemas.Users do
  @moduledoc """
  Interface for reading and writing the User schema.
  """
  alias DiscoveryApi.Repo
  alias DiscoveryApi.Schemas.Users.User
  alias DiscoveryApi.Schemas.Organizations.Organization

  def list_users do
    Repo.all(User)
  end

  def create(user_attrs) do
    %User{}
    |> User.changeset(user_attrs)
    |> Repo.insert()
  end

  def create_or_update(subject_id, changes \\ %{}) do
    case Repo.get_by(User, subject_id: subject_id) do
      nil -> %User{subject_id: subject_id}
      user -> user
    end
    |> User.changeset(changes)
    |> Repo.insert_or_update()
  end

  def get_user(subject_id) do
    case Repo.get_by(User, subject_id: subject_id) do
      nil -> {:error, "#{subject_id} not found"}
      user -> {:ok, user}
    end
  end

  def associate_with_organization(user_id, organization_id) do
    user = Repo.get(User, user_id)
    org = Repo.get(Organization, organization_id)

    user
    |> Repo.preload(:organizations)
    |> User.changeset_add_organization(org)
    |> Repo.update()
  end
end
