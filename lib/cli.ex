defmodule DealerReviews.Cli do
  @moduledoc """
  Documentation for `DealerReviews`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DealerReviews.Cli.hello()
      :world

  """
  def hello do
    :world
  end
  def main(_args) do
    IO.puts("Hello world")
  end

  def print_review(review = %DealerReviews.Review{}) do
    IO.inspect(review)
  end
end
