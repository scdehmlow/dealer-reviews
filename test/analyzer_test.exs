defmodule AnalyzerTest do
  use ExUnit.Case
  # TODO: Add doctests
  # doctest DealerReviews.Analyzer
  alias DealerReviews.Review.Ratings
  alias DealerReviews.Review.EmployeeReview

  # ratings scoring
  @ratings_perfect Ratings.create(5, 5, 5, 5, 5, true)
  @ratings_lowest Ratings.create(1, 1, 1, 1, 1, false)
  @ratings_mixed Ratings.create(5, 4, 4, 5, 4, true)
  @ratings_missing Ratings.create(5, nil, 5, 5, 5, true)
  @ratings_missing2 Ratings.create(5, nil, nil, 5, 5, true)
  @ratings_missing3 Ratings.create(nil, nil, nil, 5, 5, true)
  @ratings_missingAll Ratings.create(nil, nil, nil, nil, nil, true)

  test "perfect ratings scores a 5.0" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_perfect) == 5
  end

  test "lowest ratings scores a 1.0" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_lowest) == 1
  end

  test "mixed ratings score a 4.5" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_mixed) == 4.5
  end

  test "missing one rating should not hurt score" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_missing) == 5
  end

  test "missing two ratings should not hurt score" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_missing2) == 5
  end

  test "missing three ratings should hurt score" do
    refute DealerReviews.Analyzer.score_ratings(@ratings_missing3) == 5
  end

  test "missing all ratings should score a 1" do
    assert DealerReviews.Analyzer.score_ratings(@ratings_missingAll) == 1
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
