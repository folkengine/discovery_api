defmodule DiscoveryApi.Schemas.OrganizationsTest do
  use ExUnit.Case
  use Divo
  # use Divo, services: [:redis, :"ecto-postgres"]
  use DiscoveryApi.DataCase

  alias DiscoveryApi.Repo
  alias DiscoveryApi.Schemas.Organizations
  alias DiscoveryApi.Schemas.Organizations.Organization

  describe "create_or_update/2" do
    test "creates an organization" do
      org_id = "1"

      org = %Organization{
        org_id: org_id,
        orgName: "a",
        orgTitle: "b",
        description: "description",
        homepage: "homepage",
        logoUrl: "logo"
      }

      assert {:ok, saved} = Organizations.create_or_update(org_id, Map.from_struct(org))

      actual = Repo.get(Organization, saved.id)
      assert org.org_id == actual.org_id
      assert org.orgName == actual.orgName
      assert org.orgTitle == actual.orgTitle
      assert org.description == actual.description
      assert org.homepage == actual.homepage
      assert org.logoUrl == actual.logoUrl
    end

    test "updates an organization" do
      org_id = "2"

      assert {:ok, created} = Organizations.create_or_update(org_id, %{orgName: "a", orgTitle: "b"})
      assert {:ok, updated} = Organizations.create_or_update(org_id, %{orgName: "c", orgTitle: "d"})

      actual = Repo.get(Organization, created.id)
      assert org_id == actual.org_id
      assert "c" == actual.orgName
      assert "d" == actual.orgTitle
    end

    # test "returns an error when org id is not provided for a new org" do
    #   assert {:error, changeset} = Organizations.create_or_update(nil, %{name: "a", title: "b"})

    #   assert changeset.errors |> Keyword.has_key?(:org_id)
    #   assert nil == Repo.get_by(User, org_id: nil)
    # end
  end

  describe "create_or_update/1" do
    test "creates an organization from a smart city struct" do
      org_id = "1"

      org = %SmartCity.Organization{
        id: org_id,
        orgName: "a",
        orgTitle: "b",
        description: "description",
        homepage: "homepage",
        logoUrl: "logo"
      }

      assert {:ok, saved} = Organizations.create_or_update(org)

      assert org == Organizations.get_organization(org_id)
    end
  end

  describe "get_organization/1" do
    test "returns a nil when not found" do
      assert is_nil(Organizations.get_organization("i do not exist"))
    end
  end

end
