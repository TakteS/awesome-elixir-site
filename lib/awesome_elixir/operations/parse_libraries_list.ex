defmodule AwesomeElixir.Operation.ParseLibrariesList do
  @moduledoc "Parses libraries list from awesome-elixir repo."

  @sorce_file_url Application.get_env(:awesome_elixir, :github)[:readme_url]

  @doc """
  Parses libraries list with categories and descriptions from awesome-elixir github repo.

  Return statement is:
      [
        %{
          category: "Category name",
          description: "Some description",
          libs: [
            %{name: "lib_name", url: "https://github.com/..", description: "Lib description"},
            ...
          ]
        },
        ...
      ]
  """
  @spec run(String.t()) :: {:ok, list} | {:error, term()}
  def run(file_url \\ @sorce_file_url) do
    case HTTPoison.get(file_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, parse(body)}
      error -> error
    end
  end

  defp parse(content) do
    content
    |> String.split("# Resources")
    |> Enum.at(0)
    |> String.split("##")
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.reduce(fn -> [] end, fn line, acc -> parse_block(line, acc) end)
    |> Enum.to_list()
  end

  defp parse_block("# Awesome Elixir" <> _, acc), do: acc

  defp parse_block(block, acc) do
    block = String.split(block, "\n")
    category = block |> Enum.at(0) |> String.trim()
    description = block |> Enum.at(1) |> String.replace("*", "", trim: true)
    libs = parse_libs(block)
    acc ++ [%{category: category, description: description, libs: libs}]
  end

  defp parse_libs(block) do
    block
    |> Flow.from_enumerable()
    |> Flow.filter_map(&repo?/1, &format_lib/1)
    |> Enum.to_list()
  end

  defp repo?(line), do: String.match?(line, ~r{^\* \[(.*?)\]\(https://github.com/(.*?)\) - (.*?)})

  defp format_lib(lib) do
    lib = lib |> String.replace("*", "", trim: true)
    [name_url, desc] = String.split(lib, " - ", parts: 2)
    [name] = Regex.run(~r/(?<=\[).+?(?=\])/, name_url)
    [url] = Regex.run(~r/(?<=\().+?(?=\))/, name_url)

    %{name: name, url: url, description: desc}
  end
end
