defmodule DiscoveryApi.Data.HostedFileTest do
  use ExUnit.Case
  use Divo, services: [:redis, :presto, :metastore, :postgres, :minio, :"ecto-postgres", :kafka, :zookeeper]
  use DiscoveryApi.DataCase

  alias SmartCity.Registry.Dataset
  alias DiscoveryApi.Test.Helper
  alias DiscoveryApi.TestDataGenerator, as: TDG

  require Logger

  @expected_checksum :crypto.hash(:md5, File.read!("test/integration/test-file.test")) |> Base.encode16()

  @dataset_id "123-123"
  @dataset_name "test_id"

  setup_all do
    organization = Helper.save_org(%{name: "test_org"})

    %{organization: organization}
  end

  setup do
    Application.put_env(:ex_aws, :access_key_id, "testing_access_key")
    Application.put_env(:ex_aws, :secret_access_key, "testing_secret_key")

    Redix.command!(:redix, ["FLUSHALL"])

    "test/integration/test-file.test"
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(Application.get_env(:discovery_api, :hosted_bucket), "test_org/#{@dataset_name}.geojson")
    |> ExAws.request!()

    "test/integration/test-file.test"
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(Application.get_env(:discovery_api, :hosted_bucket), "test_org/#{@dataset_name}.tgz")
    |> ExAws.request!()

    %{}
  end

  @moduletag capture_log: true
  test "downloads a file with the geojson extension", %{organization: organization} do
    dataset_id = @dataset_id
    dataset_name = @dataset_name
    system_name = "not_saved"

    dataset =
      TDG.create_dataset(%{
        id: dataset_id,
        technical: %{
          systemName: system_name,
          orgId: organization.org_id,
          sourceType: "host",
          dataName: dataset_name,
          orgName: organization.name
        }
      })

    Dataset.write(dataset)

    eventually(fn -> download_and_checksum(organization.name, dataset.technical.dataName, "application/geo+json") == @expected_checksum end)
  end

  @moduletag capture_log: true
  test "downloads a file with a custom mime type", %{organization: organization} do
    dataset_id = @dataset_id
    dataset_name = @dataset_name
    system_name = "not_saved"

    dataset =
      TDG.create_dataset(%{
        id: dataset_id,
        technical: %{
          systemName: system_name,
          orgId: organization.org_id,
          sourceType: "host",
          dataName: dataset_name,
          orgName: organization.name
        }
      })

    Dataset.write(dataset)

    eventually(fn -> download_and_checksum(organization.name, dataset.technical.dataName, "application/shapefile") == @expected_checksum end)
  end

  @moduletag capture_log: true
  test "downloads a file with a explicit format", %{organization: organization} do
    dataset_id = @dataset_id
    dataset_name = @dataset_name
    system_name = "not_saved"

    dataset =
      TDG.create_dataset(%{
        id: dataset_id,
        technical: %{
          systemName: system_name,
          orgId: organization.org_id,
          sourceType: "host",
          dataName: dataset_name,
          orgName: organization.name
        }
      })

    Dataset.write(dataset)

    eventually(fn -> download_and_checksum_with_format(organization.name, dataset.technical.dataName, "tgz") == @expected_checksum end)
  end

  @moduletag capture_log: true
  test "unacceptable response if file with that type does not exist", %{organization: organization} do
    dataset_id = @dataset_id
    dataset_name = @dataset_name
    system_name = "not_saved"

    dataset =
      TDG.create_dataset(%{
        id: dataset_id,
        technical: %{
          systemName: system_name,
          orgId: organization.org_id,
          sourceType: "host",
          dataName: dataset_name,
          orgName: organization.name
        }
      })

    Dataset.write(dataset)

    eventually(fn ->
      %{status_code: status_code, body: _body} =
        "http://localhost:4000/api/v1/organization/#{organization.name}/dataset/#{dataset.technical.dataName}/download"
        |> HTTPoison.get!([{"Accept", "audio/ATRAC3"}])
        |> Map.from_struct()

      status_code == 406
    end)
  end

  defp download_and_checksum(org_name, dataset_name, accept_header) do
    body =
      "http://localhost:4000/api/v1/organization/#{org_name}/dataset/#{dataset_name}/download"
      |> HTTPoison.get!([{"Accept", "#{accept_header}"}])
      |> Map.get(:body)

    if is_binary(body) do
      Logger.info("Got something: #{inspect(body)}")
      checksum = :crypto.hash(:md5, body) |> Base.encode16()

      checksum
    else
      Logger.info("Got something unexpected: #{body}")
      false
    end
  end

  defp download_and_checksum_with_format(org_name, dataset_name, format) do
    body =
      "http://localhost:4000/api/v1/organization/#{org_name}/dataset/#{dataset_name}/download?_format=#{format}"
      |> HTTPoison.get!()
      |> Map.get(:body)

    if is_binary(body) do
      Logger.info("Got something: #{inspect(body)}")
      checksum = :crypto.hash(:md5, body) |> Base.encode16()

      checksum
    else
      Logger.info("Got something unexpected: #{body}")
      false
    end
  end
end
