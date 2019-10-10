defmodule DiscoveryApi.Data.DatasetEventListenerTest do
  use ExUnit.Case
  use Divo, services: [:redis, :"ecto-postgres", :kafka, :zookeeper]
  use DiscoveryApi.DataCase
  alias DiscoveryApi.Test.Helper
  alias DiscoveryApi.TestDataGenerator, as: TDG

  describe "handle_dataset/1" do
    test "indexes model for search" do
      organization = Helper.save_org(%{title: "my title"})
      dataset = TDG.create_dataset(%{id: "123", business: %{description: "my description"}, technical: %{orgId: organization.org_id}})

      # :ets.insert(DiscoveryApi.Search.Storage, {"foo", "bar"})

      # :ets.lookup(DiscoveryApi.Search.Storage, "foo")
      # |> IO.inspect(label: "FOO")

      # :ets.lookup(DiscoveryApi.Search.Storage, :_)
      # |> IO.inspect()

      DiscoveryApi.Data.DatasetEventListener.handle_dataset(dataset)

      assert_words_indexed?([dataset.business.description, organization.title], dataset.id)
    end
  end

  defp assert_words_indexed?(words, id) when is_list(words) do
    Patiently.wait_for!(
      fn ->
        Enum.all?(words, fn word ->
          :ets.lookup(DiscoveryApi.Search.Storage, word)
          |> IO.inspect(label: "EMPTY")

          IO.inspect(words, label: "looking for words")
          {word, id} in :ets.lookup(DiscoveryApi.Search.Storage, word)
        end)
      end,
      dwell: 100,
      max_tries: 200
    )
  end
end
