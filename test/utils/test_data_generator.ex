defmodule DiscoveryApi.TestDataGenerator do
  def create_dataset(term) do
    term
    |> SmartCity.TestDataGenerator.create_dataset()
    |> to_registry_module()
  end

  def create_organization(term) do
    term
    |> SmartCity.TestDataGenerator.create_organization()
    |> to_registry_module()
  end

  defp to_registry_module(%SmartCity.Dataset{} = dataset) do
    map = Map.from_struct(dataset)
    map = Map.put(map, :business, Map.from_struct(Map.get(map, :business)))
    map = Map.put(map, :technical, Map.from_struct(Map.get(map, :technical)))

    {:ok, data} = SmartCity.Registry.Dataset.new(map)

    data
  end

  defp to_registry_module(%SmartCity.Organization{} = organization) do
    {:ok, org} =
      organization
      |> Map.from_struct()
      |> SmartCity.Registry.Organization.new()

    org
  end
end
