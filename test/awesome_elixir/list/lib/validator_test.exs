defmodule AwesomeElixir.List.Lib.ValidatorTest do
  use AwesomeElixir.DataCase
  alias AwesomeElixir.List.Lib
  alias AwesomeElixir.List.Lib.Validator
  import AwesomeElixir.Factory

  describe "changeset/2" do
    setup do
      required_fields = [:name, :description, :url, :stars_count, :last_commit_date, :category_id]
      category_id = insert(:category).id

      {:ok, required_fields: required_fields, category_id: category_id}
    end

    test "validate required fields", %{required_fields: required_fields} do
      changeset = Validator.changeset(%Lib{}, %{})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "when all fields are valid", %{category_id: category_id} do
      params = params_for(:lib, category_id: category_id)
      assert Validator.changeset(%Lib{}, params).valid?
    end

    test "validate name uniqueness", %{category_id: category_id} do
      lib = insert(:lib)
      params = params_for(:lib, name: lib.name, category_id: category_id)
      assert {:error, changeset} = %Lib{} |> Validator.changeset(params) |> Repo.insert()
      assert "has already been taken" in errors_on(changeset).name
    end

    test "validate url uniqueness", %{category_id: category_id} do
      lib = insert(:lib)
      params = params_for(:lib, url: lib.url, category_id: category_id)
      assert {:error, changeset} = %Lib{} |> Validator.changeset(params) |> Repo.insert()
      assert "has already been taken" in errors_on(changeset).url
    end
  end
end
