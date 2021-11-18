defmodule DealerReviewsTest do
  use ExUnit.Case
  doctest DealerReviews.CLI

  test "greets the world" do
    assert DealerReviews.CLI.hello() == :world
  end
end
