
#' Define a place associated with a fact
#'
#' @param name The jurisdictional name of the place. 
#' Jurisdictions are separated by commas, for example, "Cove, Cache, Utah, USA."
#' @param phonetic_var A character vector of phonetic variations of the place name.
#' @param phonetisation_method A character vector giving the method used in transforming the text to 
#' the corresponding phonetic variation. If this argument is used, it must be the same size
#' as the phonetic_var argument.
#' @param romanised_var A character vector of romanised variations of the place name. 
#' @param romanisation_method A character vector giving the method used in transforming the text to 
#' the corresponding romanised variation. If this argument is used, it must be the same size
#' as the romanised_var argument.
#' @param latitude The value specifying the latitudinal coordinate of the place. 
#' The latitude coordinate is the direction North or South from the equator in degrees and 
#' fraction of degrees carried out to give the desired accuracy. 
#' For example: 18 degrees, 9 minutes, and 3.4 seconds North would be formatted as "N18.150944"
#' @param longitude The value specifying the longitudinal coordinate of the place. 
#' The longitude coordinate is Degrees and fraction of degrees east or west of the zero or 
#' base meridian coordinate. For example:
#' 168 degrees, 9 minutes, and 3.4 seconds East would be formatted as "E168.150944". 
#' @param notes A character vector of notes accompanying the place.
#' These could be xrefs to existing Note records.
#'
#' @return A tibble describing a place.
#' @export
#' @tests
#' expect_equal(place(), tibble::tibble())
#' expect_snapshot_value(place("A place"), "json2")
place <- function(name = character(),
                  phonetic_var = character(),
                  phonetisation_method = character(),
                  romanised_var = character(),
                  romanisation_method = character(),
                  latitude = character(),
                  longitude = character(),
                  notes = character()) {
  
  plac_notes <- purrr::map(notes, tidyged.internals::NOTE_STRUCTURE)
  
  if(length(name) == 0) {
    
    tidyged.internals::PLACE_STRUCTURE(character())
    
  } else {
    
    tidyged.internals::PLACE_STRUCTURE(place_name = name,
                                       place_phonetic = phonetic_var,
                                       phonetisation_method = phonetisation_method,
                                       place_romanised = romanised_var,
                                       romanisation_method = romanisation_method,
                                       place_latitude = latitude,
                                       place_longitude = longitude,
                                       notes = plac_notes)
  }
  
  
}


#' Define an address
#'
#' @param local_address_lines A character vector containing up to three local address lines.
#' @param city The city of the address.
#' @param state The state/county of the address.
#' @param postal_code The postal code of the address.
#' @param country The country of the address.
#' @param phone_number A character vector containing up to three phone numbers.
#' @param email A character vector containing up to three email addresses.
#' @param fax A character vector containing up to three fax numbers.
#' @param web_page A character vector containing up to three web pages.
#'
#' @return A tibble describing an address.
#' @export
#' @tests
#' expect_equal(address(), tibble::tibble())
#' expect_snapshot_value(address("A place"), "json2")
address <- function(local_address_lines = character(),
                    city = character(),
                    state = character(),
                    postal_code = character(),
                    country = character(),
                    phone_number = character(),
                    email = character(),
                    fax = character(),
                    web_page = character()) {
  
  if(length(local_address_lines) > 3) local_address_lines <- local_address_lines[1:3]
  if(length(phone_number) > 3) phone_number <- phone_number[1:3]
  if(length(email) > 3) email <- email[1:3]
  if(length(fax) > 3) fax <- fax[1:3]
  if(length(web_page) > 3) web_page <- web_page[1:3]
  
  tidyged.internals::ADDRESS_STRUCTURE(local_address_lines = local_address_lines,
                                       address_city = city,
                                       address_state = state,
                                       address_postal_code = postal_code,
                                       address_country = country,
                                       phone_number = phone_number,
                                       address_email = email,
                                       address_fax = fax,
                                       address_web_page = web_page)
  
  
}

#' Define a personal name's components
#' 
#' @param prefix The name prefix, e.g. Cmdr.
#' @param given The given name or earned name. Different given names are separated 
#' by a comma.
#' @param nickname A descriptive or familiar name used in connection with one's 
#' proper name.
#' @param surname_prefix Surname prefix or article used in a family name. 
#' For example in the name "de la Cruz", this value would be "de la".
#' @param surname Surname or family name. Different surnames are separated by a comma.
#' @param suffix Non-indexing name piece that appears after the given name and surname 
#' parts, e.g. Jr. Different name suffix parts are separated by a comma.
#' @param notes A character vector of notes accompanying this name.
#' These could be xrefs to existing Note records.
#'
#' @return A tibble describing a personal name's components.
#' @export
name_pieces <- function(prefix = character(),
                        given = character(), 
                        nickname = character(), 
                        surname_prefix = character(),
                        surname = character(),
                        suffix = character(),
                        notes = character()) {
  
  nam_notes <- purrr::map(notes, tidyged.internals::NOTE_STRUCTURE)
  
  names <- tidyged.internals::PERSONAL_NAME_PIECES(name_piece_prefix = prefix,
                                                   name_piece_given = given, 
                                                   name_piece_nickname = nickname, 
                                                   name_piece_surname_prefix = surname_prefix,
                                                   name_piece_surname = surname,
                                                   name_piece_suffix = suffix,
                                                   notes = nam_notes)
  
  if(nrow(names) > 0 & #We need this check so an empty full name is not constructed
     length(given) + length(surname_prefix) + length(surname) + length(suffix) == 0) 
    stop("Try to define a given name or surname")
  
  names
}


#' Create a citation of a Source record
#'
#' @param gedcom A tidyged object.
#' @param source A character string identifying the source. This can either 
#' be an xref or term(s) to match to a source title.
#' @param where Specific location within the information referenced. For a published work, this could include
#' the volume of a multi-volume work and the page number(s). For a newspaper, it could include a column
#' number and page number. A census record might have an enumerating district, page number, line number, 
#' dwelling number, and family number. 
#' The data in this field should be in the form of a label and value pair, such as Label1: value,
#' Label2: value, with each pair being separated by a comma. For example, Film: 1234567,
#' Frame: 344, Line: 28.
#' @param entry_date A date_calendar(), date_period(), date_range(), or date_approximated() 
#' value giving the date that this data was entered into the original source document.
#' @param source_text A verbatim copy of any description contained within the source. 
#' This indicates notes or text that are actually contained in the source document, 
#' not the submitter's opinion about the source.
#' @param certainty An evaluation of the credibility of a piece of information, based upon 
#' its supporting evidence. Some systems use this feature to rank multiple conflicting opinions 
#' for display of most likely information first. It is not intended to eliminate the receiver's 
#' need to evaluate the evidence for themselves. Values allowed:
#' "unreliable", "subjective", "secondary", "primary".
#' @param notes A character vector of notes accompanying the citation. These could be xrefs to 
#' existing Note records.
#' @param multimedia_links A character vector of multimedia file references accompanying this
#' citation. These could be xrefs to existing Multimedia records.
#'
#' @return A tibble describing a source citation.
#' @export
source_citation <- function(gedcom,
                            source,
                            where = character(),
                            entry_date = character(),
                            source_text = character(),
                            certainty = character(),
                            notes = character(),
                            multimedia_links = character()) {
  
  sour <- get_valid_xref(gedcom, source, .pkgenv$record_string_sour, is_sour)

  cit_notes <- purrr::map(notes, tidyged.internals::NOTE_STRUCTURE)
  
  media_links <- purrr::map_chr(multimedia_links, find_xref, 
                                gedcom = gedcom, record_xrefs = xrefs_media(gedcom), tags = "FILE") %>% 
    purrr::map(tidyged.internals::MULTIMEDIA_LINK)
  
  certainty <- dplyr::case_when(certainty == "unreliable" ~ "0",
                                certainty == "subjective" ~ "1",
                                certainty == "secondary" ~ "2",
                                certainty == "primary" ~ "3",
                                TRUE ~ "error")
  
  if(certainty == "error") stop("Invalid certainty value given")
  
  tidyged.internals::SOURCE_CITATION(xref_sour = sour,
                                     where_within_source = where,
                                     entry_recording_date = entry_date,
                                     text_from_source = source_text,
                                     certainty_assessment = certainty,
                                     multimedia_links = media_links,
                                     notes = cit_notes)
  
  
}