defmodule DealerReviews.Cli do
  @moduledoc """
  Documentation for `DealerReviews`.
  """

  @doc """
  Main method for the CLI which fetches reviews, scores them,
  and finally prints the top three. The first 5 pages are
  fetched.
  """
  def main(_args) do
    DealerReviews.Scraper.get_reviews_pages(1..5)
    |> Enum.sort_by(fn r -> DealerReviews.Analyzer.score_ratings(r) end, :desc)
    |> Enum.sort_by(fn r -> DealerReviews.Analyzer.score_employees(r) end, :desc)
    |> Enum.sort_by(fn r -> DealerReviews.Analyzer.score_body(r) end, :desc)
    |> Enum.take(3)
    |> Enum.map(fn r -> print_review((r)) end)
  end

  def print_review(review = %DealerReviews.Review{}) do
    IO.inspect(review)
  end
end
