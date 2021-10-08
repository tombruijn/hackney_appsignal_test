defmodule Appsignal.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :test,
      version: @version,
      name: "AppSignal",
      description: description(),
      package: package(),
      homepage_url: "https://github.com/tombruijn/hackney_appsignal_test",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
    ]
  end

  defp description do
    "Hackney test app"
  end

  defp package do
    %{
      files: [
      ],
      maintainers: ["Tom de Bruijn"],
      licenses: ["MIT"]
    }
  end

  defp elixirc_paths(env) do
    case test?(env) do
      true -> ["lib", "test/support"]
      false -> ["lib"]
    end
  end

  defp test?(:test), do: true
  defp test?(_), do: false

  defp deps do
    [
      {:hackney, "~> 1.6"},
    ]
  end
end
