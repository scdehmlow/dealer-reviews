defmodule Mix.Tasks.Cli do
  @moduledoc "CLI task: mix help cli"
  use Mix.Task

  @shortdoc "Runs the CLI main method to print to console."
  def run(args) do
    DealerReviews.Cli.main(args)
  end
end
