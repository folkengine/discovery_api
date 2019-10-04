defmodule DiscoveryApiWeb.OrganizationControllerTest do
  use DiscoveryApiWeb.ConnCase
  use Placebo
  alias DiscoveryApi.Schemas.Organizations

  describe "organization controller" do
    test "fetches organization by org id", %{conn: conn} do
      ecto_response = %DiscoveryApi.Schemas.Organizations.Organization{
        id: 784,
        org_id: "1234",
        name: "Org Name",
        title: "Org Title",
        description: nil,
        homepage: nil,
        logo_url: nil,
        ldap_dn: "irrelevant"
      }

      expected = %{
        "org_id" => "1234",
        "name" => "Org Name",
        "title" => "Org Title",
        "description" => nil,
        "homepage" => nil,
        "logo_url" => nil
      }

      expect(Organizations.get_organization("1234"), return: ecto_response)
      actual = conn |> get("/api/v1/organization/1234") |> json_response(200)

      assert expected == actual
    end

    test "returns 404 if organization does not exist", %{conn: conn} do
      expect(Organizations.get_organization("1234"), return: nil)
      actual = conn |> get("/api/v1/organization/1234") |> json_response(404)

      assert %{"message" => "Not Found"} = actual
    end
  end
end
