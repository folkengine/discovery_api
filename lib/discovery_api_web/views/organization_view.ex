defmodule DiscoveryApiWeb.OrganizationView do
  use DiscoveryApiWeb, :view

  def render("fetch_organization.json", %{org: %DiscoveryApi.Schemas.Organizations.Organization{} = org}) do
    %{
      org_id: org.org_id,
      name: org.name,
      title: org.title,
      description:  org.description,
      homepage: org.homepage,
      logo_url: org.logo_url
    }
  end
end
