defmodule DealerReviews.Scraper do
  def get_reviews_pages(pages) do
    pages
    |> Enum.map(fn p -> get_reviews_page(p) end)
    |> Enum.concat
  end

  def get_reviews_page(page) do
    page |> scrape |> parse
  end

  def scrape(page) do
    url =
      "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page#{page}/"

    response = Crawly.fetch(url)
    response
  end

  def parse(response) do
    {:ok, document} = Floki.parse_document(response.body)

    review_dates = get_review_dates(document)
    titles = get_titles(document)
    bodies = get_bodies(document)
    employees = get_employees(document)
    ratings = get_ratings(document)

    review_dates
    |> Enum.zip(titles)
    |> Enum.map(fn {r, t} ->
      %{date: date, overall: overall, visit_reason: visit_reason} = r
      %{customer: customer, title: title} = t

      %{
        title: title,
        customer: customer,
        date: date,
        overall_rating: overall,
        visit_reason: visit_reason
      }
    end)
    |> Enum.zip(bodies)
    |> Enum.map(fn {r, b} ->
      Map.put(r, :body, b)
    end)
    |> Enum.zip(employees)
    |> Enum.map(fn {r, e} ->
      Map.put(r, :employees, e)
    end)
    |> Enum.zip(ratings)
    |> Enum.map(fn {r, rt} ->
      Map.put(r, :ratings, rt)
    end)
    |> Enum.map(fn r -> struct(DealerReviews.Review, r) end)
  end

  def find_review_date_sections(document) do
    document |> Floki.find("#reviews .review-entry .review-date")
  end

  def parse_review_date_section(section) do
    {"div", _,
     [
       {"div", _, [date]},
       {"div", _,
        [
          {"div",
           [
             {"class",
              "rating-static visible-xs pad-none margin-none rating-" <>
                <<overall::binary-size(2)>> <> " pull-right"}
           ], _},
          _,
          {"div", _, [visit_reason]}
        ]}
     ]} = section

    %{date: date, overall: String.to_integer(overall) / 10, visit_reason: visit_reason}
  end

  def find_title_sections(document) do
    document |> Floki.find("#reviews .review-entry .review-wrapper > div:first-of-type")
  end

  def parse_title_section(section) do
    {"div", _,
     [
       {"h3", _, [title]},
       {"span", _, ["- " <> customer]}
     ]} = section

    %{title: title |> String.replace("\"", ""), customer: customer}
  end

  def find_body_sections(document) do
    document |> Floki.find("#reviews .review-entry .review-wrapper > div:nth-of-type(2)")
  end

  def parse_body_section(section) do
    {"div", _,
     [
       {"div", _,
        [
          {"p", _, [body]},
          _
        ]}
     ]} = section

    body
  end

  def find_employees_sections(document) do
    document |> Floki.find("#reviews .review-entry .review-wrapper .employees-wrapper")
  end

  defp parse_employee_section(section) do
    case section do
      {"div", _,
       [
         {"div", [{"class", "table"}],
          [
            _,
            {"div", _,
             [
               {"a", _, [employee]},
               {"div", _,
                [
                  {"div", _,
                   [
                     {"div", _,
                      [
                        {"span", _, [rating]},
                        _
                      ]}
                   ]}
                ]}
             ]}
          ]}
       ]} ->
        employee_cleaned = employee |> String.replace("\r\n", "") |> String.trim()
        {rating_integer, _} = rating |> Integer.parse()
        %DealerReviews.Review.EmployeeReview{name: employee_cleaned, rating: rating_integer}

      _ ->
        nil
    end
  end

  def parse_employees_section(section) do
    {"div", [{"class", "col-xs-12 lt-grey pad-left-none employees-wrapper"}], [_ | employees]} =
      section

    employees
    |> Enum.map(fn e -> parse_employee_section(e) end)
    |> Enum.filter(fn e -> e != nil end)
  end

  def find_ratings_section(document) do
    document |> Floki.find("#reviews .review-entry .review-wrapper .review-ratings-all")
  end

  def parse_recommend(recommend) do
    case recommend do
      "Yes" -> true
      "No" -> false
      _ -> raise "Invalid recommend #{recommend}"
    end
  end

  def parse_rating_section(section) do
    case section do
      {"div", _,
       [
         {"div", _, [label]},
         {"div",
          [
            {"class",
             "rating-static-indv rating-" <> <<rating::binary-size(1)>> <> "0 margin-top-none td"}
          ], []}
       ]} ->
        %{label: label, rating: rating |> String.to_integer()}

      {"div", _,
       [
         {"div", _, [label]},
         {"div", [{"class", "td small-text boldest"}], [recommend]}
       ]} ->
        %{
          label: label,
          recommend: recommend |> String.replace("\r\n", "") |> String.trim() |> parse_recommend
        }

      _ ->
        nil
    end
  end

  def parse_ratings_section(section) do
    {"div", _,
     [
       _,
       {"div", _, ratings}
     ]} = section

    ratings
  end

  def merge_ratings(ratings_map, ratings) do
    case ratings do
      [h | t] ->
        case h do
          %{label: "Customer Service", rating: r} -> Map.put(ratings_map, :customer_service, r)
          %{label: "Quality of Work", rating: r} -> Map.put(ratings_map, :quality, r)
          %{label: "Friendliness", rating: r} -> Map.put(ratings_map, :friendliness, r)
          %{label: "Pricing", rating: r} -> Map.put(ratings_map, :pricing, r)
          %{label: "Overall Experience", rating: r} -> Map.put(ratings_map, :overall, r)
          %{label: "Recommend Dealer", recommend: r} -> Map.put(ratings_map, :recommend, r)
        end
        |> merge_ratings(t)

      [] ->
        struct(DealerReviews.Review.Ratings, ratings_map)
    end
  end

  def get_ratings(document) do
    find_ratings_section(document)
    |> Enum.map(fn rating ->
      rating_list =
        parse_ratings_section(rating)
        |> Enum.map(fn r -> parse_rating_section(r) end)
        |> Enum.filter(fn r -> r != nil end)

      merge_ratings(%{}, rating_list)
    end)
  end

  def get_employees(document) do
    find_employees_sections(document)
    |> Enum.map(fn e ->
      parse_employees_section(e)
    end)
  end

  def get_bodies(document) do
    find_body_sections(document)
    |> Enum.map(fn b ->
      parse_body_section(b)
    end)
  end

  def get_titles(document) do
    find_title_sections(document)
    |> Enum.map(fn t ->
      parse_title_section(t)
    end)
  end

  def get_review_dates(document) do
    find_review_date_sections(document)
    |> Enum.map(fn r ->
      parse_review_date_section(r)
    end)
  end
end
