# AwesomeElixir

Simple Phoenix application that parses Awesome Elixir list and saves data about categories and libraries to database.

Before running the application you should create `config/dev.secret.exs` with following content:

```
use Mix.Config

config :awesome_elixir, :github,
  client_id: "your_github_client_id",
  client_secret: "your_github_client_secret"
```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Note that database updates once per 24 hours after application was started, so if you want to populate database earlier, you can run following function in your `iex -S mix` shell:

```
AwesomeElixir.Service.UpdateList.parse()
```

Also you can update `application.ex`:

```
worker(AwesomeElixir.Service.Scheduler, [86_400_000])
```

by setting another scheduler's delay time (in milliseconds) instead of `86_400_000`.
