# Load necessary libraries
library(tidyverse)
library(fixest)

# Prepare the data
cleaned_data <- cleaned_data %>%
  mutate(
    aid_gni_squared = aid_gni^2,
    interaction_term = cpia_score * aid_gni
  )

# Specify and estimate the fixed effects model
model <- feols(
  gdp_per_capita ~ cpia_score + aid_gni + aid_gni_squared + interaction_term | country_name + year,
  data = cleaned_data
)

# Print the summary of the model
summary(model, driscoll_kraay ~ year)

# Summary of Regression Results Interpretation:

# 1. Policy Quality (cpia_score):
#    - Coefficient: 956.50377 (thousands of dollars)
#    - Interpretation: A one-unit increase in the CPIS score (policy quality) is 
#      associated with an increase of approximately $956.50 in GDP per capita, 
#      holding other factors constant.

# 2. Aid as a Percentage of GDP (aid_gni):
#    - Coefficient: 77.24147 (thousands of dollars)
#    - Interpretation: A one-percentage-point increase in aid as a percentage of 
#     GDP is associated with an increase of approximately $77.24 in GDP per 
#     capita, holding other factors constant.

# 3. Aid Squared (aid_gni_squared):
#    - Coefficient: -0.04997 (thousands of dollars)
#    - Interpretation: The negative coefficient suggests diminishing returns to 
#      aid, but it is not statistically significant. A one-percentage-point 
#      increase in aid squared would slightly decrease GDP per capita by approximately $0.05.

# 4. Interaction Term (interaction_term):
#    - Coefficient: -24.91626 (thousands of dollars)
#    - Interpretation: The negative coefficient indicates that the effectiveness 
#      of aid on GDP per capita decreases as policy quality improves. 
#      Specifically, a one-unit increase in the interaction between policy 
#      quality and aid reduces GDP per capita by approximately $24.92.

# Overall Model Fit:
# - Adjusted R²: 0.956723
#   - Interpretation: Approximately 95.67% of the variance in GDP per capita is 
#     explained by the model, suggesting a good fit.
# - Within R²: 0.062978
#   - Interpretation: There is substantial variability within countries over 
#     time that is not fully captured by the model.


# Note on Standard Errors

# Driscoll-Kraay standard errors are appropriate for this panel data model because:
# 1. They account for cross-sectional dependence, which is common in 
#    country-level data.
# 2. They adjust for serial correlation, addressing the issue of correlated 
#    errors over time within each country.
# 3. They are robust to heteroskedasticity, making them suitable for datasets 
#    with non-constant error variances. 
#
# Therefore, using Driscoll-Kraay standard errors helps to ensure that the 
# standard errors of the estimated coefficients are reliable and robust to 
# various issues typically present in panel data.