defmodule DealerReviews.Review do
  defstruct title: "",
            customer: "",
            date: Date.utc_today(),
            overall_rating: 0,
            visit_reason: "",
            body: "",
            ratings: DealerReviews.Review.Ratings,
            employees: []

  @type t :: %__MODULE__{
          title: String.t(),
          customer: String.t(),
          date: Date.t(),
          overall_rating: float,
          visit_reason: String.t(),
          body: String.t(),
          ratings: DealerReviews.Review.Ratings.t(),
          employees: list(DealerReviews.Review.EmployeeReview.t())
        }

  @spec create(
          String.t(),
          String.t(),
          Date.t(),
          integer,
          String.t(),
          String.t(),
          DealerReviews.Review.Ratings.t(),
          list(DealerReviews.Review.EmployeeReview.t())
        ) :: DealerReviews.Review.t()
  def create(title, customer, date, overall_rating, visit_reason, body, ratings, employees) do
    %__MODULE__{
      title: title,
      customer: customer,
      date: date,
      overall_rating: overall_rating,
      visit_reason: visit_reason,
      body: body,
      ratings: ratings,
      employees: employees
    }
  end
end
