defmodule DiscoveryApi.Schemas.OrganizationsTest do
  use ExUnit.Case
  use Divo, services: [:redis, :"ecto-postgres", :kafka, :zookeeper]
  use DiscoveryApi.DataCase

  alias DiscoveryApi.Repo
  alias DiscoveryApi.Schemas.Organizations
  alias DiscoveryApi.Schemas.Organizations.Organization

  describe "create_or_update/2" do
    test "creates an organization" do
      org_id = "1"

      org = %{
        org_id: org_id,
        name: "a",
        title: "b",
        description: "description",
        homepage: "homepage",
        logo_url: "logo"
      }

      assert {:ok, saved} = Organizations.create_or_update(org_id, org)

      actual = Organizations.get_organization(org_id)
      assert !is_nil(actual)
      assert org.org_id == actual.org_id
      assert org.name == actual.name
      assert org.title == actual.title
      assert org.description == actual.description
      assert org.homepage == actual.homepage
      assert org.logo_url == actual.logo_url
    end

    test "updates an organization" do
      org_id = "2"

      assert {:ok, created} = Organizations.create_or_update(org_id, %{name: "a", title: "b"})
      assert {:ok, updated} = Organizations.create_or_update(org_id, %{name: "c", title: "d"})

      actual = Organizations.get_organization(org_id)
      assert !is_nil(actual)
      assert "c" == actual.name
      assert "d" == actual.title
    end

    # test "returns an error when org id is not provided for a new org" do
    #   assert {:error, changeset} = Organizations.create_or_update(nil, %{name: "a", title: "b"})

    #   assert changeset.errors |> Keyword.has_key?(:org_id)
    #   assert nil == Repo.get_by(User, org_id: nil)
    # end
  end

  describe "create_or_update/1" do
    test "creates an organization from a smart city struct" do
      org_id = "3"

      org = %SmartCity.Organization{
        id: org_id,
        orgName: "a",
        orgTitle: "b",
        description: "description",
        homepage: "homepage",
        logoUrl: "logo"
      }

      assert {:ok, saved} = Organizations.create_or_update(org)

      actual = Organizations.get_organization(org_id)
      assert !is_nil(actual)
      assert org.id == actual.org_id
      assert org.orgName == actual.name
      assert org.orgTitle == actual.title
      assert org.description == actual.description
      assert org.homepage == actual.homepage
      assert org.logoUrl == actual.logo_url

    end
  end

  describe "get_organization/1" do
    test "returns a nil when not found" do
      assert is_nil(Organizations.get_organization("i do not exist"))
    end
  end

end
