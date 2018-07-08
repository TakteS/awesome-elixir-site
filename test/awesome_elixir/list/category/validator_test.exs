defmodule AwesomeElixir.List.Category.ValidatorTest do
  use AwesomeElixir.DataCase
  alias AwesomeElixir.List.Category
  alias AwesomeElixir.List.Category.Validator
  import AwesomeElixir.Factory

  describe "changeset/2" do
    setup do
      required_fields = [:name, :description]
      {:ok, required_fields: required_fields}
    end

    test "validate required fields", %{required_fields: required_fields} do
      changeset = Validator.changeset(%Category{}, %{})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "when all fields are valid" do
      params = params_for(:category)
      assert Validator.changeset(%Category{}, params).valid?
    end

    test "validate name uniqueness" do
      category = insert(:category)

      assert {:error, changeset} =
               %Category{} |> Validator.changeset(%{name: category.name, description: "Something"}) |> Repo.insert()

      assert "has already been taken" in errors_on(changeset).name
    end
  end
end
