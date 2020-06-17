
address_structure <- function(all_address_lines,
                              city = character(),
                              state = character(),
                              postal_code = character(),
                              country = character(),
                              phone_numbers = character(),
                              emails = character(),
                              fax_numbers = character(),
                              web_pages = character()) {
  
  if (length(all_address_lines) == 0) return(tibble())
  postal_code <- as.character(postal_code)
  phone_numbers <- as.character(phone_numbers)
  fax_numbers <- as.character(fax_numbers)
  
  validate_input_size(all_address_lines, 4, 1, 60)
  validate_input_size(city, 1, 1, 60)
  validate_input_size(state, 1, 1, 60)
  validate_input_size(postal_code, 1, 1, 10)
  validate_input_size(country, 1, 1, 60)
  validate_input_size(phone_numbers, 3, 1, 25)
  validate_input_size(emails, 3, 5, 120)
  validate_input_size(fax_numbers, 3, 5, 60)
  validate_input_size(web_pages, 3, 5, 120)
  
  
  address_lines_all <- tibble()
  
  # First populate the ADDR and CONT lines (mandatory)
  for (i in seq_along(all_address_lines)) {
      
    if (i == 1) {
      address_lines_all <- bind_rows(
        address_lines_all,
        tibble(level = 0, tag = "ADDR", value = all_address_lines[i])
      )
    } else {
      address_lines_all <- bind_rows(
        address_lines_all,
        tibble(level = 1, tag = "CONT", value = all_address_lines[i])
      )
    }
      
  }
  
  # Now populate ADR1/2/3 lines
  if (length(all_address_lines) > 1) {
    for (i in 2:length(all_address_lines)) {
      
      address_lines_all <- bind_rows(
        address_lines_all,
        tibble(level = 1, tag = paste0("ADR", i-1), value = all_address_lines[i])
      )
    }
  }
  
  bind_rows(
    address_lines_all,
    tibble(level = 1, tag = "CITY", value = city),
    tibble(level = 1, tag = "STAE", value = state),
    tibble(level = 1, tag = "POST", value = postal_code),
    tibble(level = 1, tag = "CTRY", value = country),
    tibble(level = 0, tag = "PHON", value = phone_numbers),
    tibble(level = 0, tag = "EMAIL", value = emails),
    tibble(level = 0, tag = "FAX", value = fax_numbers),
    tibble(level = 0, tag = "WWW", value = web_pages)
  )
  
  
}


association_structure <- function(individual_ref,
                                  relation_is,
                                  source_citations = list(),
                                  notes = list()) {
  
  if (length(individual_ref) == 0) return(tibble())
  if (length(relation_is) == 0) return(tibble())
  
  validate_input_size(individual_ref, 1, 1, 18)
  validate_input_size(relation_is, 1, 1, 25)
  
  bind_rows(
    tibble(level = 0, tag = "ASSO", value = ref_to_xref(individual_ref, "I")),
    tibble(level = 1, tag = "RELA", value = relation_is),
    source_citations %>% bind_rows() %>% add_levels(1),
    notes %>% bind_rows() %>% add_levels(1)
  )
  
}


change_date <- function(date = date_exact(),
                        time = character(),
                        notes = list()) {
  
  if (length(date) == 0) 
    date <- toupper(format(Sys.Date(), "%d %b %Y"))
  
  validate_input_size(date, 1, 10, 11)
  validate_input_size(time, 1, 1, 12)
  
  bind_rows(
    tibble(level = 0, tag = "CHAN", value = ""),
    tibble(level = 1, tag = "DATE", value = date),
    tibble(level = 2, tag = "TIME", value = time),
    notes %>% bind_rows() %>% add_levels(1)
  )
  
}


child_to_family_link <- function(family_ref,
                                pedigree_linkage_type = character(),
                                child_linkage_status = character(),
                                notes = list()) {
  
  if (length(family_ref) == 0) return(tibble())
  
  validate_input_size(family_ref, 1, 1, 18)
  validate_input_size(pedigree_linkage_type, 1)
  validate_input_size(child_linkage_status, 1)
  check_pedigree_linkage_type(pedigree_linkage_type)
  check_child_linkage_status(child_linkage_status)
  
  
  bind_rows(
    tibble(level = 0, tag = "FAMC", value = ref_to_xref(family_ref, "F")),
    tibble(level = 1, tag = "PEDI", value = pedigree_linkage_type),
    tibble(level = 1, tag = "STAT", value = child_linkage_status),
    notes %>% bind_rows() %>% add_levels(1)
  )
  
}


event_detail <- function(event_classification = character(),
                         date = character(),
                         place = place_structure(character()),
                         address = address_structure(character()),
                         responsible_agency = character(),
                         religious_affiliation = character(),
                         cause_of_event = character(),
                         restriction_notice = character(),
                         notes = list(),
                         source_citations = list(),
                         multimedia_links = list()) {
  
  validate_input_size(event_classification, 1, 1, 90)
  validate_input_size(date, 1, 1, 35)
  validate_input_size(responsible_agency, 1, 1, 120)
  validate_input_size(religious_affiliation, 1, 1, 90)
  validate_input_size(cause_of_event, 1, 1, 90)
  validate_input_size(restriction_notice, 1)
  check_restriction_notice(restriction_notice)
  
  bind_rows(
    tibble(level = 0, tag = "TYPE", value = event_classification),
    tibble(level = 0, tag = "DATE", value = date),
    place %>% add_levels(0),
    address %>% add_levels(0),
    tibble(level = 0, tag = "AGNC", value = responsible_agency),
    tibble(level = 0, tag = "RELI", value = religious_affiliation),
    tibble(level = 0, tag = "CAUS", value = cause_of_event),
    tibble(level = 0, tag = "RESN", value = restriction_notice),
    notes %>% bind_rows() %>% add_levels(0),
    source_citations %>% bind_rows() %>% add_levels(0),
    multimedia_links %>% bind_rows() %>% add_levels(0)
  )
  
}


family_event_detail <- function(husband_age = character(),
                                wife_age = character(),
                                event_details = event_detail()) {
  
  husband_age <- as.character(husband_age)
  wife_age <- as.character(wife_age)
  
  validate_input_size(husband_age, 1, 1, 12)
  validate_input_size(wife_age, 1, 1, 12)
  
  temp = bind_rows(
    tibble(level = 0, tag = "HUSB", value = ""),
    tibble(level = 1, tag = "HAGE", value = husband_age),
    tibble(level = 0, tag = "WIFE", value = ""),
    tibble(level = 1, tag = "WAGE", value = wife_age),
    event_details %>% add_levels(0),
  )
  
  if (sum(temp$tag == "HAGE") == 0) temp <- filter(temp, tag != "HUSB")
  if (sum(temp$tag == "WAGE") == 0) temp <- filter(temp, tag != "WIFE")  
  mutate(temp,
         tag = if_else(tag == "HAGE", "AGE", tag),
         tag = if_else(tag == "WAGE", "AGE", tag))
  
}


family_event_structure <- function(family_event,
                                   family_event_details = family_event_detail()) {
  
  if (length(family_event) == 0) return(tibble())
  
  validate_input_size(family_event, 1)
  check_family_event(family_event)
  
  bind_rows(
    tibble(level = 0, tag = family_event, value = ""),
    family_event_details %>% add_levels(1),
  )
  
}


individual_attribute_structure <- function(individual_attribute,
                                           attribute_description,
                                           individual_event_details = individual_event_detail()) {
  
  if (length(individual_attribute) == 0) return(tibble())
  
  validate_input_size(individual_attribute, 1)
  check_individual_attribute(individual_attribute)
  
  if (individual_attribute %in% c("CAST","OCCU","RELI","FACT")) {
      validate_input_size(attribute_description, 1, 1, 90)
  } else if (individual_attribute %in% c("EDUC","PROP")) {
    validate_input_size(attribute_description, 1, 1, 248)
  } else if (individual_attribute == "IDNO") {
    validate_input_size(attribute_description, 1, 1, 30)
  } else if (individual_attribute %in% c("NATI","TITL")) {
    validate_input_size(attribute_description, 1, 1, 120)
  } else if (individual_attribute %in% c("NCHI","NMR")) {
    validate_input_size(attribute_description, 1, 1, 3)
  } else if (individual_attribute == "SSN") {
    validate_input_size(attribute_description, 1, 9, 11)
  }
  
  
  if (individual_attribute == "DSCR") {
    
    temp <- split_text(start_level = 0, top_tag = "DSCR", text = attribute_description)
    
  } else {
    
    temp <- tibble(level = 0, tag = individual_attribute, value = attribute_description)
    
  }
  
  bind_rows(temp, 
            individual_event_details %>% add_levels(1)
  )
  
}


individual_event_detail <- function(event_details = event_detail(),
                                    age = character()) {
  
  age <- as.character(age)
  
  validate_input_size(age, 1, 1, 12)
  
  bind_rows(
    event_details %>% add_levels(0),
    tibble(level = 0, tag = "AGE", value = age),
  )
  
  
}


individual_event_structure <- function(individual_event,
                                       individual_event_details = individual_event_detail(),
                                       family_ref = character(),
                                       adoptive_parent = character()) {
  
  if (length(individual_event) == 0) return(tibble())
  
  validate_input_size(individual_event, 1)
  validate_input_size(family_ref, 1, 1, 18)
  validate_input_size(adoptive_parent, 1)
  check_individual_event(individual_event)
  check_adoptive_parent(adoptive_parent)
  
  temp <- bind_rows(
    tibble(level = 0, tag = individual_event, value = ""),
    individual_event_details %>% add_levels(1)
  )
    
  if (sum(temp$tag %in% c("BIRT", "CHR", "ADOP")) == 1)
    temp <- bind_rows(
      temp,
      tibble(level = 1, tag = "FAMC", value = ref_to_xref(family_ref, "F"))
    )
  
  if (sum(temp$tag == "ADOP") == 1)
    temp <- bind_rows(
      temp,
      tibble(level = 2, tag = "ADOP", value = adoptive_parent)
    )
    
  temp %>% 
    mutate(value = if_else(tag %in% c("BIRT", "CHR", "DEAT"), "Y", value))
  
}


lds_individual_ordinance <- function() {
  
  tibble()
}


lds_spouse_sealing <- function() {
  
  tibble()
}


multimedia_link <- function(file_ref,
                            media_format = character(),
                            media_type = character(),
                            title = character()) {
  
  if (length(file_ref) == 0) return(tibble())
  
  if_else(is.numeric(file_ref),
          validate_input_size(file_ref, 1, 1, 18),
          validate_input_size(file_ref, 1000, 1, 30))
  # Is it one format per file?
  validate_input_size(media_format, 1)
  validate_input_size(media_type, 1)
  validate_input_size(title, 1, 1, 248)
  check_media_format(media_format)
  check_media_type(media_type)
  
  if (is.numeric(file_ref)) {
  
    tibble(level = 0, tag = "OBJE", value = ref_to_xref(file_ref, "M"))
  
  } else {
    
    #file and form are needed
    if (length(media_format) == 0) stop("Media format required")
    
    bind_rows(
      tibble(level = 0, tag = "OBJE", value = ""),
      tibble(level = 1, tag = "FILE", value = file_ref),
      tibble(level = 2, tag = "FORM", value = media_format),
      tibble(level = 3, tag = "MEDI", value = media_type),
      tibble(level = 1, tag = "TITL", value = title)
    )
  }
}


note_structure <- function(notes) {
  
  if (length(notes) == 0) return(tibble())
  
  if (is.numeric(notes)) {
    
    validate_input_size(notes, 1, 1, 18)
    tibble(level = 0, tag = "NOTE", value = ref_to_xref(notes, "T"))
  
  } else {
  
    validate_input_size(notes, 1)
    split_text(start_level = 0, top_tag = "NOTE", text = notes)  
  }
  
}





personal_name_pieces <- function(prefix = character(),
                                 given = character(), 
                                 nickname = character(), 
                                 surname_prefix = character(),
                                 surname = character(),
                                 suffix = character(),
                                 notes = list(),
                                 source_citations = list()) {
  
  validate_input_size(prefix, 1, 1, 30)
  validate_input_size(given, 1, 1, 120)
  validate_input_size(nickname, 1, 1, 30)
  validate_input_size(surname_prefix, 1, 1, 30)
  validate_input_size(surname, 1, 1, 120)
  validate_input_size(suffix, 1, 1, 30)
  
  bind_rows(
    tibble(level = 0, tag = "NPFX", value = prefix),
    tibble(level = 0, tag = "GIVN", value = given),
    tibble(level = 0, tag = "NICK", value = nickname),
    tibble(level = 0, tag = "SPFX", value = surname_prefix),
    tibble(level = 0, tag = "SURN", value = surname),
    tibble(level = 0, tag = "NSFX", value = suffix),
    notes %>% bind_rows() %>% add_levels(0),
    source_citations %>% bind_rows() %>% add_levels(0)
  ) 
  
}


personal_name_structure <- function(name,
                                    type = character(),
                                    name_pieces = personal_name_pieces(), 
                                    phonetic_variation = character(),
                                    phonetic_type = character(),
                                    phonetic_name_pieces = list(),
                                    romanized_variation = character(),
                                    romanized_type = character(),
                                    romanized_name_pieces = list()) {
  
  if (length(name) == 0) return(tibble())
  
  validate_input_size(name, 1, 1, 120)
  validate_input_size(type, 1, 5, 30)
  validate_input_size(phonetic_variation, 1000, 5, 120)
  validate_input_size(phonetic_type, 1000, 5, 30)
  validate_input_size(romanized_variation, 1000, 5, 120)
  validate_input_size(romanized_type, 1000, 5, 30)
  
  # ARE THESE NEEDED? - SPEC IS UNCLEAR
  if (length(phonetic_variation) != length(phonetic_type))
    stop("Each phonetic variation requires a phonetic type")
  if (length(phonetic_variation) != length(phonetic_name_pieces) &
      length(phonetic_name_pieces) > 0)
    stop("Each phonetic variation requires a set of phonetic name pieces")
  if (length(romanized_variation) != length(romanized_type))
    stop("Each romanized variation requires a romanized type")
  if (length(romanized_variation) != length(romanized_name_pieces) &
      length(romanized_name_pieces) > 0)
    stop("Each romanized variation requires a set of romanized name pieces")
  
  temp <- bind_rows(
    tibble(level = 0, tag = "NAME", value = name),
    tibble(level = 1, tag = "TYPE", value = type),
    name_pieces %>% add_levels(1)
  )
  
  for (i in seq_along(phonetic_variation)) {
    temp <- bind_rows(
      temp,
      tibble(level = 1, tag = "FONE", value = phonetic_variation[i]),
      tibble(level = 2, tag = "TYPE", value = phonetic_type[i])
    )
    if (length(phonetic_name_pieces) > 0)
      temp <- bind_rows(temp, phonetic_name_pieces[[i]] %>% add_levels(2))
  }
  for (i in seq_along(romanized_variation)) {
    temp <- bind_rows(
     temp,
     tibble(level = 1, tag = "ROMN", value = romanized_variation[i]),
     tibble(level = 2, tag = "TYPE", value = romanized_type[i])
    )
    if (length(romanized_name_pieces) > 0)
      temp <- bind_rows(temp, romanized_name_pieces[[i]] %>% add_levels(2))
  }
  
  temp
  
}


place_structure <- function(place,
                            place_hierarchy = character(),
                            phonetic_variation = character(),
                            phonetic_type = character(),
                            romanized_variation = character(),
                            romanized_type = character(),
                            latitude = character(),
                            longitude = character(),
                            notes = list()) {

  if (length(place) == 0) return(tibble())
  
  validate_input_size(place, 1, 1, 120)
  validate_input_size(place_hierarchy, 1, 1, 120)
  validate_input_size(phonetic_variation, 1000, 1, 120)
  validate_input_size(phonetic_type, 1000, 5, 30)
  validate_input_size(romanized_variation, 1000, 1, 120)
  validate_input_size(romanized_type, 1000, 5, 30)
  validate_input_size(latitude, 1, 5, 8)
  validate_input_size(longitude, 1, 5, 8)
  
  # ARE THESE NEEDED? - SPEC IS UNCLEAR
  if (length(phonetic_variation) != length(phonetic_type))
    stop("Each phonetic variation requires a phonetic type")
  if (length(romanized_variation) != length(romanized_type))
    stop("Each romanized variation requires a romanized type")
  
  temp <- bind_rows(
    tibble(level = 0, tag = "PLAC", value = place),
    tibble(level = 1, tag = "FORM", value = place_hierarchy)
    )
  
  for (i in seq_along(phonetic_variation)) {
    temp <- bind_rows(
      temp,
      tibble(level = 1, tag = "FONE", value = phonetic_variation[i]),
      tibble(level = 2, tag = "TYPE", value = phonetic_type[i])
    )
  }
  for (i in seq_along(romanized_variation)) {
    temp <- bind_rows(
      temp,
      tibble(level = 1, tag = "ROMN", value = romanized_variation[i]),
      tibble(level = 2, tag = "TYPE", value = romanized_type[i])
    )
  }
  
  temp <- bind_rows(
    temp,
    tibble(level = 1, tag = "MAP", value = ""),
    tibble(level = 2, tag = "LATI", value = latitude),
    tibble(level = 2, tag = "LONG", value = longitude),
    notes %>% bind_rows() %>% add_levels(1)
  )
  
  if (sum(temp$tag == "LATI") == 0) temp <- filter(temp, tag != "MAP")
  if (sum(temp$tag == "LONG") == 0) temp <- filter(temp, tag != "MAP")
  temp
  
}


source_citation <- function(source_ref,
                            page = character(),
                            event_type = character(),
                            role = character(),
                            entry_recording_date = character(),
                            source_text = character(),
                            certainty_assessment = character(),
                            multimedia_links = list(),
                            notes = list()) {
  
  if (length(source_ref) == 0) return(tibble())
  
  page <- as.character(page)
  certainty_assessment <- as.character(certainty_assessment)
  
  if_else(is.numeric(source_ref), 
          validate_input_size(source_ref, 1, 1, 18),
          validate_input_size(source_ref, 1))
  validate_input_size(page, 1, 1, 248)
  validate_input_size(event_type, 1, 1, 15)
  validate_input_size(role, 1, 1, 15)
  validate_input_size(entry_recording_date, 1, 1, 90)
  validate_input_size(certainty_assessment, 1)
  check_certainty_assessment(certainty_assessment)
  
  if (is.numeric(source_ref)) {
    
    temp <- bind_rows(
      tibble(level = 0, tag = "SOUR", value = ref_to_xref(source_ref, "S")),
      tibble(level = 1, tag = "PAGE", value = page),
      tibble(level = 1, tag = "EVEN", value = event_type),
      tibble(level = 2, tag = "ROLE", value = role),
      tibble(level = 1, tag = "DATA", value = ""),
      tibble(level = 1, tag = "DATE", value = entry_recording_date),
      split_text(start_level = 2, top_tag = "TEXT", text = source_text),
      multimedia_links %>% bind_rows() %>% add_levels(1),
      notes %>% bind_rows() %>% add_levels(1),
      tibble(level = 1, tag = "QUAY", value = certainty_assessment)
    ) 
    
    if (sum(temp$tag == "EVEN") == 0) temp <- filter(temp, tag != "ROLE")
    if (sum(temp$tag == "DATE") == 0 & sum(temp$tag == "TEXT") == 0) 
      temp <- filter(temp, tag != "DATA")
    
    temp
    
  } else {
    
    bind_rows(
      split_text(start_level = 0, top_tag = "SOUR", text = source_ref),
      split_text(start_level = 1, top_tag = "TEXT", text = source_text),
      multimedia_links %>% bind_rows() %>% add_levels(1),
      notes %>% bind_rows() %>% add_levels(1),
      tibble(level = 1, tag = "QUAY", value = certainty_assessment)
    )
    
  }
  
}


source_repository_citation <- function(repo_ref,
                                       notes = list(),
                                       call_numbers = character(),
                                       media_type = character()) {
  
  if (length(repo_ref) == 0) return(tibble())
  
  validate_input_size(repo_ref, 1, 1, 18)
  validate_input_size(call_numbers, 1000, 1, 120)
  validate_input_size(media_type, 1)
  check_media_type(media_type)
  # A MEDIA TYPE FOR EVERY CALL NUMBER?
  bind_rows(
    tibble(level = 0, tag = "REPO", value = ref_to_xref(repo_ref, "R")),
    notes %>% bind_rows() %>% add_levels(1),
    tibble(level = 1, tag = "CALN", value = call_numbers),
    tibble(level = 2, tag = "MEDI", value = media_type)
  )
  
}



spouse_to_family_link <- function(family_ref,
                                  notes = list()) {
  
  if (length(family_ref) == 0) return(tibble())
  
  validate_input_size(family_ref, 1, 1, 18)
  
  bind_rows(
    tibble(level = 0, tag = "FAMS", value = ref_to_xref(family_ref, "F")),
    notes %>% bind_rows() %>% add_levels(1)
  )
}


