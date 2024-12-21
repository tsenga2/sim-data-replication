# Replication files for empirical results (A new look at uncertainty shocks: misallocation and imperfect information) 
This explains how to construct data, run empirical analysis, and generate figures and tables included in the paper (Replication package).

You can clone this repository and add directories named `FigureTable`, `data`, and `log`.

In `data` directory, you should add datasets listed below and the entire directory structure looks like below.

```
├── FigureTable
├── README.md
├── data
│   ├── compustat_garch.dta
│   ├── crps-compustat-merged-fund.dta
│   ├── crps-compustat-merged-monthly.dta
│   ├── crps_permno.dta
│   ├── data_bachmanetal.dta
│   ├── data_table1_census.dta
│   ├── freduse_cpi.dta
│   ├── freduse_real.dta
│   ├── ibes.dta
│   └── optmtrx31_y.dta
├── log
├── src
│   ├── build_panel.do
│   ├── ibes_sum_cusip.do
│   ├── ibes_sum_cusip_fuzoku.do
│   ├── post_panel.do
│   └── stats_panel.do
└── wrapper.do
```

A wrapper (`wrapper.do`) will run each do-file:

- `ibes_sum_cusip.do`
- `build_panel.do`
- `post_panel.do`
- `ibes_sum_cusip_fuzoku.do`
- `stats_panel.do`

Log files will be stored at `log` directory.

## ibes_sum_cusip.do

This takes `ibes.dta` and builds datasets listed below:

- `ibes_panel_m.dta`
- `ibes_cusip_ave.dta`
- `ibes_cusip_1yr.dta`
- `ibes_cusip_extrp.dta`

## build_panel.do

Start from `crps-compustat-merged-fund.dta`

Merge with:

- `crps-compustat-merged-monthly.dta`
- `crps_permno.dta`
- `ibes_cusip_extrp.dta`
- `optmtrx31_y.dta`
- `freduse_cpi.dta`
- `compustat_garch.dta`

Build `uim_panel.dta`

Generate tables:

- desc_ind.tex
- desc_v_all.tex (A.1 Structural Estimation)
- reg_ind.tex
- reg_mrpk_sic3d.tex (A.4 The marginal revenue products of capital, dupulicated?)
- reg_mrpk_agg.tex


## post_panel.do

Start from `uim_panel.dta`

Merge with:
- `freduse_real.dta`
- `data_table1_census`
- `data_bachmanetal`

Generate the following figures and tables stored in `FigureTable` for the paper.

- `reg_T01.tex` (Table 3 : Forecast disagreement and forecast errors covary with realized stock market volatility and options-implied volatility)
- `reg_T02.tex` (Table 4 : Forecast disagreement appears to reflect uncertainty)
- `reg_T03.tex`
- `reg_T04.tex`
- `desc_all.tex` (Table 1 : Descriptive Statistics)
- `desc_unct.tex`
- `desc_both_sub.tex` (Table 2 : Subsamples-Descriptive Statistics)
- `reg_ts1.tex` (Table 5 : Uncertainty fluctuates over time in a countercyclical fashion)
- `reg_ts2.tex` (Table 5 : Uncertainty fluctuates over time in a countercyclical fashion)
- `reg_ts3.tex` (A.2 Forecast disagreement is robust when standard deviation is used instead of coefficient of variation)
- `reg_ts_v.tex`
- `reg_ts_mrpk.tex`
  
- foreach z in strt vol iv fdis1 fdis2 fe1 fe2 fe3 {`corrmat_`z`_hp.tex`}

  `corrmat_fdis1_hp.tex` (A.2 Forecast disagreement is robust)
 
  `corrmat_fdis2_hp.tex` (A.2 Forecast disagreement is robust)

- `reg_forecast_lngdp.tex`
- `reg_forecast_dgdp.tex`
- `combo_GR.png` (Figure 1 : The Great Recession)
- `combo_TS.png`
- `combo_TS-skew.png` (Figure 2 : Historical series)
- `combo_TS-a.png`
- `desc_sprice_sub.tex` (A.3 Sub-sample analysis by share price and uncertainty)
- `reg_MK1.tex` (Table 12 : High-low share price subsamples)
- `reg_MK2.tex` (Table 12 : High-low share price subsamples)
- `comboMK1.png` (Figure 12 : Time-series by share price subsamples)
- `comboMK2.png` (Figure 12 : Time-series by share price subsamples)
- `desc_both_sub.tex`
- `reg_MK3.tex` (Table 13 : High-low uncertainty subsamples)
- `reg_MK4.tex` (Table 13 : High-low uncertainty subsamples)
- `comboMK3.png` (Figure 13 : Time-series by uncertainty subsamples)
- `comboMK4.png` (Figure 13 : Time-series by uncertainty subsamples)


Save `uim_tseries.dta`


## ibes_sum_cusip_fuzoku.do

Start with `ibes_panel_m.dta`

Generate the following figures and store them at `FigureTable`

- `ford_example_ponch.png`
- `ford_example_fefdis.png`
- `ford_example_fe.png` (Figure 11 : Ford example - forecast error)
- `ford_example_fdis.png` (Figure 9 : I/B/E/S data example (Ford Motor Co.))
- `box_tow.png` (Figure 10 : Pattern of uncertainty by toward)
- `box_m_12.png`
- `box_m_9.png`
- `box_m_6.png`
- `box_m_3.png`


## stats_panel.do

Start with `uim_panel.dta`

Merge with `freduse_real.dta`

- `reg_`x`.tex` 

   (`reg_ts_v.tex` is for A.5 Cyclicality of the marginal revenue products of capital)
   
   (`reg_sales_gr.tex` is for A.6 Sales growth rates are negatively correlated with uncertainty)

   (`reg_forecast_lngdp.tex` is for Table 14 : Predicting future economic activity with uncertainty measures)

- `unct_`z`_nber.png`
- `F4_`z`_`w`.png`
- `F_`z`_`w`.png` 

   (`F4_sales_gr_unct_pct.png` is Figure 3 : Sales growth rates by uncertainty decile)

- `calibration1.png`
- `calibration2.png`
- `calibration3.png`
- `panel_moment_unbala.tex`
- `panel_moment_unbala_des.tex`
- `panel_moment_unbala_sub.tex`
- `panel_moment_unbala_unct_pct.tex`


