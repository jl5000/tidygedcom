% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/activate.R
\name{find_xref}
\alias{find_xref}
\title{Find an xref of a record given a set of terms}
\usage{
find_xref(gedcom, record_xrefs, tags, search_pattern)
}
\arguments{
\item{gedcom}{A tidyged object.}

\item{record_xrefs}{A list of potential xrefs to consider.}

\item{tags}{The tags to look at when comparing values.}

\item{search_pattern}{A set of terms to search for (separated by spaces).}
}
\value{
A single xref for the given record.
}
\description{
This is a helper function to identify the xref of a record given a piece of information such
as a name or reference number.
}
\details{
Sometimes an xref may be provided directly, in which case it's returned straight back.
}
