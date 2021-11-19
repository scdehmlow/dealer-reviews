# DealerReviews

This application will analyze a set of reviews for a sample dealership and pick out the top three overly positive.
Three measures are used to determine the most overly positive sentiment of the reviews.
All scores are calculated on a scale from 1-5 to correlate with a five option star rating system.
The following scores are used to sort the reviews:
- Average ratings when four or more are provided
- Ratings of employees combined with the total number of employees listed which is weighted at 2x
- Number of `!` characters in the review body

## Running
To run the application either build an executable with `mix escript.build`, 
run `DealerReviews.Cli.main` in iex, or run the mix task with `mix cli`.
## Testing
Tests can be run with `mix test`.