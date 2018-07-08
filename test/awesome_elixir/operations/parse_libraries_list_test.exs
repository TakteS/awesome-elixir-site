defmodule AwesomeElixir.Operation.ParseLibrariesListTest do
  use ExUnit.Case
  alias AwesomeElixir.Operation.ParseLibrariesList

  describe "run/0" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "parse readme.md when url is correct", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        fixture_readme = File.read!("test/fixtures/readme.md")
        Plug.Conn.resp(conn, 200, fixture_readme)
      end)

      assert {:ok, result} = ParseLibrariesList.run("http://localhost:#{bypass.port}/readme.md")

      # There are just 2 categories to parse. Check test/fixtures/readme.md for details.
      assert Enum.count(result) == 2

      assert [%{category: "Actors", description: "Libraries and tools for working with actors and such.", libs: libs1}] =
               Enum.filter(result, &(&1.category == "Actors"))

      assert Enum.count(libs1) == 2

      assert %{
               name: "dflow",
               url: "https://github.com/dalmatinerdb/dflow",
               description: "Pipelined flow processing engine."
             } in libs1

      assert %{
               name: "exactor",
               url: "https://github.com/sasa1977/exactor",
               description: "Helpers for easier implementation of actors in Elixir."
             } in libs1

      assert [
               %{
                 category: "Algorithms and Data structures",
                 description: "Libraries and implementations of algorithms and data structures.",
                 libs: libs2
               }
             ] = Enum.filter(result, &(&1.category == "Algorithms and Data structures"))

      # Note that actually there are 3 libs in this category in redme.md,
      # but third one is not github repo, so we just ignore it.
      assert Enum.count(libs2) == 2

      assert %{
               name: "array",
               url: "https://github.com/takscape/elixir-array",
               description: "An Elixir wrapper library for Erlang's array."
             } in libs2

      assert %{
               name: "aruspex",
               url: "https://github.com/dkendal/aruspex",
               description: "Aruspex is a configurable constraint solver, written purely in Elixir."
             } in libs2
    end

    test "return an error when something went wrong" do
      assert {:error, _reason} = ParseLibrariesList.run("https://fake-url-example.com")
    end
  end
end
