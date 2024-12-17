#' Query a Paginated App Store Connect API Endpoint
#'
#' This function queries a specified App Store Connect API endpoint, handling authentication
#' with a JSON Web Token (JWT) and iterating through paginated results until all data is retrieved.
#'
#' @param verb A verb indicating the HTTP method to use (must be from `{httr}`).
#' @param api_url A string representing the initial API endpoint URL to query.
#' @param jwt A string containing the JSON Web Token (JWT) used for authentication.
#' @param ... arguments passed to `verb`
#'
#' @return A list containing all results retrieved from the API across all pages.
#' If an error occurs during any request, \code{NULL} is returned, and the error message is printed.
#'
#' @details
#' - The function sends a \code{verb} request to the specified \code{api_url}.
#' - Authentication is handled by attaching the JWT in the \code{Authorization} header.
#' - If the response includes a \code{meta$paging$next} field, the function retrieves additional pages.
#' - Results from all pages are combined into a single list and returned.
#'
#' @importFrom httr add_headers content status_code modify_url
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' \dontrun{
#' jwt <- generate_jwt(
#'   issuer_id = '1234',
#'   key_id = '1234',
#'   private_key_path = "1234"
#' )
#' query_api(
#'   httr::GET,
#'   "https://api.appstoreconnect.apple.com/v1/apps",
#'    jwt
#' )
#' }
query_api <- function(verb, api_url, jwt, ...) {
  all_results <- list()  # To store all results
  next_url <- api_url    # Start with the first page

  repeat {
    # Make the API request
    response <- verb(
      url = next_url,
      add_headers(
        Authorization = paste("Bearer", jwt),
        "Content-Type" = "application/json"
      ),
      ...
    )

    # Check response status
    if (status_code(response) != 200) {
      cat("Error:", status_code(response), "\n")
      cat("Response:", content(response, as = "text"), "\n")
      return(NULL)
    }

    # Parse the response
    content_parsed <- fromJSON(content(response, as = "text", encoding = "UTF-8"))

    # Append the data to the all_results list
    all_results <- append(all_results, content_parsed$data)

    # Check for pagination
    if (!is.null(content_parsed$meta$paging$`next`)) {
      next_url <- content_parsed$meta$paging$`next`  # Set the next URL
    } else {
      break  # No more pages, exit the loop
    }
  }

  # Return all collected results
  return(all_results)
}
