defmodule DiscoveryApi.EventHandler do
  @moduledoc "Event Handler for event stream"
  use Brook.Event.Handler
  require Logger
  alias SmartCity.{Dataset, Organization}
  import SmartCity.Event, only: [organization_update: 0]



  def handle_event(%Brook.Event{} = event) do
    IO.inspect(event, label: "Got Event")
    :discard
  end

  # def handle_event(%Brook.Event{type: organization_update(), data: %Organization{} = data}) do
  #   {:merge, :org, data.id, data}
  # end
end
