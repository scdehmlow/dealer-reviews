defmodule DealerReviews.Review.Ratings do
  defstruct customer_service: 0, friendliness: 0, pricing: 0, overall: 0, quality: 0, recommend: false

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
