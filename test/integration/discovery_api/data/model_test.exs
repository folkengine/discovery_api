defmodule DiscoveryApi.Data.ModelTest do
  use ExUnit.Case
  use Divo, services: [:"ecto-postgres", :redis, :kafka, :zookeeper]
  use DiscoveryApi.DataCase
  alias DiscoveryApi.Test.Helper
  alias DiscoveryApi.Data.Model

  setup do
    Redix.command!(:redix, ["FLUSHALL"])
    :ok
  end

  test "Model saves data to Redis" do
    organization = Helper.save_org()
    model = Helper.sample_model(%{organization_id: organization.id})
    last_updated_date = DateTime.to_iso8601(DateTime.utc_now())

    Model.save(model)
    Redix.command!(:redix, ["SET", "discovery-api:stats:#{model.id}", Jason.encode!(model.completeness)])

    Redix.command!(:redix, [
      "SET",
      "forklift:last_insert_date:#{model.id}",
      last_updated_date
    ])

    actual = Model.get(model.id)

    assert actual.id == model.id
    assert actual.title == model.title
    assert actual.systemName == model.systemName
    assert actual.keywords == model.keywords

    assert actual.organizationDetails.id == organization.id
    assert actual.organizationDetails.orgName == organization.name
    assert actual.organizationDetails.orgTitle == organization.title
    assert actual.organizationDetails.description == organization.description
    assert actual.organizationDetails.logoUrl == organization.logo_url
    assert actual.organizationDetails.homepage == organization.homepage
    assert actual.organizationDetails.dn == organization.ldap_dn

    assert(actual.modifiedDate == model.modifiedDate)

    assert actual.fileTypes == model.fileTypes
    assert actual.description == model.description

    assert actual.completeness == model.completeness
    assert actual.lastUpdatedDate == last_updated_date
    assert Map.has_key?(actual, :downloads)
    assert Map.has_key?(actual, :queries)
  end

  test "Model saves data to Redis even without an org" do
    model = Helper.sample_model(%{organization_id: "I do not exist"})
    Model.save(model)

    actual = Model.get(model.id)

    assert actual.id == model.id
    assert actual.organizationDetails == %{}
  end

  test "get latest should return a single date" do
    last_updated_date = DateTime.to_iso8601(DateTime.utc_now())
    model_id = "123"

    Redix.command!(:redix, ["SET", "forklift:last_insert_date:#{model_id}", last_updated_date])

    actual_date = Model.get_last_updated_date(model_id)
    assert actual_date == last_updated_date
  end

  test "get should return nil when model does not exist" do
    actual_model = Model.get("123456")
    assert nil == actual_model
  end

  test "should return all of the models" do
    organization = Helper.save_org()
    model_id_1 = Faker.UUID.v4()
    model_id_2 = Faker.UUID.v4()
    model_ids = [model_id_1, model_id_2]

    model_ids
    |> Enum.map(fn id -> Helper.sample_model(%{id: id, organization_id: organization.id}) end)
    |> Enum.each(&Model.save/1)

    results = Model.get_all()

    assert Model.get(model_id_1) in results
    assert Model.get(model_id_2) in results
    assert 2 == length(results)
  end

  test "get all returns empty list if no keys exist" do
    assert [] == Model.get_all()
  end

  test "get all should return the models for all the ids specified" do
    organization = Helper.save_org()
    model1 = Helper.sample_model(%{organization_id: organization.id})
    model2 = Helper.sample_model(%{organization_id: organization.id})
    model3 = Helper.sample_model(%{organization_id: organization.id})

    [model1, model2, model3]
    |> Enum.each(fn model ->
      Model.save(model)
      Redix.command!(:redix, ["SET", "discovery-api:stats:#{model.id}", Jason.encode!(model.completeness)])
    end)

    results = Model.get_all([model1.id, model3.id])

    assert Model.get(model1.id) in results
    assert Model.get(model3.id) in results
    assert 2 == length(results)
  end

  defp struct_to_json(model) do
    model
    |> Map.from_struct()
    |> Jason.encode!()
  end
end
