defmodule DiscoveryApi.Application do
  @moduledoc """
  Discovery API serves as middleware between our metadata store and our Data Discovery UI.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    DiscoveryApi.MetricsExporter.setup()
    DiscoveryApiWeb.Endpoint.Instrumenter.setup()

    get_s3_credentials()

    children =
      [
        DiscoveryApi.Data.SystemNameCache,
        DiscoveryApi.Search.Storage,
        DiscoveryApiWeb.Plugs.ResponseCache,
        redis(),
        ecto_repo(),
        {Brook, Application.get_env(:discovery_api, :brook)},
        registry_pubsub(),
        supervisor(DiscoveryApiWeb.Endpoint, []),
        DiscoveryApi.Quantum.Scheduler
      ]
      |> List.flatten()

    opts = [strategy: :one_for_one, name: DiscoveryApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DiscoveryApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp registry_pubsub() do
    Application.get_env(:smart_city_registry, :redis)
    |> case do
      nil -> []
      _ -> {SmartCity.Registry.Subscriber, [message_handler: DiscoveryApi.Data.DatasetEventListener]}
    end
  end

  defp redis do
    Application.get_env(:redix, :args)
    |> case do
      nil -> []
      redix_args -> {Redix, Keyword.put(redix_args, :name, :redix)}
    end
  end

  defp get_s3_credentials do
    Application.get_env(:discovery_api, :secrets_endpoint)
    |> case do
      nil -> nil
      _ -> DiscoveryApi.S3.CredentialRetriever.retrieve()
    end
  end

  defp ecto_repo do
    Application.get_env(:discovery_api, DiscoveryApi.Repo)
    |> case do
      nil -> []
      _ -> Supervisor.Spec.worker(DiscoveryApi.Repo, [])
    end
  end
end
