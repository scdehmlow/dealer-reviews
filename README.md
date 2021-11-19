# DealerReviews

This application will analyze a set of reviews for a sample dealership and pick out the top three overly positive.
Three measures are used to determine the most overly positive sentiment of the reviews.
All scores are calculated on a scale from 1-5 to correlate with a five option star rating system.
The following scores are used to sort the reviews:
- Average ratings when four or more are provided
- Ratings of employees combined with the total number of employees listed which is weighted at 2x
- Number of `!` characters in the review body

## Running
### Elixir Environment
To run the application either build an executable with `mix escript.build`, 
run `DealerReviews.Cli.main` in iex, or run the mix task with `mix cli`.
### Docker
This application can also be run in a docker container. Use the following command to build the container:
```bash
docker build -t dealer_reviews .
```
and then run this command to run the application and print to the console:
```bash
docker run -it --rm dealer_reviews
```
Make sure the dockerfile is updated if the elixir version is updated.
## Testing
Tests can be run with `mix test`.

