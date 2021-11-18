defmodule DealerReviews.Analyzer do
  @moduledoc """

  """
  def score_ratings(ratings = %DealerReviews.Review.Ratings{}) do
    %DealerReviews.Review.Ratings{
      customer_service: customer_service,
      friendliness: friendliness,
      overall: overall,
      pricing: pricing,
      recommend: recommend
    } = ratings

    # convert the recommend status to a numerical value
    recommend_value =
      case recommend do
        # highest rating is a 5
        true -> 5
        # lowest rating is a 1
        false -> 1
      end

    (customer_service + friendliness + overall + pricing + recommend_value) / 5
  end
end
