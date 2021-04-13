import Config

config :company, Company.Repo,
  database: "company_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :company, ecto_repos: [Company.Repo]
