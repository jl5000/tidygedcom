% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/source.R
\name{add_sour}
\alias{add_sour}
\title{Add a Source record to a tidyged object}
\usage{
add_sour(
  gedcom,
  events_recorded = character(),
  date_period_covered = date_period(),
  jurisdiction = character(),
  responsible_agency = character(),
  originator = character(),
  title = character(),
  short_title = character(),
  publication_detail = character(),
  source_text = character(),
  user_reference_number = character(),
  user_reference_type = character(),
  data_notes = character(),
  sour_notes = character(),
  multimedia_links = character()
)
}
\arguments{
\item{gedcom}{A tidyged object.}

\item{events_recorded}{An enumeration of the different kinds of events that were recorded
in this source. Each enumeration is separated by a comma. See the Gedcom 5.5.5 Specification for
more details.}

\item{date_period_covered}{A date_period() object indicating the time period of events
covered by this source.}

\item{jurisdiction}{A character string indicating the lowest level jurisdiction encompassing
all places named in this source. See the Gedcom 5.5.5 Specification for more details.}

\item{responsible_agency}{The organisation, institution, corporation, person, or other
entity that has responsibility for the source data.}

\item{originator}{The person, agency, or entity who created the record.}

\item{title}{The title of the source work, record, or item and, when appropriate, the title of the
larger work or series of which it is a part.}

\item{short_title}{An abbreviated or shortened version of the title (if required).}

\item{publication_detail}{When and where the source record was created. For published works,
this includes information such as the city of publication, name of the publisher, and year of
publication.}

\item{source_text}{A verbatim copy of relevant text contained within the source.
This indicates notes or text that are actually contained in the source document,
not the submitter's opinion about the source.}

\item{user_reference_number}{A unique user-defined number or text that the submitter
uses to identify this record. You can supply more than one in a vector.}

\item{user_reference_type}{A user-defined definition of the user_reference_number(s). If this
parameter is used, there must be a reference type for every reference number defined.}

\item{data_notes}{A character vector of notes associated with the data in this Source record.
These could be xrefs to existing Note records.}

\item{sour_notes}{A character vector of notes accompanying this Source record.
These could be xrefs to existing Note records.}

\item{multimedia_links}{A character vector of multimedia file references accompanying this
source. These could be xrefs to existing Multimedia records.}
}
\value{
An updated tidyged object including the Source record.
}
\description{
Add a Source record to a tidyged object
}
