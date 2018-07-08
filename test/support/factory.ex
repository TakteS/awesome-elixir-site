defmodule AwesomeElixir.Factory do
  use ExMachina.Ecto, repo: AwesomeElixir.Repo
  alias AwesomeElixir.List.{Category, Lib}

  def category_factory() do
    %Category{
      name: sequence(:name, &"Category #{&1}"),
      description: sequence(:description, &"Some description #{&1}")
    }
  end

  def lib_factory() do
    %Lib{
      name: sequence(:name, &"lib_#{&1}"),
      description: sequence(:description, &"Some lib description #{&1}"),
      url: sequence(:description, &"https://github.com/some/repo#{&1}"),
      stars_count: sequence(:stars_count, &(&1 + 1)),
      last_commit_date: Timex.now(),
      category: build(:category)
    }
  end
end
