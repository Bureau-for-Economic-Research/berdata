#' berdata.R
#' @import logger
#' @import dplyr
#' @import lubridate
#' @import jsonlite
#' @importFrom httr RETRY POST add_headers http_type http_error content status_code
#' @importFrom snakecase to_sentence_case to_snake_case
#' @importFrom glue glue
#' @importFrom readr read_csv
#' @importFrom scales comma
#' @importFrom purrr set_names
#' @importFrom tidyr drop_na pivot_longer nest
#' @importFrom janitor clean_names
#'

PKG_VERSION <- utils::packageDescription('berdata')$Version
