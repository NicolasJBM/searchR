#' @name references_make_bib_file
#' @title Write a bib file
#' @author Nicolas Mangin
#' @description Function creating a bibtex reference file.
#' @param source_folder Character. Path to the folder where the .Rmd files are.
#' @param references Tibble. List of references.
#' @param destination_folder Character. Path to the folder where the .bib file should be written.
#' @param file_name Character. Name of the .bib file.
#' @return Write a .bib files with all the references quoted in the .Rmd files
#' @importFrom tibble tibble
#' @importFrom stringr str_detect
#' @importFrom dplyr mutate
#' @importFrom purrr map
#' @importFrom tidyr unnest
#' @importFrom stringr str_extract_all
#' @importFrom stringr str_remove_all
#' @importFrom dplyr filter
#' @importFrom tibble as_tibble
#' @importFrom dplyr mutate_all
#' @importFrom stringr str_replace_all
#' @importFrom dplyr mutate
#' @importFrom dplyr group_by
#' @importFrom dplyr sample_n
#' @importFrom dplyr ungroup
#' @importFrom tibble as_tibble
#' @importFrom dplyr select
#' @importFrom purrr pmap
#' @export


references_make_bib_file <- function(
  source_folder = NULL,
  references = NULL,
  destination_folder = NULL,
  file_name = "references.bib"
) {
  
  bibtype <- NULL
  key <- NULL
  author <- NULL
  year <- NULL
  title <- NULL
  journal <- NULL
  volume <- NULL
  number <- NULL
  pages <- NULL
  doi <- NULL
  url <- NULL
  publisher <- NULL
  booktitle <- NULL
  editor <- NULL
  address <- NULL
  chapter <- NULL
  edition <- NULL
  isbn <- NULL
  text <- NULL
  abstract <- NULL
  
  # Gather citations
  if (base::is.null(source_folder)) source_folder <- base::getwd()
  files <- base::list.files(source_folder, full.names = TRUE, recursive = TRUE)
  rmdfiles <- tibble::tibble(
    rmdfiles = files[stringr::str_detect(files, ".Rmd$")]
  )
  
  bibfile <- dplyr::case_when(
    base::is.null(destination_folder) ~ file_name,
    TRUE ~ base::paste0(destination_folder, "/", file_name)
  )
  
  if (base::nrow(rmdfiles) > 0) {
    content <- rmdfiles |>
      dplyr::mutate(text = purrr::map(rmdfiles, base::readLines)) |>
      tidyr::unnest(text)
    content <- base::paste(
      base::as.character(base::unlist(content$text)),
      collaspe = " "
    )
  }
  
  selection <- content |>
    stringr::str_extract_all("@\\w+") |>
    base::unlist() |>
    stringr::str_remove_all("@") |>
    base::unique()
  
  # Create bib file and csv files about journals and authors
  if (base::length(selection) > 0 & base::nrow(references) > 0) {
    references |>
      dplyr::filter(key %in% selection) |>
      tibble::as_tibble() |>
      dplyr::mutate_all(
        stringr::str_replace_all,
        pattern = "&",
        replacement = "\\\\&"
      ) |>
      dplyr::mutate(
        title = base::paste0("{", title, "}"),
        abstract = base::paste0("{", abstract, "}")
      ) |>
      base::unique() |>
      dplyr::group_by(key) |>
      dplyr::sample_n(1) |>
      dplyr::ungroup() |>
      tibble::as_tibble() |>
      dplyr::select(
        bibtype,
        key,
        author,
        year,
        title,
        journal,
        volume,
        number,
        pages,
        doi,
        url,
        publisher,
        booktitle,
        editor,
        address,
        chapter,
        edition,
        isbn
      ) |>
      dplyr::mutate_all(function(x) base::replace(x, base::is.na(x), "")) |>
      purrr::pmap(searchR::references_make_bib_entry) |>
      base::unlist() |>
      base::writeLines(bibfile, useBytes = TRUE)
  }
}
