# Analysis of the Determinants of Growth in Developing Countries

## Introduction

This report aims to replicate and extend the analysis of the determinants of economic growth in developing countries, following the methodology outlined in the referenced study. The focus is on understanding how various factors, including initial income levels, institutional quality, policy measures (CPIA), and foreign aid, influence the growth rate of per capita Gross National Product (GNP). Additionally, regional effects are considered through dummy variables for different regions.

## Data and Methodology

### Data Sources

1.  **CPIA Scores**: Collected from the World Bank, these scores measure the quality of policies and institutions in each country.
2.  **Aid Data**: Data on net Official Development Assistance (ODA) received as a percentage of GNP.
3.  **Growth Data**: GDP per capita growth rates calculated from GDP per capita in constant prices.
4.  **Initial Income**: GDP per capita in 2005 used as a baseline for initial income.
5.  **Institutional Quality**: Data from the Worldwide Governance Indicators.
6.  **Regional Dummies**: A lookup table was created to assign each country to a region (South Asia, East Asia/Pacific, Europe/Central Asia, Latin America/Caribbean, Sub-Saharan Africa, and Middle East/North Africa).

### Methodology

The analysis uses a linear regression model to estimate the following relationship:

$$ G = c + b_1X + b_2P + b_3A + b_4A^2 + b_5AP + \text{Regional Dummies} $$

Where: - $G$ = Growth rate of per capita GNP - $X$ = Exogenous conditions (initial income, institutional quality) - $P$ = Policy measure (CPIA) - $A$ = Aid as a percentage of GDP - $A^2$ = Squared term of aid - $AP$ = Interaction term between aid and policy

### Data Preprocessing

The data was preprocessed using the following steps: 1. **Merging Datasets**: The datasets were merged using a fuzzy matching approach based on country names and years. 2. **Creating Interaction Terms**: Variables such as $A^2$ and $AP$ were created. 3. **Adding Regional Dummies**: Dummy variables were created for each region.

## Results

### Descriptive Statistics

The final dataset consisted of 1,627 observations after merging all sources.

### Regression Analysis

The regression model was specified as follows:

$$ \text{Growth} \sim \text{Initial GNP per capita} + \text{CPIA} + \text{ODA/GDP} + A^2 + AP + \text{Regional Dummies} $$

#### Model Summary

``` plaintext
Call:
lm(formula = Growth ~ Initial_GNP_per_capita + CPIA + ODA_GDP + 
    A_squared + AP_interaction + `East Asia/Pacific` + `Europe/Central Asia` + 
    `Latin America/Caribbean` + `Sub-Saharan Africa` + `South Asia`, 
    data = merged_data)

Residuals:
    Min      1Q  Median      3Q     Max 
-36.840  -1.954   0.007   1.979  59.522 

Coefficients:
                            Estimate Std. Error t value Pr(>|t|)    
(Intercept)               -4.269e+00  2.189e+00  -1.950   0.0513 .  
Initial_GNP_per_capita     2.673e-05  4.775e-05   0.560   0.5756    
CPIA                       2.430e+00  5.278e-01   4.604 4.47e-06 ***
ODA_GDP                    1.235e-01  1.474e-01   0.838   0.4022    
A_squared                  1.300e-03  6.498e-04   2.000   0.0456 *  
AP_interaction            -6.742e-02  4.456e-02  -1.513   0.1305    
`East Asia/Pacific`       -8.387e-01  1.626e+00  -0.516   0.6061    
`Europe/Central Asia`      1.798e-02  1.650e+00   0.011   0.9913    
`Latin America/Caribbean` -1.460e+00  1.610e+00  -0.907   0.3647    
`Sub-Saharan Africa`      -1.207e+00  1.599e+00  -0.755   0.4504    
`South Asia`              -1.944e+00  1.673e+00  -1.162   0.2454    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 4.972 on 1616 degrees of freedom
Multiple R-squared:  0.04047,   Adjusted R-squared:  0.03453 
F-statistic: 6.816 on 10 and 1616 DF,  p-value: 1.732e-10
```

### Interpretation

-   **CPIA**: The coefficient for CPIA is positive and highly significant (p \< 0.001), suggesting that better policies and institutions are associated with higher growth rates.
-   **Initial_GNP_per_capita**: The coefficient is not statistically significant, indicating that initial income does not significantly impact growth in the sample.
-   **ODA_GDP**: The coefficient for aid as a percentage of GDP is not significant, suggesting no direct effect on growth.
-   **A_squared**: The positive and significant coefficient (p \< 0.05) suggests diminishing returns to aid.
-   **AP_interaction**: The interaction between aid and policy is not significant, indicating that the effectiveness of aid does not significantly depend on the policy environment.
-   **Regional Dummies**: None of the regional dummy variables are significant, indicating that regional differences do not significantly affect growth when controlling for other factors.

## Fixed Effects Results

```         
> summary(model_fe, driscoll_kraay ~ Year)
OLS estimation, Dep. Var.: Growth
Observations: 1,627
Fixed-effects: Country: 78,  Year: 18
Standard-errors: Driscoll-Kraay (L=2) 
                Estimate Std. Error   t value Pr(>|t|)    
CPIA            3.042135   1.128561  2.695587 0.015315 *  
ODA_GDP        -0.275615   0.308188 -0.894310 0.383643    
A_squared       0.001388   0.000887  1.563792 0.136290    
AP_interaction  0.058429   0.087880  0.664868 0.515054    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
RMSE: 4.36923     Adj. R2: 0.205973
                Within R2: 0.017546
```

## Conclusion

The analysis shows that while good policy environments (as measured by CPIA) positively influence growth, the effectiveness of aid and the initial income levels do not have a significant impact. The diminishing returns to aid are evident, and regional effects are not statistically significant.

These findings provide important insights for policymakers focusing on enhancing growth in developing countries. Future research could further investigate the specific channels through which policies impact growth and the conditions under which aid becomes effective.

When compared to Collier and Dollar we find:

-   **Policy Quality**: Both analyses find that good policies (higher CPIA scores) are associated with higher growth. However, our study finds a much stronger effect.

-   **Aid Effectiveness**: The original study by Collier and Dollar finds that aid has diminishing returns and its effectiveness improves with a better policy environment. In contrast, our analysis does not find a significant effect for aid or its interaction with policy.

-   **Initial Income and Regional Effects**: The significance of initial income and regional dummies in Collier and Dollar’s study suggests these factors play a role in growth, while our analysis does not find such effects. \`\`\`
