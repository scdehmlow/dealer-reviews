defmodule AnalyzerTest do
  use ExUnit.Case
  # TODO: Add doctests
  # doctest DealerReviews.Analyzer
  alias DealerReviews.Review.Ratings
  alias DealerReviews.Review.EmployeeReview

  # ratings scoring
  @ratings_perfect Ratings.create(5, 5, 5, 5, true)
  @ratings_lowest Ratings.create(1, 1, 1, 1, false)
  @ratings_mixed Ratings.create(5, 4, 4, 5, true)

  test "perfect ratings scores a 5.0" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_perfect) == 5.0
  end

  test "lowest ratings scores a 1.0" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_lowest) == 1.0
  end

  test "mixed ratings score a 4.6" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_mixed) == 4.6
  end
end
