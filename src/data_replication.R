# Load necessary libraries
library(tidyverse)
library(fixest)
library(readr)
library(fuzzyjoin)
library(modelsummary)

# 1: Load the datasets ----
# Make sure to update the file paths with the actual paths to your datasets

# CPIA Scores
cpia <- read_csv('./data/raw/World_Bank_CPIA.csv', skip = 4, col_names = TRUE) %>%
  # Gather all the year columns into key-value pairs
  pivot_longer(cols = starts_with("19") | starts_with("20"),
               names_to = "Year",
               values_to = "CPIA") %>%
  # Convert Year from character to numeric
  mutate(Year = as.numeric(Year)) %>%
  # Remove rows with NA CPIA values
  filter(!is.na(CPIA)) %>%
  # Select only necessary columns
  select(Country = `Country Name`, Year, CPIA)

# Aid Data
aid <- read_csv('./data/raw/OECD_DAC.csv', skip = 4, col_names = TRUE) %>%
  # Gather all the year columns into key-value pairs
  pivot_longer(cols = starts_with("19") | starts_with("20"),
               names_to = "Year",
               values_to = "ODA_GDP") %>%
  # Convert Year from character to numeric
  mutate(Year = as.numeric(Year)) %>%
  # Remove rows with NA ODA_GDP values
  filter(!is.na(ODA_GDP)) %>%
  # Select only necessary columns
  select(Country = `Country Name`, Year, ODA_GDP)

# Growth Data
growth <- read_csv('./data/raw/WEO_Data.csv') %>%
  filter(`Subject Descriptor` == "Gross domestic product per capita, constant prices",
         Units == "Purchasing power parity; 2017 international dollar") %>%
  # Gather all the year columns into key-value pairs
  pivot_longer(cols = `1980`:`2029`,
               names_to = "Year",
               values_to = "GNP_per_capita") %>%
  # Convert Year from character to numeric
  mutate(Year = as.numeric(Year),
         # Convert GNP_per_capita from character to numeric, handling "n/a" values
         GNP_per_capita = as.numeric(gsub(",", "", GNP_per_capita))) %>%
  # Remove rows with NA GNP_per_capita values
  filter(!is.na(GNP_per_capita)) %>%
  # Select only necessary columns
  select(Country, Year, GNP_per_capita) %>%
  arrange(Country, Year) %>%
  group_by(Country) %>%
  mutate(Growth = (GNP_per_capita - lag(GNP_per_capita)) / lag(GNP_per_capita) * 100) %>%
  # Remove the first year for each country since it won't have a growth rate
  filter(!is.na(Growth)) %>%
  ungroup()


# Initial Income Data
initial_income <- read_csv('./data/raw/WEO_Data.csv') %>%
  filter(`Subject Descriptor` == "Gross domestic product per capita, constant prices",
         Units == "Purchasing power parity; 2017 international dollar") %>%
  # Gather all the year columns into key-value pairs
  pivot_longer(cols = `1980`:`2029`,
               names_to = "Year",
               values_to = "Initial_GNP_per_capita") %>%
  # Convert Year from character to numeric
  mutate(Year = as.numeric(Year),
         # Convert Initial_GNP_per_capita from character to numeric, handling "n/a" values
         Initial_GNP_per_capita = as.numeric(gsub(",", "", Initial_GNP_per_capita))) %>%
  # Remove rows with NA Initial_GNP_per_capita values
  filter(!is.na(Initial_GNP_per_capita)) %>%
  # Select 2005 as the baseline income
  filter(Year == 2005) %>%
  # Select only necessary columns
  select(Country, Year, Initial_GNP_per_capita)

# Institutional Quality Data
institutional_quality <- read_csv("./data/raw/Corruption_Worldwide_Governance_Indicators.csv", col_names = TRUE) %>% 
  select(1:12) %>%
  filter(complete.cases(.)) %>%
  # Gather all the year columns into key-value pairs
  pivot_longer(cols = starts_with("20"),
               names_to = "Year",
               values_to = "Institutional_Quality") %>%
  # Extract the year from the column names and convert it to numeric
  mutate(Year = as.numeric(sub("\\s\\[.*\\]", "", Year)),
         # Convert Institutional_Quality from character to numeric
         Institutional_Quality = as.numeric(Institutional_Quality)) %>%
  # Remove rows with NA Institutional_Quality values
  filter(!is.na(Institutional_Quality)) %>%
  # Select only necessary columns
  select(Country = `Country Name`, Year, Institutional_Quality)

# TODO
# Regional Dummies
# regional_dummies <- read_csv("path_to_regional_dummies.csv")

# 2: Merge the datasets ----
# Ensure consistency in country names and years across all datasets
# We'll use a full join to merge all datasets into one

# Function to print merge success summary
print_merge_summary <- function(original_data, merged_data, step_name) {
  original_count <- nrow(original_data)
  merged_count <- nrow(merged_data)
  cat(sprintf("%s - Original rows: %d, Rows after merge: %d, Proportion retained: %.2f%%\n",
              step_name, original_count, merged_count, (merged_count / original_count) * 100))
}

# Initial dataset sizes
cat("Initial dataset sizes:\n")
cat("cpia:", nrow(cpia), "\n")
cat("growth:", nrow(growth), "\n")
cat("aid:", nrow(aid), "\n")
cat("initial_income:", nrow(initial_income), "\n")
cat("institutional_quality:", nrow(institutional_quality), "\n\n")

# Step 1: Merge CPIA and Growth using fuzzy join 
merged_data <- stringdist_inner_join(cpia, growth, by = c("Country", "Year"), method = "jw", max_dist = 0.1) 

# Inspect intermediate result after first join
cat("Intermediate result after Step 1:\n")
glimpse(merged_data)

# Clean intermediate result
merged_data <- merged_data %>%
  filter(Year.x == Year.y) %>%
  filter(!is.na(Year.y) & !is.na(Country.y)) %>%
  select(Country = Country.x, Year = Year.x, CPIA, GNP_per_capita, Growth)
print_merge_summary(cpia, merged_data, "Step 1: cpia + growth")

# Step 2: Merge with Aid using fuzzy join
merged_data <- stringdist_left_join(merged_data, aid, by = c("Country", "Year"), method = "jw", max_dist = 0.1)

# Inspect intermediate result after second join
cat("Intermediate result after Step 2:\n")
glimpse(merged_data)

# Clean intermediate result
merged_data <- merged_data %>%
  filter(Year.x == Year.y) %>%
  filter(!is.na(Year.y) & !is.na(Country.y)) %>%
  select(Country = Country.x, Year = Year.x, CPIA, GNP_per_capita, Growth, ODA_GDP)
print_merge_summary(cpia, merged_data, "Step 2: merged_data + aid")

# Step 3: Merge with Initial Income using fuzzy join
merged_data <- stringdist_left_join(merged_data, initial_income, by = c("Country"), method = "jw", max_dist = 0.1)

# Inspect intermediate result after third join
cat("Intermediate result after Step 3:\n")
glimpse(merged_data)

# Clean intermediate result
merged_data <- merged_data %>%
  filter(!is.na(Year.y) & !is.na(Country.y)) %>%
  select(Country = Country.x, Year = Year.x, CPIA, GNP_per_capita, Growth, Initial_GNP_per_capita, ODA_GDP)
print_merge_summary(cpia, merged_data, "Step 3: merged_data + initial_income")

# Step 4: Merge with Institutional Quality using fuzzy join
merged_data <- stringdist_left_join(merged_data, institutional_quality, by = c("Country", "Year"), method = "jw", max_dist = 0.1)

# Inspect intermediate result after fourth join
cat("Intermediate result after Step 4:\n")
glimpse(merged_data)

# Clean intermediate result
merged_data <- merged_data %>%
  filter(ifelse(is.na(Year.y), TRUE, Year.x == Year.y)) %>%
  select(Country = Country.x, Year = Year.x, CPIA, GNP_per_capita, Growth, ODA_GDP, Initial_GNP_per_capita, Institutional_Quality)
print_merge_summary(cpia, merged_data, "Step 4: merged_data + institutional_quality")

# Step 5: Create Region Dummies
# Create the region lookup table in R
region_lookup <- read_csv("data/raw/region_lookup_corrected.csv")

# Merge the region lookup data with the merged_data dataframe
merged_data <- merged_data %>%
  left_join(region_lookup, by = "Country")

# Create dummy variables for the 'Region' column using pivot_wider
merged_data <- merged_data %>%
  mutate(Region = as.factor(Region)) %>%
  pivot_wider(names_from = Region, values_from = Region, values_fn = length, values_fill = list(Region = 0))


# Final dataset size
cat("\nFinal merged dataset size:\n")
cat("Rows in merged dataset:", nrow(merged_data), "\n\n")

write.csv(merged_data, "data/processed/final_data.csv")


# 3: Create plots ----

# Summarize the data by country
summarised_data <- merged_data %>%
  group_by(Country) %>%
  summarize(
    average_GNP_per_capita = mean(GNP_per_capita, na.rm = TRUE),
    average_CPIA = mean(CPIA, na.rm = TRUE)
  )

# Identify countries with the highest and lowest average GNP_per_capita and CPIA
high_gnp_countries <- summarised_data %>% top_n(1, average_GNP_per_capita)
low_gnp_countries <- summarised_data %>% top_n(-1, average_GNP_per_capita)
high_cpia_countries <- summarised_data %>% top_n(1, average_CPIA)
low_cpia_countries <- summarised_data %>% top_n(-1, average_CPIA)

# Combine the identified countries to label
label_countries <- rbind(high_gnp_countries, low_gnp_countries, high_cpia_countries, low_cpia_countries) %>%
  distinct(Country, .keep_all = TRUE)

# Create the scatter plot using ggplot2
ggplot(summarised_data, aes(x = average_CPIA, y = average_GNP_per_capita, label = Country)) +
  geom_point(alpha = 0.6, color = 'blue', size = 3) +
  geom_text(data = label_countries, aes(label = Country), vjust = -0.5, hjust = 0.5, size = 3) +
  geom_smooth(method = 'lm', col = 'red', linetype = 'dashed') +
  labs(title = 'Average CPIA vs. Average GNP per Capita by Country',
       x = 'Average CPIA',
       y = 'Average GNP per Capita') +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5, family = "serif"), 
        axis.title = element_text(face = "bold", family = "serif"),
        text = element_text(family = "serif"))

# 4: Estimate the regression model ----
# The model is: G = c + b1*X + b2*P + b3*A + b4*A^2 + b5*AP
# where:
# G = Growth rate of per capita GNP
# X = Exogenous conditions (initial income, institutional quality, regional dummies)
# P = Policy measure (CPIA)
# A = Aid as a percentage of GDP
# A^2 = Squared term of aid to capture diminishing returns
# AP = Interaction term between aid and policy


# Create new variables for the model
merged_data <- merged_data %>%
  mutate(A_squared = ODA_GDP^2,
         AP_interaction = ODA_GDP * CPIA)

# Define the first regression model (OLS)
model_ols <- lm(Growth ~ Initial_GNP_per_capita + CPIA + ODA_GDP + A_squared + AP_interaction +
                  `East Asia/Pacific` + `Europe/Central Asia` + `Latin America/Caribbean` + 
                  `Sub-Saharan Africa` + `South Asia`, data = merged_data)

# Define the second model with fixed effects (FE)
model_fe <- feols(Growth ~ CPIA + ODA_GDP + A_squared + AP_interaction | Country + Year, data = merged_data)

# Summary with Driscoll-Kraay standard errors
model_fe_summary <- summary(model_fe, driscoll_kraay ~ Year)

# Add sample size to the model summary
model_ols_summary <- summary(model_ols)
n_obs_ols <- nobs(model_ols)

n_obs_fe <- model_fe_summary$nobs

# Define custom formatting function
custom_format <- function(x) {
  format(round(x, 3), nsmall = 3, scientific = FALSE)
}

# Define custom coefficient names
coef_names <- c(
  "(Intercept)" = "Constant",
  "Initial_GNP_per_capita" = "Initial GDP per Capita",
  "CPIA" = "Policy Measure (CPIA)",
  "ODA_GDP" = "Aid as % of GDP",
  "A_squared" = "Aid Squared",
  "AP_interaction" = "Aid * Policy Interaction",
  "`East Asia/Pacific`" = "East Asia/Pacific",
  "`Europe/Central Asia`" = "Europe/Central Asia",
  "`Latin America/Caribbean`" = "Latin America/Caribbean",
  "`Sub-Saharan Africa`" = "Sub-Saharan Africa",
  "`South Asia`" = "South Asia"
)

# Create the model summary with enhanced formatting
modelsummary(list("OLS Model" = model_ols, "Fixed Effects Model" = model_fe_summary),
             coef_map = coef_names,
             stars = c('*' = .1, '**' = .05, '***' = .01),
             statistic = "std.error",
             fmt = custom_format,
             gof_omit = "AIC|BIC",
             output = "markdown",
             title = "Regression Models: Determinants of GDP Growth",
             notes = paste0("Standard errors in parentheses. Significance levels: *** p < 0.01, ** p < 0.05, * p < 0.1.",
                            "\nNumber of observations (OLS): ", n_obs_ols,
                            "\nNumber of observations (FE): ", n_obs_fe)
)


