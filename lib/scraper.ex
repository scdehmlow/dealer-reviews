defmodule DealerReviews.Scraper do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.dealerrater.com/"

  @impl Crawly.Spider
  def init(),
    do: [
      start_urls: [
        "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page1/"
      ]
    ]

  @impl Crawly.Spider
  def parse_item(response) do
    # IO.inspect(response)
    {:ok, document} = Floki.parse_document(response.body)

    items =
      document
      |> Floki.find("#reviews")

    IO.puts(items)

    %Crawly.ParsedItem{:items => items, :requests => []}
  end

  def scrape(page) do
    url =
      "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page#{page}/"

    response = Crawly.fetch(url)
    IO.inspect(response)
    response
  end

  def parse(response) do
    {:ok, document} = Floki.parse_document(response.body)

    reviews =
      document
      |> Floki.find("#reviews")
      |> Floki.find(".review-entry")
  end

  def find_review_date_sections(document) do
    document |> Floki.find("#reviews .review-entry .review-date")
  end

  def parse_review_date_section(section) do
    [
      {"div", _,
       [
         {"div", _, [date]},
         {"div", _,
          [
            {"div",
             [
               {"class",
                "rating-static visible-xs pad-none margin-none rating-" <>
                  <<overall::binary-size(1)>> <> "0 pull-right"}
             ], _},
            _,
            {"div", _, [visit_reason]}
          ]}
       ]}
    ] = section

    %{date: date, overall: overall, visit_reason: visit_reason}
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

    %{body: body}
  end

  def find_employees_sections(document) do
    document |> Floki.find("#reviews .review-entry .review-wrapper .employees-wrapper")
  end

  defp parse_employee_section(section) do
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
     ]} = section

    employee_cleaned = employee |> String.replace("\r\n", "") |> String.trim()
    %{employee: employee_cleaned, rating: rating |> Integer.parse()}
  end

  def parse_employees_section(section) do
    {"div", [{"class", "col-xs-12 lt-grey pad-left-none employees-wrapper"}], [_ | employees]} =
      section

    employees
    |> Enum.map(fn e -> parse_employee_section(e) end)
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
        %{label: label, rating: rating |> String.to_integer}

      {"div", _,
       [
         {"div", _, [label]},
         {"div", [{"class", "td small-text boldest"}], [recommend]}
       ]} ->
        %{label: label, recommend: recommend |> String.replace("\r\n","") |> String.trim |> parse_recommend}

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
      [h|t] -> case h do
        %{label: "Customer Service", rating: r} -> Map.put(ratings_map, :customer_service, r)
        %{label: "Friendliness", rating: r} ->  Map.put(ratings_map, :friendliness, r)
        %{label: "Pricing", rating: r} ->  Map.put(ratings_map, :pricing, r)
        %{label: "Overall Experience", rating: r} ->  Map.put(ratings_map, :overall, r)
        %{label: "Recommend Dealer", recommend: r} ->  Map.put(ratings_map, :recommend, r)
      end
      |> merge_ratings(t)
      [] -> struct(DealerReviews.Review.Ratings, ratings_map)
    end
  end

  def test(document) do
    ratings = find_ratings_section(document)
    [ratings1 | _] = ratings
    rating_list = parse_ratings_section(ratings1)
    |> Enum.map(fn r -> parse_rating_section(r) end)
    |> Enum.filter(fn r -> r != nil end)

    merge_ratings(%{}, rating_list)
  end
end
