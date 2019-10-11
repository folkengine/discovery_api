defmodule DiscoveryApi.Data.DatasetEventListenerTest do
  use ExUnit.Case
  use Divo, services: [:redis, :"ecto-postgres", :kafka, :zookeeper]
  use DiscoveryApi.DataCase
  alias DiscoveryApi.Test.Helper
  alias DiscoveryApi.TestDataGenerator, as: TDG

  describe "handle_dataset/1" do
    test "indexes model for search" do
      organization = Helper.save_org(%{title: "my org title"})
      dataset = TDG.create_dataset(%{id: "123", business: %{description: "my description"}, technical: %{orgId: organization.id}})

      DiscoveryApi.Data.DatasetEventListener.handle_dataset(dataset)

      result = DiscoveryApi.Search.Storage.search("my org title")
      assert length(result) > 0
    end
  end
end
