defmodule DiscoveryApi.Schemas.OrganizationsTest do
  use ExUnit.Case
  use Divo, services: [:redis, :"ecto-postgres", :kafka, :zookeeper]
  use DiscoveryApi.DataCase

  alias DiscoveryApi.Repo
  alias DiscoveryApi.Schemas.Organizations
  alias DiscoveryApi.Schemas.Organizations.Organization

  import Checkov

  @org_id "12343532"

  setup do
    Repo.delete_all(Organization)

    :ok
  end

  describe "create_or_update/2" do
    test "creates an organization" do
      org = %{
        org_id: @org_id,
        name: "a",
        title: "b",
        description: "description",
        homepage: "homepage",
        logo_url: "logo",
        ldap_dn: "cn=this_is_a_group,ou=Group"
      }

      assert {:ok, saved} = Organizations.create_or_update(@org_id, org)

      actual = Organizations.get_organization(@org_id)
      assert !is_nil(actual)
      assert org.org_id == actual.org_id
      assert org.name == actual.name
      assert org.title == actual.title
      assert org.description == actual.description
      assert org.homepage == actual.homepage
      assert org.logo_url == actual.logo_url
      assert org.ldap_dn == actual.ldap_dn
    end

    test "updates an organization" do
      assert {:ok, created} = Organizations.create_or_update(@org_id, %{name: "a", title: "b", ldap_dn: "ldap"})
      assert {:ok, updated} = Organizations.create_or_update(@org_id, %{name: "c", title: "d", ldap_dn: "ldap"})

      actual = Organizations.get_organization(@org_id)
      assert !is_nil(actual)
      assert "c" == actual.name
      assert "d" == actual.title
    end

    data_test "returns an error when required field: `#{required_field}` is not provided" do
      organization_map =
        %{name: "name", title: "title", ldap_dn: "ldap"}
        |> Map.delete(required_field)

      assert {:error, changeset} = Organizations.create_or_update(@org_id, organization_map)

      assert changeset.errors |> Keyword.has_key?(required_field)
      assert is_nil(Organizations.get_organization(@org_id))

      where([
        [:required_field],
        [:name],
        [:title],
        [:ldap_dn]
      ])
    end
  end

  describe "create_or_update/1" do
    test "creates an organization from a smart city struct" do
      org = %SmartCity.Organization{
        id: @org_id,
        orgName: "a",
        orgTitle: "b",
        description: "description",
        homepage: "homepage",
        logoUrl: "logo",
        dn: "cn=this_is_a_group,ou=Group"
      }

      assert {:ok, saved} = Organizations.create_or_update(org)

      actual = Organizations.get_organization(@org_id)
      assert !is_nil(actual)
      assert org.id == actual.org_id
      assert org.orgName == actual.name
      assert org.orgTitle == actual.title
      assert org.description == actual.description
      assert org.homepage == actual.homepage
      assert org.logoUrl == actual.logo_url
      assert org.dn == actual.ldap_dn
    end
  end

  describe "get_organization/1" do
    test "returns a nil when not found" do
      assert is_nil(Organizations.get_organization("i do not exist"))
    end
  end
end
