defmodule DealerReviews.Review.Ratings do
  defstruct customer_service: nil,
            friendliness: nil,
            pricing: nil,
            overall: nil,
            quality: nil,
            recommend: false

  @typedoc """
  Contains the multiple categories of ratings.
  They are optional and are nil when not specified.
  Ratings are integer values from 1-5.
  """
  @type t :: %__MODULE__{
          customer_service: integer,
          friendliness: integer,
          pricing: integer,
          overall: integer,
          quality: integer,
          recommend: bool
        }

  def create(customer_service, friendliness, pricing, overall, quality, recommend) do
    %__MODULE__{
      customer_service: customer_service,
      friendliness: friendliness,
      pricing: pricing,
      overall: overall,
      quality: quality,
      recommend: recommend
    }
  end
end
