# Regression Specification and Data Documentation

## Regression Specification

The regression model we will use is specified as follows:

$$ 
G = b_0 + b_1(\text{Initial Income}) + b_2(\text{Institutional Quality}) + b_3(\text{Policy}) + b_4(\text{Aid/GDP}) + b_5(\text{Aid/GDP})^2 + b_6(\text{Policy} \times \text{Aid/GDP}) + \epsilon 
$$

Where: - $G$ is the real GDP per capita growth over a four-year period. - $\text{Initial Income}$ is the logged real GDP per capita at the beginning of the period. - $\text{Institutional Quality}$ is measured by the CPIA score. - $\text{Policy}$ is also measured by the CPIA score. - $\text{Aid/GDP}$ is the net ODA relative to GDP. - $\text{Aid/GDP}^2$ is the square of net ODA relative to GDP, to capture diminishing returns to aid. - $\text{Policy} \times \text{Aid/GDP}$ is the interaction term between Policy and Aid/GDP. - $\epsilon$ is the error term.

We will also include time fixed effects and regional dummies in the regression.

## Data Sources

### Dependent Variable

-   **Real GDP per capita growth over a four-year period**
    -   Source: [IMF World Economic Outlook (WEO)](https://www.imf.org/en/Publications/SPROLLs/world-economic-outlook-databases)
    -   Note: We will also conduct a robustness test with an eight-year period.

### Independent Variables

-   **Net ODA relative to GDP (Aid/GDP)**
    -   Source: [OECD DAC via World Bank](https://data.worldbank.org/indicator/DT.ODA.ODAT.GN.ZS)
    -   Note: Data is expressed relative to GNI but can be converted to GDP using IMF WEO data.
-   **Aid/GDP Squared (Aid/GDP**$^2$)
    -   Calculation: Square of the Net ODA relative to GDP.
-   **CPIA Score**
    -   Source: [World Bank CPIA](https://data.worldbank.org/indicator/IQ.CPA.IRAI.XQ?locations=AF)
    -   Note: This will constrain the countries included in our regression.
-   **Logged Real GDP per capita (Initial Income)**
    -   Source: [IMF World Economic Outlook (WEO)](https://www.imf.org/en/Publications/SPROLLs/world-economic-outlook-databases)
    -   Note: Used to control for initial conditions.
-   **Time Fixed Effects and Regional Dummies**
    -   Source: IMF or World Bank data sources which include a 'regional' column.

### Additional Considerations

-   Ensure consistency in the time periods used across all data sources.
-   Validate data transformations and calculations, such as converting Aid/GNI to Aid/GDP.

## Methodology

1.  **Data Collection**: Gather data from the specified sources.
2.  **Data Processing**: Convert and clean the data as necessary, ensuring consistency and accuracy.
3.  **Regression Analysis**: Perform the regression analysis with the specified model.
4.  **Robustness Test**: Extend the period for the dependent variable to eight years and re-run the regression to test the robustness of the results.

This documentation provides a comprehensive guide for conducting the regression analysis, including the sources of data and the specific variables to be used.
