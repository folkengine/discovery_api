defmodule DiscoveryApi.Schemas.UsersTest do
  use ExUnit.Case
  # , services: [:redis, :"ecto-postgres"] #run this without starting Brook?
  use Divo
  use DiscoveryApi.DataCase

  alias DiscoveryApi.Repo
  alias DiscoveryApi.Schemas.Organizations
  alias DiscoveryApi.Schemas.Users.Organization

  describe "create_or_update/2" do
    test "creates an organization" do
      org_id = "1"

      assert {:ok, saved} = Organizations.create_or_update(org_id, %{name: "a", title: "b"})

      actual = Repo.get(Organization, saved.id)
      assert %Organization{org_id: org_id, name: "a", title: "b"} = actual
    end

    test "updates an organization" do
      org_id = "2"

      assert {:ok, created} = Organizations.create_or_update(org_id, %{name: "a", title: "b"})
      assert {:ok, updated} = Organizations.create_or_update(org_id, %{name: "c", title: "d"})

      actual = Repo.get(Organization, created.id)
      assert %Organization{org_id: org_id, name: "c", title: "d"} = actual
    end
  end
end
