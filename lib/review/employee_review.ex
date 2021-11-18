defmodule DealerReviews.Review.EmployeeReview do
  # TODO: module docs clarify that rating here can be null
  defstruct name: "", rating: nil

  @type t :: %__MODULE__{
          name: String.t(),
          rating: integer
        }

  def create(name, rating) do
    %__MODULE__{
      name: name,
      rating: rating
    }
  end

  def create(name) do
    %__MODULE__{
      name: name
    }
  end
end
