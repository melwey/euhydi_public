library(tidyverse)

# load hydi.na
load("../EUHYDI_NA_v1_1.Rdata")
for (name in names(hydi.na)){
  expres <- parse(text = paste0(tolower(name), " <- hydi.na$", name), keep.source = FALSE)
  print(expres)
  eval(expres)
}

# load license status
status <- readxl::read_xlsx(
  "../EUHYDI_License/status_20210512.xlsx",
  skip = 2
  ) %>%
  # lower case, remove spaces and restrict name to 10 char 
  rename_with(~ tolower(gsub(" ", "_", .x, fixed = TRUE)) %>% substr(1,10)) 

# agreed + license
status %>% filter(and_hereby == "accept" & !is.na(please_upl)) %>% select(email_sent, contributi)
# agreed + no license
status %>% filter(and_hereby == "accept" & is.na(please_upl)) %>% select(email_sent, contributi)
# waiting for statement
status %>% filter(grepl("waiting", comments)) %>% select(email_sent, contributi)
# no response
status %>% filter(grepl("reminder", comments) & !grepl("waiting", comments) & is.na(and_hereby)) %>% select(email_sent, contributi)
# negative
status %>% filter(and_hereby == "do not accept") %>% select(email_sent, contributi)

# match hydi SOURCE to status$email_sent
sources <- basic$SOURCE %>% unique()
# manually set sources
print(status$email_sent)
status$source <- c(
  "Javaux",
  "Cornelis",
  "Schindler_HYPRES",
  "Schindler",
  "Mako",
  "Iovino",
  "Wosten_HYPRES",
  "Lamorski",
  "Shein",
  "Katterer",
  "Patyka",
  "Lilly",
  "Strauss",
  "Matula",
  "Daroussin",
  "Hennings_HYPRES",
  "Bilas",
  "Romano",
  "Morari",
  "Kvaerno",
  "Kvaerno",
  "Kvaerno",
  "Kvaerno",
  "Goncalves",
  "Houskova",
  "Houskova_HYPRES",
  "Anaya",
  "Cranfield"
)
status$source %in% sources

# which sources need to be extracted?
exp_sources <- status %>% filter(and_hereby == "accept" & !grepl("waiting", tolower(comments))) %>% select(source)
# from which of those sources must we remove the geographical coordinates?
exp_nogeog <- status %>% filter(grepl("without", comments) & and_hereby == "accept") %>% select(source)

# total number of samples by source
basic %>% count(SOURCE)

# How many Ksat?
# extract Ksat
Ksat <- cond[cond$IND_VALUE==1 & cond$VALUE==0,]
KsatSelect <- Ksat %>% 
  left_join(method, by = c("COND_M" = "CODE_M")) %>%
  select(-COND_M, -METH_REF) %>%
  count(SOURCE, METHOD) %>% 
  left_join(status %>% select(source, and_hereby, comments), by = c("SOURCE" = "source")) %>%
  arrange(and_hereby) %>%
  # View()
  filter(and_hereby == "accept")
sum(KsatSelect$n)

# unique sample_id
Ksat %>%
  select(SAMPLE_ID) %>%
  unique() %>%
  nrow()
Ksat %>%
  select(PROFILE_ID) %>%
  unique() %>%
  nrow()

## filter sources
filter_fun <- function(df){
  if ("SOURCE" %in% names(df)) {
    return(df %>% dplyr::filter(SOURCE %in% exp_sources$source))
    }
  else {
    return (df)
    }
}

exp_hydi <- lapply(hydi.na, filter_fun)

set_na <- function(x){x[] <- NA}

# remove coord
gen_nogeog <- exp_hydi$GENERAL %>%
    filter(SOURCE %in% exp_nogeog$source) %>%
    mutate(across(LOC_COOR_X:Y_WGS84, set_na))

exp_hydi$GENERAL <- 
  bind_rows(
    exp_hydi$GENERAL %>% filter(! SOURCE %in% exp_nogeog$source),
    gen_nogeog
  ) %>%
  arrange(SOURCE, PROFILE_ID) 


# export to csv
for (name in names(hydi.na)){
  write_csv(exp_hydi[[name]], paste0("./csv/", tolower(name), ".csv"))
}
