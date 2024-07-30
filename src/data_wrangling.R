# Load necessary libraries
library(tidyverse)
library(fixest)
library(readr)

# Load the data sets
oecd_dac <- read_csv('./data/raw/OECD_DAC.csv', skip = 4, col_names = TRUE)
weo_data <- read_csv('./data/raw/WEO_Data.csv')
world_bank_cpia <- read_csv('./data/raw/World_Bank_CPIA.csv', skip = 4, col_names = TRUE)

# Transform OECD_DAC data
oecd_dac_filtered <- oecd_dac %>% select(-`...69`)
oecd_dac_melted <- oecd_dac_filtered %>% 
  pivot_longer(cols = starts_with("19") | starts_with("20"), names_to = "Year", values_to = "Aid_GNI") %>% 
  filter(!is.na(Aid_GNI)) %>%
  mutate(Year = as.integer(Year))

# Transform World_Bank_CPIA data
world_bank_cpia_filtered <- world_bank_cpia %>% select(-`...69`)
world_bank_cpia_melted <- world_bank_cpia_filtered %>% 
  pivot_longer(cols = starts_with("19") | starts_with("20"), names_to = "Year", values_to = "CPIA_Score") %>% 
  filter(!is.na(CPIA_Score)) %>%
  mutate(Year = as.integer(Year))

# Transform WEO_Data data to handle different GDP measurements
weo_data_melted <- weo_data %>% 
  pivot_longer(cols = starts_with("19") | starts_with("20"), names_to = "Year", values_to = "Value") %>%
  filter(!is.na(Value)) %>%
  mutate(Year = as.integer(Year)) %>%
  unite("Measurement", `Subject Descriptor`, Units, sep = "_", remove = FALSE) %>%
  pivot_wider(names_from = Measurement, values_from = Value)

# Convert Value columns to numeric, forcing non-numeric values to NA
weo_data_melted <- weo_data_melted %>% 
  mutate(across(starts_with("Gross domestic product"), ~ as.numeric(gsub(",", "", .))))

# Get initial income (real GDP per capita in the first non-NA year for each country)
initial_gdp_per_capita <- weo_data_melted %>%
  group_by(Country) %>%
  arrange(Year) %>%
  filter(!is.na(`Gross domestic product per capita, constant prices_National currency`)) %>%
  slice(1) %>%
  summarise(Initial_Income = log(`Gross domestic product per capita, constant prices_National currency`)) %>%
  ungroup()


# Merge data sets
merged_data <- oecd_dac_melted %>% 
  inner_join(world_bank_cpia_melted, by = c("Country Name", "Country Code", "Year")) %>%
  inner_join(weo_data_melted, by = c("Country Name" = "Country", "Year")) %>%
  rename(
    CPIA_Score = CPIA_Score,
    Aid_GNI = Aid_GNI
  ) %>%
  inner_join(initial_gdp_per_capita, by = c("Country Name" = "Country"))

# Perform necessary calculations
conversion_rate <- 1.2
merged_data <- merged_data %>% 
  mutate(
    Aid_GDP = Aid_GNI / conversion_rate,
    Aid_GDP_squared = Aid_GDP ^ 2,
    GDP_per_capita = as.numeric(`Gross domestic product per capita, constant prices_National currency`)
  ) %>%
  filter(!is.na(GDP_per_capita)) %>%
  mutate(
    Policy_Aid_GDP = CPIA_Score * Aid_GDP
  ) 


# Tests to ensure everything is merged correctly
# Check if any country-year combinations are missing in the merged data
expected_rows <- nrow(oecd_dac_melted) + nrow(world_bank_cpia_melted) + nrow(weo_data_melted)
actual_rows <- nrow(merged_data)
cat("Expected number of rows after merging:", expected_rows, "\n")
cat("Actual number of rows after merging:", actual_rows, "\n")

# Summary statistics about missing/incomplete data fields
missing_data_summary <- merged_data %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "Field", values_to = "Missing_Count")

cat("Summary of missing data fields:\n")
print(missing_data_summary)

# Checking completeness
complete_cases <- sum(complete.cases(merged_data))
total_cases <- nrow(merged_data)
cat("Number of complete cases:", complete_cases, "\n")
cat("Total number of cases:", total_cases, "\n")
cat("Proportion of complete cases:", complete_cases / total_cases, "\n")

# Final Cleaning

# Rename columns using tidyverse conventions
cleaned_data <- merged_data %>%
  rename(
    country_name = `Country Name`,
    country_code = `Country Code`,
    indicator_name = `Indicator Name.x`,
    indicator_code = `Indicator Code.x`,
    year = `Year`,
    aid_gni = `Aid_GNI`,
    indicator_name_y = `Indicator Name.y`,
    indicator_code_y = `Indicator Code.y`,
    cpia_score = `CPIA_Score`,
    subject_descriptor = `Subject Descriptor`,
    units = `Units`,
    scale = `Scale`,
    country_series_specific_notes = `Country/Series-specific Notes`,
    estimates_start_after = `Estimates Start After`,
    gdp_per_capita_constant_national = `Gross domestic product per capita, constant prices_National currency`,
    gdp_per_capita_constant_ppp = `Gross domestic product per capita, constant prices_Purchasing power parity; 2017 international dollar`,
    gdp_per_capita_current_national = `Gross domestic product per capita, current prices_National currency`,
    gdp_per_capita_current_usd = `Gross domestic product per capita, current prices_U.S. dollars`,
    initial_income = `Initial_Income`,
    aid_gdp = `Aid_GDP`,
    aid_gdp_squared = `Aid_GDP_squared`,
    gdp_per_capita = `GDP_per_capita`,x
    policy_aid_gdp = `Policy_Aid_GDP`
  ) %>%
  # Remove duplicate columns
  select(-contains(".y"))

# View cleaned data
cleaned_data



