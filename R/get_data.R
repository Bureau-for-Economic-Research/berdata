#' Get BER Data
#'
#' @description Get timeseries by specifying vector of codes.
#' @param time_series_code time series code to return, `KBP7096B`
#' @param output options are ("codes", "names", "nested")
#'
#' @return tibble
#' @export
#'

get_data <- function(time_series_code, 
                     output_format = c("codes", "names", "nested")[3]){
  
  ptm <- proc.time()
  
  apikey <- Sys.getenv("BERDATA_API")
  
  url <- glue("https://api.beranalytics.co.za/")

  payload <- list(
    data = time_series_code, 
    interface = "api", 
    platform = "R",
    apikey = apikey
  )
  
  all_param <- toJSON(payload[-4])
  
  log_debug(skip_formatter(glue("Querying with parameters: [{all_param}]")))
  
  timeseriescode <- POST(glue("{url}/timeseriescode"), body = toJSON(payload)) 
  
  if(status_code(timeseriescode) == 404){
    
    out <- timeseriescode %>% 
      content
    
    stop(toJSON(out, pretty = TRUE))
  }
  
  timeseriescode <- timeseriescode %>% 
    content %>%
    read_csv(show_col_types = FALSE) 
  
  codedescriptions <- POST(glue("{url}/codedescriptions"), body = toJSON(payload)) 
  
  if(status_code(codedescriptions) == 404){
    
    out <- codedescriptions %>% 
      content 
    
    stop(toJSON(out, pretty = TRUE, auto_unbox = TRUE))
  }
  
  codedescriptions <- codedescriptions %>% 
    content %>%
    read_csv(show_col_types = FALSE) %>% 
    clean_names(.)
  
  if(output_format == "codes"){
    out <- timeseriescode
  }

  if(output_format == "names"){
    out <- timeseriescode %>%
      set_names(c("date", codedescriptions$description[match(colnames(timeseriescode)[-1], codedescriptions$timeseries_code)]))
  }
  
  if(output_format == "nested"){
    timeseriescode <- timeseriescode %>% 
      pivot_longer(names_to = "timeseries_code", values_to = "value", -date_col) %>% 
      nest(.by = timeseries_code)
    
    out <- codedescriptions %>%
      left_join(timeseriescode, by = "timeseries_code")
  }
  
  total_time <- round((proc.time() - ptm)[3], 3)
  log_debug(skip_formatter(glue("Total runtime: [{total_time}s]")))
  
  return(out)
}
