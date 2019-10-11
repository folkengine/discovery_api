defmodule DiscoveryApi.EventListenerTest do
  use ExUnit.Case
  use Placebo

  import DiscoveryApi
  import SmartCity.Event, only: [organization_update: 0, data_ingest_start: 0]

  alias SmartCity.TestDataGenerator, as: TDG
  alias DiscoveryApi.EventHandler
  alias DiscoveryApi.Schemas.Organizations

  describe "handle_event/1" do
    test "does not save non-organization to ecto" do
      org = TDG.create_organization(%{})
      allow(Organizations.create_or_update(any()), return: :dontcare)

      Brook.Test.with_event(instance(), fn ->
        EventHandler.handle_event(Brook.Event.new(type: data_ingest_start(), data: org, author: :author))
      end)

      assert_called(Organizations.create_or_update(any()), times(0))
    end

    test "should save organization to ecto" do
      org = TDG.create_organization(%{})
      allow(Organizations.create_or_update(any()), return: :dontcare)

      Brook.Test.with_event(instance(), fn ->
        EventHandler.handle_event(Brook.Event.new(type: organization_update(), data: org, author: :author))
      end)

      assert_called(Organizations.create_or_update(org))
    end
  end
end
