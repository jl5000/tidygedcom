# Generated by roxytest: Do not edit by hand!

# File R/individual_links.R: @tests

test_that("Function add_indi_association() @ L23", {
  expect_snapshot_value(gedcom(subm("Me")) %>% 
                          add_indi(qn = "Joe Bloggs") %>% 
                          add_indi(qn = "Jimmy Bloggs") %>% 
                          add_indi_association(associated_with = "Joe", association = "Friend") %>% 
                          tidyged.internals::remove_dates_for_tests(), "json2")
})

