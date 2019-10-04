defmodule DiscoveryApiWeb.MetadataView do
  use DiscoveryApiWeb, :view
  alias DiscoveryApi.Data.Model

  def accepted_formats() do
    ["json"]
  end

  def render("detail.json", %{model: model, org: org}) do
    translate_to_dataset_detail(model, org)
  end

  def render("fetch_schema.json", %{model: %{schema: schema}}) do
    format_schema(schema)
  end

  defp translate_to_dataset_detail(%Model{} = model, org) do
    %{
      name: model.name,
      title: model.title,
      description: model.description,
      id: model.id,
      keywords: model.keywords,
      sourceType: model.sourceType,
      sourceFormat: model.sourceFormat,
      sourceUrl: model.sourceUrl,
      lastUpdatedDate: model.lastUpdatedDate,
      contactName: model.contactName,
      contactEmail: model.contactEmail,
      license: model.license,
      rights: model.rights,
      homepage: model.homepage,
      spatial: model.spatial,
      temporal: model.temporal,
      publishFrequency: model.publishFrequency,
      conformsToUri: model.conformsToUri,
      describedByUrl: model.describedByUrl,
      describedByMimeType: model.describedByMimeType,
      parentDataset: model.parentDataset,
      issuedDate: model.issuedDate,
      language: model.language,
      referenceUrls: model.referenceUrls,
      categories: model.categories,
      modified: model.modifiedDate,
      downloads: model.downloads,
      queries: model.queries,
      accessLevel: model.accessLevel,
      completeness: model.completeness,
      schema: format_schema(model.schema),
      systemName: model.systemName
    } |> with_organization(org)
  end

  defp with_organization(map, nil), do: map

  defp with_organization(map, org) do
    Map.put(map, :organization, %{
      name: org.name,
      title: org.title,
      image: org.logo_url,
      description: org.description,
      homepage: org.homepage
    })
  end

  defp format_schema(schema_fields) do
    fields_to_return = [:name, :type, :description]
    Enum.map(schema_fields, &Map.take(&1, fields_to_return))
  end
end
