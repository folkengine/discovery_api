defmodule DiscoveryApi.OrganizationUpdateTest do
  use ExUnit.Case
  use Divo
  import SmartCity.Event, only: [organization_update: 0]
  alias SmartCity.TestDataGenerator, as: TDG

  test "when an organization is updated then it is retrievable" do
    org =
      TDG.create_organization(%{
        id: "11234",
        orgName: "My_little_org",
        orgTitle: "Turtles all the way down"
      })

    Brook.Event.send(:discovery_api_brook, organization_update(), :test, org)

    result = get("http://localhost:4000/api/v1/organization/#{org.id}")

    IO.inspect(result, label: "result")

    assert result.status_code == 200
    new_org = Jason.decode!(result.body)

    assert new_org.id == org.id
    assert new_org.name == org.orgName
    assert new_org.title == org.orgTitle
  end

  defp get(url, headers \\ %{}) do
    HTTPoison.get!(url, headers)
    |> Map.from_struct()
  end
end
