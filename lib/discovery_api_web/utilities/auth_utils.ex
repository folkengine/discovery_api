defmodule DiscoveryApiWeb.Utilities.AuthUtils do
  @moduledoc """
  Provides authentication and authorization helper methods
  """
  alias DiscoveryApi.Services.{PaddleService, PrestoService}
  alias DiscoveryApi.Schemas.Organizations
  alias DiscoveryApi.Data.Model

  def authorized_to_query?(statement, username) do
    with true <- PrestoService.is_select_statement?(statement),
         {:ok, affected_tables} <- PrestoService.get_affected_tables(statement),
         affected_models <- get_affected_models(affected_tables) do
      valid_tables?(affected_tables, affected_models) && can_access_models?(affected_models, username)
    else
      _ -> false
    end
  end

  defp get_affected_models(affected_tables) do
    all_models = Model.get_all()

    Enum.filter(all_models, &(String.downcase(&1.systemName) in affected_tables))
  end

  defp valid_tables?(affected_tables, affected_models) do
    affected_system_names =
      affected_models
      |> Enum.map(&Map.get(&1, :systemName))
      |> Enum.map(&String.downcase/1)

    MapSet.new(affected_tables) == MapSet.new(affected_system_names)
  end

  defp can_access_models?(affected_models, username) do
    Enum.all?(affected_models, &has_access?(&1, username))
  end

  def has_access?(%Model{private: false}, _username), do: true
  def has_access?(%Model{private: true}, nil), do: false

  def has_access?(%Model{private: true, organization_id: organization_id}, username) when not is_nil(organization_id) do
    case Organizations.get_organization(organization_id) do
      nil -> false
      org -> org.ldap_dn |> PaddleService.get_members() |> Enum.member?(username)
    end
  end

  def has_access?(_base, _case), do: false
end
