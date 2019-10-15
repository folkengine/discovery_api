defmodule DiscoveryApi.Data.DatasetEventListenerTest do
  use ExUnit.Case
  use Placebo
  alias DiscoveryApi.Data.{DatasetEventListener, Model, SystemNameCache}
  alias DiscoveryApi.Schemas.Organizations
  alias DiscoveryApi.TestDataGenerator, as: TDG
  alias DiscoveryApiWeb.Plugs.ResponseCache
  import Checkov

  describe "handle_dataset/1" do
    setup do
      allow ResponseCache.invalidate(), return: :ok
      allow DiscoveryApi.Search.Storage.index(any()), return: :ok
      allow DiscoveryApi.RecommendationEngine.save(any()), return: :ok

      :ok
    end

    test "should return :ok when successful" do
      dataset = TDG.create_dataset(%{id: "123"})
      organization = TDG.create_organization(%{id: dataset.technical.orgId})

      allow(Organizations.get_organization(dataset.technical.orgId), return: {:ok, organization})
      allow(Model.save(any()), return: {:ok, :success})
      allow Model.get(any()), return: :ok

      assert :ok == DatasetEventListener.handle_dataset(dataset)
    end

    @tag capture_log: true
    test "should return :ok and log when system cache put fails" do
      dataset = TDG.create_dataset(%{id: "123"})
      organization = TDG.create_organization(%{id: dataset.technical.orgId})

      allow(Organizations.get_organization(dataset.technical.orgId), return: {:ok, organization})
      allow(SystemNameCache.put(any()), return: {:error, :failure})

      assert :ok == DatasetEventListener.handle_dataset(dataset)
    end

    test "should invalidate the ResponseCache when dataset is received" do
      dataset = TDG.create_dataset(%{id: "123"})
      organization = TDG.create_organization(%{id: dataset.technical.orgId})

      allow(Organizations.get_organization(dataset.technical.orgId), return: {:ok, organization})
      allow(Model.save(any()), return: {:ok, :success})
      allow Model.get(any()), return: :ok

      assert :ok == DatasetEventListener.handle_dataset(dataset)
      assert_called ResponseCache.invalidate(), once()
    end

    @tag capture_log: true
    test "should return :ok and log when model save fails" do
      dataset = TDG.create_dataset(%{id: "123"})
      organization = TDG.create_organization(%{id: dataset.technical.orgId})

      allow(Organizations.get_organization(dataset.technical.orgId), return: {:ok, organization})
      allow(SystemNameCache.put(any()), return: {:ok, :cached})
      allow(Model.save(any()), return: {:error, :failure})

      assert :ok == DatasetEventListener.handle_dataset(dataset)
    end

    @tag capture_log: true
    test "should return :ok and log when model get fails" do
      dataset = TDG.create_dataset(%{id: "123"})

      allow(Model.get(any()),
        exec: fn _ -> raise %Postgrex.Error{message: "ERROR 42P01 (undefined_table) relation organizations does not exist"} end
      )

      allow(SystemNameCache.put(any()), return: {:ok, :cached})
      allow(Model.save(any()), return: {:ok, :success})

      assert :ok == DatasetEventListener.handle_dataset(dataset)
    end

    test "creates orgName/dataName mapping to dataset_id" do
      dataset = TDG.create_dataset(%{id: "123", technical: %{orgName: "orgName", dataName: "dataName"}})
      organization = TDG.create_organization(%{id: dataset.technical.orgId})

      allow Organizations.get_organization(organization.id), return: {:ok, organization}
      allow(Model.save(any()), return: {:ok, :success})
      allow Model.get(any()), return: :ok

      DatasetEventListener.handle_dataset(dataset)

      assert SystemNameCache.get(dataset.technical.orgName, dataset.technical.dataName) == "123"
    end

    test "indexes model for search" do
      dataset = TDG.create_dataset(%{id: "123"})
      allow(Model.save(any()), return: {:ok, :success})
      expected_model = DiscoveryApi.Data.Mapper.to_data_model(dataset)
      allow Model.get(any()), return: expected_model

      DatasetEventListener.handle_dataset(dataset)

      assert_called(DiscoveryApi.Search.Storage.index(expected_model))
    end

    data_test "sends dataset to recommendation engine" do
      dataset = TDG.create_dataset(dataset_map)
      organization = TDG.create_organization(%{id: dataset.technical.orgId})
      allow Organizations.get_organization(organization.id), return: {:ok, organization}
      allow(Model.save(any()), return: {:ok, :success})
      allow Model.get(any()), return: :ok

      DatasetEventListener.handle_dataset(dataset)

      assert called == called?(DiscoveryApi.RecommendationEngine.save(dataset))

      where([
        [:called, :dataset_map],
        [true, %{technical: %{private: false, schema: [%{name: "id", type: "string"}]}}],
        [false, %{technical: %{private: false, schema: []}}],
        [false, %{technical: %{private: true}}]
      ])
    end
  end
end
