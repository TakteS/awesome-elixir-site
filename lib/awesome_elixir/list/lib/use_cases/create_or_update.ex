defmodule AwesomeElixir.List.Lib.UseCase.CreateOrUpdate do
  @moduledoc "Create or update library."

  alias AwesomeElixir.Repo
  alias AwesomeElixir.List.Lib
  alias AwesomeElixir.List.Lib.Validator

  @doc """
  Updates existing library or creates new one.
  Function calls github API for take repo's stars count and last commit date.
  """
  @spec run(map) :: {:ok, %Lib{}} | {:error, Ecto.Changeset.t()} | {:error, :repo_not_exists}
  def run(lib_params) do
    oauth = oauth_settings()
    api_url = Application.get_env(:awesome_elixir, :github)[:api_url]
    repo_url = String.replace_leading(lib_params.url, "https://github.com", "#{api_url}/repos")
    repo = HTTPoison.get!(repo_url <> oauth).body |> Poison.decode!()

    if repo["id"] do
      stars_count = repo["stargazers_count"]
      last_commit_date = get_last_commit_date(repo_url, oauth)
      params = Map.merge(lib_params, %{stars_count: stars_count, last_commit_date: last_commit_date})

      Lib |> Repo.get_by(name: lib_params.name) |> create_or_update_lib(params)
    else
      {:error, :repo_not_exists}
    end
  end

  defp create_or_update_lib(nil, params), do: %Lib{} |> Validator.changeset(params) |> Repo.insert()

  defp create_or_update_lib(lib, params), do: lib |> Validator.changeset(params) |> Repo.update()

  defp get_last_commit_date(repo_url, oauth) do
    commits = HTTPoison.get!(repo_url <> "/commits" <> oauth).body |> Poison.decode!()
    if is_list(commits), do: List.first(commits)["commit"]["author"]["date"]
  end

  defp oauth_settings() do
    github_settings = Application.get_env(:awesome_elixir, :github)
    "?client_id=#{github_settings[:client_id]}&client_secret=#{github_settings[:client_secret]}"
  end
end
