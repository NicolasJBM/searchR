% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/documents_get_meta.R
\name{documents_get_meta}
\alias{documents_get_meta}
\title{Get a document's meta-information}
\usage{
documents_get_meta(path)
}
\arguments{
\item{path}{character. Path to the document for which meta-information should be retrieved.}
}
\value{
A single-row tibble with all the tags from a document.
}
\description{
Function reading a document and retrieving the tags in meta-information.
}
\author{
Nicolas Mangin
}
