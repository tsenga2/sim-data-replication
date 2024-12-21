# Uncertainty Shocks: Misallocation and Imperfect Information

This repository contains replication files for the empirical results from the paper "A new look at uncertainty shocks: misallocation and imperfect information".

This explains how to construct data, run empirical analysis, and generate figures and tables included in the paper (Replication package).

You can clone this repository and add directories named `FigureTable`, `data`, and `log`.

## Software Requirements

### Stata Version

Tested and confirmed working on:
- macOS: Stata/SE 18.0
- Windows: Stata/MP 18.0

Note: Earlier versions of Stata may work but are not tested.

### Required Stata Packages

```stata
ssc install reghdfe      // For high-dimensional fixed effects
ssc install ftools       // Required by reghdfe
ssc install estout       // For creating tables
ssc install winsor2      // For winsorization
ssc install egen         // Extended generate functions
ssc install egenmore     // Additional generate functions
```

## Data Requirements

Before running the replication, you'll need to obtain the following datasets from WRDS (Wharton Research Data Services):

- Compustat Quarterly (GARCH data)
- CRSP-Compustat Merged Fundamentals
- CRSP-Compustat Merged Security Monthly
- CRSP Daily Stock
- OptionMetrics (Standardized Options)
- IBES

Place these files in the `data` directory with the following names:
- `compustat-quarterly-garch.dta`
- `crsp-compustat-merged-fund.dta`
- `crsp_compustat_merged_security_monthly.dta`
- `crsp_daily_stock.dta`
- `std_inv.csv`
- `ibes.dta`

## Directory Structure

The repository contains the following directories and do-files:

```
├── FigureTable
├── README.md
├── data
│   ├── compustat-quarterly-garch.dta (from Compustat via WRDS)
│   ├── crsp-compustat-merged-fund.dta (from CRSP via WRDS)
│   ├── crsp_compustat_merged_security_monthly.dta (from CRSP via WRDS)
│   ├── crsp_daily_stock.dta (from CRSP via WRDS)
│   ├── std_inv.csv (from OptionMetrics via WRDS)
│   └── ibes.dta (from IBES via WRDS)
├── log
├── src
│   ├── Build_CRSP_Data.do
│   ├── Build_IV_Data.do
│   │── Build_FRED_Data.do
│   ├── Build_IBES_Panel.do
│   ├── Build_Compustat_IBES_Panel.do
│   ├── T1-2andF1.do (Table 1 and 2, Figure 1)
│   ├── Add_V.do
│   ├── MPK.do (A.5)
│   ├── Cross_regressions.do (Table 8 and 9, A.3)
│   ├── Build_Compustat_IBES_TimeSeries.do
│   ├── TSeries.do (A.6)
│   ├── T3andF2.do (Table 3 and Figure 2)
│   ├── SharePrice.do (A.4, Figure 9 and Table 10)
│   ├── Uncertainty.do (Figure 10 and Table 11)
│   ├── SalesGrowth.do (A.7)
│   └── Add_Garch_PredictFuture.do (Table 12)
│
└── wrapper.do
```

## Replication Instructions

1. Clone the appropriate branch based on which paper version you want to replicate
2. Create the required directories: `FigureTable`, `data`, and `log`
3. Add the required datasets from WRDS to the `data` directory
4. Run the wrapper script:
```stata
do wrapper.do
```
A wrapper (`wrapper.do`) will run all the do-files and generate data, and then create figures and tables as below:

- `crsp_permno.dta`
- `FRED_Data.dta`
- `ibes_cusip_extrp.dta`
- `ibes_cusip_ave.dta`
- `ibes_cusip_1yr.dta`
- `uim_panel.dta`
- `uim_tseries.dta`
- `optionmtrx31_m.dta`
- `optionmtrx31_y.dta`

- `desc_all.tex` (for Table 1: : Descriptive Statistics)
- `desc_both_sub.tex` (for Table 2: : Subsamples-Descriptive Statistics)
- `GR_Covid_Fdis.png` (for Figure 2: Forecast Dispersion: Great Recession vs Covid-19 Pandemic)
- `GR_Covid_FE.png` (for Figure 2: Forecast Dispersion: Great Recession vs Covid-19 Pandemic)
- `combo_TS-skew.png` (for Figure 3: : Historical series)
- `reg_ts1.tex` (for Table 3: : Uncertainty fluctuates over time in a countercyclical fashion)
- `reg_ts2.tex` (for Table 3: : Uncertainty fluctuates over time in a countercyclical fashion)
- `reg_mrpk_sic3d.tex` (for Table A.5: The marginal revenue products of capital covaies with uncertainty at the industry level)
- `reg_T01.tex` (for Table 8: fororecast disagreement and forecast errors covary with realized stock market volatility and options-implied volatility)
- `reg_T02.tex` (for Table 9: forecast disagreement appears to reflect uncertainty)
- `reg_T03.tex` (for A.3: Forecast disagreement is robust when standard deviation is used instead of coefficient of variation)
- `reg_mrpk_sic3d.tex` (for A.5: The marginal revenue products of capital covaies with uncertainty at the industry level)
- `reg_ts_mrpk.tex` (for A.6: Cyclicality of the marginal revenue products of capital)
- `reg_MK1.tex` (for Table 10: High-low share price subsamples)
- `reg_MK2.tex` (for Table 10: High-low share price subsamples)
- `reg_MK3.tex` (for Table 11: High-low uncertainty subsamples)
- `reg_MK4.tex` (for Table 11: High-low uncertainty subsamples)
- `comboMK1.png` (for Figure 9: Time-series by share price subsamples)
- `comboMK1.png` (for Figure 9: Time-series by share price subsamples)
- `comboMK1.png` (for Figure 10: Time-series by uncertainty subsamples)
- `comboMK1.png` (for Figure 10: Time-series by uncertainty subsamples)
- `reg_sales_gr.tex` (for A.7: Sales growth rates are negatively correlated with uncertainty)
- `reg_forecast_lngdp.tex` (for Table 12: : Predicting future economic activity with uncertainty measures)

Data will be stored at `data` and all the `tex` and `png` files at `FigureTable`.

Log files will be stored at `log` directory.


## License

This project is licensed under the MIT License - see the license-file for details.
