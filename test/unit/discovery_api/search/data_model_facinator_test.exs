defmodule DiscoveryApi.Search.DataModelFacinatorTest do
  use ExUnit.Case
  use Placebo

  alias DiscoveryApi.Search.DataModelFacinator
  alias DiscoveryApi.Test.Helper
  alias DiscoveryApi.Schemas.Organizations

  describe "extract_facets/2" do
    setup do
      {model1, _} = create_model(%{title: "Ben's head canon", keywords: ["my cool keywords", "another keywords"]}, %{title: "OrgA"})

      model2 =
        Helper.sample_model(%{
          title: "Ben's Caniac Combo",
          keywords: ["my cool keywords", "another keywords"],
          organization_id: model1.organization_id
        })

      {model3, _} = create_model(%{title: "Jarred's irrational attachment to natorism's", keywords: []}, %{title: "OrgB"})
      {model4, _} = create_model(%{title: "hi its erin", keywords: ["uncool keywords"]}, %{title: ""})

      {:ok,
       %{
         models: [
           model1,
           model2,
           model3,
           model4
         ]
       }}
    end

    #  Helper.sample_model(%{
    #    title: "Ben's head canon",
    #    organization: "OrgA",
    #    keywords: ["my cool keywords", "another keywords"]
    #  }),
    #  Helper.sample_model(%{
    #    title: "Ben's Caniac Combo",
    #    organization: "OrgA",
    #    keywords: []
    #  }),
    #  Helper.sample_model(%{
    #    title: "Jarred's irrational attachment to natorism's",
    #    organization: "OrgB",
    #    keywords: ["my cool keywords"]
    #  }),
    #  Helper.sample_model(%{
    #    title: "hi its erin",
    #    organization: "",
    #    keywords: ["uncool keywords"]
    #  })
    #  ]

    test "given a list of models, it extracts unique facets and their counts", %{models: models} do
      assert DataModelFacinator.extract_facets(models, %{}, []) == %{
               organization: [
                 %{name: "", count: 1},
                 %{name: "OrgA", count: 2},
                 %{name: "OrgB", count: 1}
               ],
               keywords: [
                 %{name: "another keywords", count: 1},
                 %{name: "my cool keywords", count: 2},
                 %{name: "uncool keywords", count: 1}
               ]
             }
    end

    test "given an empty list of models and empty list of selected facets should return empty lists" do
      assert DataModelFacinator.extract_facets([], %{}, []) == %{
               organization: [],
               keywords: []
             }
    end

    test "given an empty list of models and a non-empty list of selected facets should return selected facets with 0 counts" do
      assert DataModelFacinator.extract_facets([], %{organization: ["8-Corner"], keywords: ["turbo", "crust"]}, []) == %{
               organization: [%{name: "8-Corner", count: 0}],
               keywords: [%{name: "turbo", count: 0}, %{name: "crust", count: 0}]
             }
    end
  end

  defp create_model(model_map \\ %{}, org_map \\ %{}) do
    model = Helper.sample_model(model_map)
    org = org_map |> Map.put(:org_id, model.organization_id) |> Helper.sample_org()
    allow(Organizations.get_organization(org.org_id), return: org)
    {model, org}
  end
end
