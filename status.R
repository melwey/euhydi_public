library(tidyverse)

# load HYDI_SOURCE_nd_qa3.Rdata
p2h <- readline("Path to HYDI_SOURCE_nd_qa3.Rdata")
load(p2h)
for (name in names(hydi)){
  expres <- parse(text = paste0(tolower(name), " <- hydi$", name), keep.source = FALSE)
  print(expres)
  eval(expres)
}

# load license status EUHYDI_License/status_20210512.xlsx
p2l <- readline("Path to EUHYDI_License status file (xlsx)")
status <- readxl::read_xlsx(
  p2l,
  skip = 2
  ) %>%
  # lower case, remove spaces and restrict name to 10 char 
  rename_with(~ tolower(gsub(" ", "_", .x, fixed = TRUE)) %>% substr(1,10)) 

# agreed + license
status %>% filter(and_hereby == "accept" & !is.na(please_upl)) %>% select(email_sent, contributi)
# missing license files?
status %>% filter(and_hereby == "accept" & !is.na(please_upl) & is.na(license_fi)) %>% select(email_sent, contributi)
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
status %>% filter(and_hereby == "accept" & !grepl("waiting", tolower(comments))) %>% select(source,email_sent, contributi)
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
if (!dir.exists("./euhydi_public_csv")) {dir.create("./euhydi_public_csv")}
for (name in names(hydi.na)){
  write_csv(exp_hydi[[name]], paste0("./euhydi_public_csv/", name, ".csv"))
}

# copy references and metadata from "../EU_HYDI/HYDI_SOURCE_nd_qa3_csv"
file.copy(from = "../EU_HYDI/HYDI_SOURCE_nd_qa3_csv/METADATA.csv", to = "./euhydi_public_csv/METADATA.csv")
file.copy(from = "../EU_HYDI/HYDI_SOURCE_nd_qa3_csv/REFERENCES.csv", to = "./euhydi_public_csv/REFERENCES.csv")


# Norway
general %>% filter(SOURCE == "Kvaerno") %>% group_by(CONTACT_P) %>% count()

# table status
tbl <- status %>%
  select(contributi, and_hereby, license_fi, comments, source) %>%
  left_join(general %>% 
              # group_by(SOURCE, ISO_COUNTRY) %>%
              # count(substr(CONTACT_A, start=1, stop=30)) %>%
              count(SOURCE) %>%
              rename("n_profiles" = "n"),
            by = c("source" = "SOURCE")
            ) %>% 
  left_join(basic %>% 
              count(SOURCE) %>% 
              rename("n_samples" = "n"),
            by = c("source" = "SOURCE")) %>%
  mutate(Access = if_else(and_hereby == "accept" & !grepl("waiting", tolower(comments)), true = "public", false = "restricted", missing = "restricted"),
         .after = contributi) %>%
  select(- and_hereby) %>%
  arrange(Access, contributi) %>%
  rename(Contributor = contributi,
         Licence_File = license_fi,
         Comment = comments)
knitr::kable(tbl, format = "html", caption = "Status of EU-HYDI contributions")
