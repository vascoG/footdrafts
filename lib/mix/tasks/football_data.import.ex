defmodule Mix.Tasks.FootballData.Import do
  use Mix.Task

  @requirements ["app.start"]
  @shortdoc "Imports football data for a competition code"

  @impl Mix.Task
  def run([competition_code]) do
    result = FootDrafts.Football.Import.import_competition!(competition_code)

    Mix.shell().info(
      "Imported #{result.competition.name} (#{result.competition.external_id}): #{result.clubs} clubs, #{result.players} players"
    )
  end

  def run(_) do
    Mix.raise("usage: mix football_data.import <competition_code>")
  end
end
