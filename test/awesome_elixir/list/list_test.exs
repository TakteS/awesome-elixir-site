defmodule AwesomeElixir.ListTest do
  use AwesomeElixir.DataCase
  alias AwesomeElixir.List
  alias AwesomeElixir.List.{Category, Lib}
  import AwesomeElixir.Factory

  describe "delegations" do
    test "create_or_update_lib/1 presence" do
      assert 1 == List.__info__(:functions) |> Keyword.fetch!(:create_or_update_lib)
    end
  end

  describe "create_or_update_category/1" do
    test "crates new category when params are valid" do
      params = %{"name" => "Name", "description" => "Description"}
      assert {:ok, %Category{name: "Name", description: "Description"}} = List.create_or_update_category(params)
    end

    test "update category when already exists" do
      category = insert(:category)
      id = category.id
      name = category.name
      params = %{"name" => category.name, "description" => "New description"}

      assert {:ok, %Category{id: ^id, name: ^name, description: "New description"}} =
               List.create_or_update_category(params)
    end

    test "with ivalid params" do
      assert {:error, %Ecto.Changeset{valid?: false}} = List.create_or_update_category(%{})
      assert [] = Repo.all(Category)
    end
  end

  describe "find_categories_with_libs/1" do
    setup do
      [cat1, cat2, _cat3] = insert_list(3, :category)
      lib1 = insert(:lib, category: cat1, stars_count: 100)
      lib2 = insert(:lib, category: cat2, stars_count: 50)

      {:ok, cat1: cat1, cat2: cat2, lib1: lib1, lib2: lib2}
    end

    test "finds categiries with related libraries", %{
      cat1: %{id: cat1_id},
      cat2: %{id: cat2_id},
      lib1: %{id: lib1_id},
      lib2: %{id: lib2_id}
    } do
      # Note that categories without libs are not selected
      assert [%Category{id: ^cat1_id, libs: [%Lib{id: ^lib1_id}]}, %Category{id: ^cat2_id, libs: [%Lib{id: ^lib2_id}]}] =
               List.find_categories_with_libs()
    end

    test "filter by stars count", %{cat1: %{id: cat1_id}, lib1: %{id: lib1_id}} do
      assert [%Category{id: ^cat1_id, libs: [%Lib{id: ^lib1_id}]}] = List.find_categories_with_libs(100)
    end
  end
end
