#' Generate a JSON Web Token (JWT) for Apple App Store Connect API
#'
#' This function generates a signed JSON Web Token (JWT) using the ES256 algorithm.
#' The token is required to authenticate requests to Apple's App Store Connect API.
#'
#' @param issuer_id A string representing the Issuer ID obtained from App Store Connect.
#' @param key_id A string representing the Key ID associated with the private key.
#' @param private_key_path A string specifying the path to the private key file (a `.p8` file).
#' @param expiration_time A numeric value specifying the token's expiration time as a UNIX timestamp.
#'   Defaults to 20 minutes (1200 seconds) from the current system time.
#'
#' @return A string containing the signed JSON Web Token (JWT).
#' @details
#' - The JWT header includes the algorithm (`ES256`), key ID (`kid`), and type (`typ`).
#' - The JWT payload includes the issuer (`iss`), expiration time (`exp`), and audience (`aud`).
#' - The private key must be readable using the `openssl::read_key()` function.
#' - The token is signed using `jose::jwt_encode_sig()`.
#'
#' @examples
#' \dontrun{
#' issuer_id <- "YOUR_ISSUER_ID"
#' key_id <- "YOUR_KEY_ID"
#' private_key_path <- "path/to/AuthKey_YOUR_KEY_ID.p8"
#' jwt <- generate_jwt(issuer_id, key_id, private_key_path)
#' print(jwt)
#' }
#'
#' @importFrom openssl read_key
#' @importFrom jose jwt_claim jwt_encode_sig
#' @export
generate_jwt <- function(
  issuer_id,
  key_id,
  private_key_path,
  expiration_time = as.numeric(Sys.time()) + 1200
) {
  # Load the private key
  private_key <- openssl::read_key(
    private_key_path
  )

  header <- list(
    alg = "ES256",
    kid = key_id,
    typ = "JWT"
  )

  payload <- jose::jwt_claim(
    iss = issuer_id,           # Issuer ID
    exp = expiration_time,     # Expiration time
    aud = "appstoreconnect-v1" # Audience
  )

  # Sign the JWT
  jose::jwt_encode_sig(
    payload,
    key = private_key,
    header = header
  )
}