defmodule DealerReviewsTest do
  use ExUnit.Case
  doctest DealerReviews.Cli

  test "greets the world" do
    assert DealerReviews.Cli.hello() == :world
  end
end
