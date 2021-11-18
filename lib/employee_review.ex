defmodule DealerReviews.EmployeeReview do
  defstruct name: "", rating: 0

  @type t :: %__MODULE__{
    name: String.t,
    rating: integer
  }

  def create(name, rating) do
    %__MODULE__{
      name: name,
      rating: rating
    }
  end
end
