library(tidyverse)

# load EUHYDI_v1_1.Rdata
version <- "v1.1.0"
p2h <- readline("Path to EUHYDI_v1_1_csv: ")
files <- dir(p2h)
for (f in files) {
  name <- sub(".csv", "", f) %>% tolower()
  expres <- parse(text = paste0(name, "<- read_csv(file.path(p2h, f))"), keep.source = FALSE, encoding = "UTF-8")
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
  "Houskova_HYPRES",
  "Houskova",
  "Anaya",
  "Cranfield"
)

status$source %in% sources

# which sources need to be extracted?
exp_sources <- status %>% filter(and_hereby == "accept" & !grepl("waiting", tolower(comments))) %>% select(source)
status %>% filter(and_hereby == "accept" & !grepl("waiting", tolower(comments))) %>% select(source,email_sent, contributi)
# from which of those sources must we remove the geographical coordinates?
exp_nogeog <- status %>% filter(grepl("without", comments) & and_hereby == "accept") %>% select(source)

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


## prepare for export
hydi <- vector("list", length(files))
names(hydi) <- gsub(".csv","",files)
for (f in files){
  name = sub(".csv","",f)
  eval(parse(text = paste0("hydi[[name]] <- ", tolower(name))))
}

## filter sources
filter_fun <- function(df){
  if ("SOURCE" %in% names(df)) {
    return(df %>% dplyr::filter(SOURCE %in% exp_sources$source))
    }
  else {
    return (df)
    }
}

exp_hydi <- lapply(hydi, filter_fun)

set_na <- function(x){
  if (is.character(x)) {
    x[] = "ND"
  } else {
    x[] <- -999
  }
}

# remove coord
gen_nogeog <- exp_hydi$GENERAL %>%
  filter(SOURCE %in% exp_nogeog$source) %>%
  mutate(across(LOC_COOR_X:Y_WGS84, set_na)) %>%
  mutate(COMMENTS_PBL = "Coordinates removed from public version.")

exp_hydi$GENERAL <- 
  bind_rows(
    exp_hydi$GENERAL %>% 
      mutate(COMMENTS_PBL = "ND") %>% 
      filter(! SOURCE %in% exp_nogeog$source),
    gen_nogeog
  ) %>%
  arrange(SOURCE, PROFILE_ID) 


# export to csv
if (!dir.exists(paste0("./EUHYDI_public_",version,"_csv"))) {dir.create(paste0("./EUHYDI_public_", version, "_csv"))}
for (name in names(hydi)){
  # use write_excel_csv to include a UTF-8 Byte order mark which indicates to Excel the csv is UTF-8 encoded
  write_excel_csv(
    exp_hydi[[name]],
    file = paste0("./EUHYDI_public_", version, "_csv/", name, ".csv"),
    )
}

# copy references and metadata from "../EUHYDI_v1_1_csv"
file.copy(from = paste0(p2h,"/METADATA.csv"), to = paste0("./EUHYDI_public_", version, "_csv/METADATA.csv"))
file.copy(from = paste0(p2h,"/REFERENCES.csv"), to = paste0("./EUHYDI_public_", version, "_csv/REFERENCES.csv"))


# Norway
institutions <- tibble(Contributor = c(
    "Norway: Bioforsk Soil and Environment",
    "Norway: Bioforsk Soil and Environment",
    "Norway: Norwegian Forest and Landscape Institute",
    "Norway: Norwegian University of Life Sciences",
    "Norway: Nowegian Water Resources and Energy Directorate",
    "Spain: Evenor-Tech",
    "Greece: Aristotle University of Thessaloniki",
    "Belgium: Ghent University",
    "United Kingdom: Cranfield University",
    "France: INRA, Orléans",
    "Portugal: Instituto Nacional de Investigação Agrária e Veterinária",
    "Germany: BGR",
    "Slovakia: Soil Science and Conservation Research Institute",
    "Slovakia: Soil Fertility Research Institute",
    "Italy: University of Palermo",
    "Belgium: Earth and Life Institute, UCLouvain",
    "Sweden: Swedish University of Agricultural Sciences",
    "Poland: Institute of Agrophysics, Polish Academy of Sciences, Lublin",
    "United Kingdom: James Hutton Institute",
    "Hungary: University of Pannonia",
    "Czechia: Czech University of Life Science in Prague",
    "Italy: University of Padova",
    "Ukraine: National Scientific Center, Institute for Soil Science and Agrochemistry Research named after ON Sokolovskiy, Kharkiv",
    "Italy: University of Naples Federico II",
    "Italy: University of Naples Federico II",
    "Germany: ZALF Müncheberg",
    "Germany: ZALF Müncheberg",
    "Germany: ZALF Müncheberg",
    "Russian Federation: Moscow State University",
    "Austria: Federal Agency for Water Management",
    "Netherlands: Wageningen University"
  ), CONTACT_A = c(
    "Bioforsk East, Apelsvoll, Nylinna 226, N-2849 KAPP",
    "Bioforsk Soil and Environment, Frederik A. Dahls vei 20, N-1432 Ås",
    "Skog & Landskap, P.O. Box 115, N-1431 Ås",
    "Norwegian University of Life Sciences, Department of Plant and Environmental Sciences, P.O. Box 5003, N-1432 Ås",
    "Norwegian Water Resources and Energy Directorate, P.O. Box 5091 Majorstua, N-0301 Oslo",
    "Evenor-Tech, CSIC Spin-off, Instituto de Recursos Naturales y Agrobiologia de Sevilla (CSIC), Avda. Reina Mercedes,10, 41012, Spain",
    "Laboratory of Applied Soil Science, School of Agriculture, Aristotle University of Thessaloniki, 54124 Thessaloniki, Greece",                                   
    "Ghent University",
    "Bullock Building, Cranfield University, Cranfield, Bedfordshire, MK43 0PL",
    "INRA, Orléans, France",
    "Instituto Nacional de Investigação Agrária e Veterinária, Av. Republica, 2784-505 Oeiras, Portugal",
    "Federal Institute for Geosciences and Natural Resources, BGR, Alfred-Bentz-Haus, Stilleweg 2, 30655 Hannover",
    "VUPOP",
    "Soil Fertility Research Institute, Gagarinova 10, 827 13 Bratislava, Slovakia. Fax:+42 7 295 487",
    "Dipartimento dei Sistemi Agro-Ambientali, Università degli Studi di Palermo",
    "Earth and Life Institute, Université catholique de Louvain",
    "Swedish University of Agricultural Sciences",
    "Institute of Agrophysics, Polish Academy of Sciences, Lublin",
    "James Hutton Institute, Craigiebuckler, Aberdeen",
    "Pannon Egyetem Georgikon Kar, Növénytermesztéstani és Talajtani Tanszék, H-8360 Keszthely Deák F. u. 16.",
    "CULS Prague, Kamycka 129, Praha 6, 16521, CZ",
    "Universitá di Padova",
    "NSC ISSAR, Chaikovska str.,№4, Kharkiv, Ukraine 61024, tel: +380577041665; +380954011107",
    "University of Naples Federico II",
    "Institute of Agricultural Hydraulics, University of Naples \"Frederico II\", Universita 100, 80055 Portici, Napoli, Italy. tel: +39 81 488954",
    "ZALF",
    "Inst. of Hydrology, Centre for Research on Agric.Landscapes & Land Use (ZALF) e.V., 0-1278 Muncheberg, W.-Pieck-Str. 72 Germany. Tel: (033-432)82300",
    "Zentrum fur Agarlandschafts-und Landnutzungsforschung(ZALF), Institut fur Bodenlandschaftsforschung, Eberswalder Str 84, 15374 Muncheberg. Fax 49 033432-82289",
    "Moscow State University",
    "Federal Agency for Water Management",
    "Wageningen University & Research"
    )
)
general %>% filter(SOURCE == "Kvaerno") %>% group_by(CONTACT_A) %>% count() %>% left_join(norway) %>% dplyr::select(!(CONTACT_A))

# table status
tbl <- status %>%
    select(contributi, and_hereby, license_fi, comments, source) %>%   full_join(general %>% 
               group_by(SOURCE) %>%
               # count(substr(CONTACT_A, start=1, stop=30)) %>%
               count(CONTACT_A) %>%
               # count(SOURCE) %>%
               rename(`N profiles` = "n") %>%
               full_join(institutions),
             by = c("contributi" = "Contributor", "source" = "SOURCE")
             ) %>%
    left_join(
            basic %>%
              select(SAMPLE_ID, PROFILE_ID, SOURCE) %>%
              # group_by(SOURCE) %>%
              left_join(general %>% select(PROFILE_ID, CONTACT_A)) %>%
              count(CONTACT_A) %>% 
              rename(`N samples` = "n"),
            # by = c("source" = "SOURCE")
            ) %>%
  select(- CONTACT_A) %>%
  mutate(Access = if_else(
                    and_hereby == "accept" & !grepl("waiting", tolower(comments)), 
                    true = "public", 
                    false = "restricted", 
                    missing = "restricted"
                    ),
         .after = contributi) %>%
  select(- and_hereby) %>%
  rename(Contributor = contributi,
         Licence_File = license_fi,
         Comment = comments,
         `Source in HYDI` = source) %>%
  group_by(Contributor, Access, `Source in HYDI`) %>%
  summarise(`N profiles` = sum(`N profiles`), `N samples` = sum(`N samples`)) %>%
  arrange(Access, Contributor) 

knitr::kable(tbl, caption = "Status of EU-HYDI contributions")
knitr::kable(tbl, format = "html", caption = "Status of EU-HYDI contributions")
