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

  # employees scoring
  @employees_perfect [
    EmployeeReview.create("E1", 5),
    EmployeeReview.create("E2", 5),
    EmployeeReview.create("E3", 5),
    EmployeeReview.create("E4", 5),
    EmployeeReview.create("E5", 5)
  ]
  @employees_lowest []
  @employees_mixed [
    EmployeeReview.create("E1"),
    EmployeeReview.create("E2", 3),
    EmployeeReview.create("E2", 5)
  ]

  test "perfect employees scores a 5.0" do
    assert DealerReviews.Analyzer.score_employees(@employees_perfect) == 5.0
  end

  test "lowest employees scores a 1.0" do
    assert DealerReviews.Analyzer.score_employees(@employees_lowest) == 1.0
  end

  # average employee ratings then average in the number of employees under 5 multiplied by the weighting factor of 2
  test "mixed employees scores a 3.5" do
    assert DealerReviews.Analyzer.score_employees(@employees_mixed) == 3.5
  end
end
