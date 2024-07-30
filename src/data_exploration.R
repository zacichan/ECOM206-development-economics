library(tidyverse)
library(stargazer)

# Summary Statistics for Key Variables ---- 

summary_stats <- cleaned_data %>%
  summarise(
    mean_aid_gni = mean(aid_gni, na.rm = TRUE),
    median_aid_gni = median(aid_gni, na.rm = TRUE),
    sd_aid_gni = sd(aid_gni, na.rm = TRUE),
    mean_gdp_per_capita = mean(gdp_per_capita, na.rm = TRUE),
    median_gdp_per_capita = median(gdp_per_capita, na.rm = TRUE),
    sd_gdp_per_capita = sd(gdp_per_capita, na.rm = TRUE)
  )

# Convert the summary statistics to a matrix for stargazer
summary_matrix <- as.matrix(summary_stats)

stargazer(summary_matrix, type = "text", summary = FALSE, title = "Summary Statistics for Key Variables")


# Grouped Summary Statistics by Country ----

# Calculate GDP growth rate
cleaned_data <- cleaned_data %>%
  group_by(country_name) %>%
  arrange(year) %>%
  mutate(gdp_growth = (gdp_per_capita - lag(gdp_per_capita)) / lag(gdp_per_capita) * 100) %>%
  ungroup()

# Compute the mean GDP growth rate by country
grouped_summary <- cleaned_data %>%
  group_by(country_name) %>%
  summarise(
    mean_aid_gni = mean(aid_gni, na.rm = TRUE),
    mean_gdp_per_capita = mean(gdp_per_capita, na.rm = TRUE),
    mean_gdp_growth = mean(gdp_growth, na.rm = TRUE)
  ) %>%
  arrange(desc(mean_gdp_growth)) %>%
  as.data.frame()

# Print the summary using stargazer
stargazer(grouped_summary, type = "text", title = "Grouped Summary Statistics by Country")

# Summary Table for Aid and GDP per Capita

aid_gdp_summary <- cleaned_data %>%
  group_by(country_name) %>%
  summarise(
    mean_aid_gni = mean(aid_gni, na.rm = TRUE),
    mean_gdp_per_capita = mean(gdp_per_capita, na.rm = TRUE)
  ) %>%
  arrange(desc(mean_aid_gni)) %>%
  as.data.frame()

# Using stargazer for the Aid and GDP per capita summary table
stargazer(aid_gdp_summary, type = "text", title = "Summary Table for Aid and GDP per Capita by Country", summary = FALSE)

