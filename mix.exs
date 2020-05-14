defmodule XCUID.MixProject do
  use Mix.Project

  def project do
    [
      app: :xcuid,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/rbao/xcuid",
      description: """
        Collision-resistant ids optimized for horizontal scaling and
        binary search lookup performance, in Elixir.
      """,
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {XCUID.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev}
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rbao/xcuid"}
    ]
  end
end
