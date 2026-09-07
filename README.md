# Data-Center-Hydrogen-and-Cold-Energy-Supply

This repository contains MATLAB codes, processed datasets, and the integrated
system model supporting the study:

**Sustainable Offshore Wind Driven Hydrogen and Cold Energy Supply for Next Generation Data Centers**

## Overview

The repository provides the principal physical models, analysis codes, and
processed datasets used in the revised study.

The materials include:

- offshore wind-resource and wind-power analysis;
- an integrated SOEC-based hydrogen-production model;
- Monte Carlo uncertainty analyses for LCOH and LCOCE;
- processed spatial results for the offshore wind and techno-economic analyses;
- and the key implementation of the multi-objective optimization framework.

The Monte Carlo codes and associated processed input datasets can be used to
reproduce the uncertainty analyses reported in the manuscript.

The multi-objective optimization codes are provided to document the
implementation of the optimization framework, including the decision variables,
objective functions, constraints, bounds, and genetic-algorithm settings.

---

## Repository contents

### 1. Offshore wind analysis

- **`Wind_speed_2023.m`**  
  Processes ERA5 hourly wind data and calculates the 100-m wind-speed magnitude
  from the ERA5 100-m u- and v-components of wind.

- **`Single_wind_power.m`**  
  Calculates the hourly power output of a single Vestas-80 2 MW offshore wind
  turbine as a function of the 100-m wind speed.

- **`Wind_Power.m`**  
  Calculates and visualizes the hourly wind-speed and wind-power profiles.

- **`Total_electricity.mat`**  
  Contains the processed hourly wind-speed and wind-power data for the ten
  representative offshore locations used in the subsequent techno-economic
  and uncertainty analyses.

The original ERA5 NetCDF data are not redistributed in this repository.
They can be obtained directly from the Copernicus Climate Change Service
(C3S) Climate Data Store (CDS).

ERA5 dataset:

https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=overview



---

### 2. Integrated hydrogen production model

- **`Hydrogen_platform.slx`**  
  Integrated Simulink model of the SOEC-based hydrogen-production and
  thermal-integration system.

  The model includes the SOEC and associated thermal-management and
  energy-recovery components, including steam and air heat exchange,
  air compression, evaporation and condensation, MgH2 hydrogenation-heat
  recovery, and absorption refrigeration.

- **`SOECplatform_parameter_sweep.m`**  
  MATLAB script used to perform parametric simulations of the SOEC system
  by varying the current density and corresponding steam inlet flow rate.
  The operating parameters are passed to `Hydrogen_platform.slx` for
  Simulink simulation.

---

### 3. Monte Carlo uncertainty analysis

- **`Monte_Carlo_LCOH.m`**  
  Monte Carlo uncertainty analysis for the levelized cost of hydrogen (LCOH).

- **`Monte_Carlo_LCOCE.m`**  
  Monte Carlo uncertainty analysis for the levelized cost of cold energy
  (LCOCE).

- **`Total_electricity.mat`**  
  Provides the case-specific processed hourly wind-resource and wind-power
  inputs for the ten representative offshore locations.

The Monte Carlo analyses implement the parameter-specific uncertainty ranges
and probability distributions described in the manuscript and
Supplementary Information.

---

### 4. Spatial analysis and mapping

- **`Map_plot.m`**  

MATLAB code for generating the spatial map of offshore wind speed. 
Processed CF, LCOH and LCOCE spatial datasets are also provided.

The processed spatial datasets include:

- **`Results_wind_speed.mat`** — Processed wind-speed results.
- **`Results_CF.mat`** — Processed wind-turbine capacity-factor results.
- **`Results_LCOH.mat`** — Processed LCOH results.
- **`Results_LCOCE.mat`** — Processed LCOCE results.

Coastline data used for map visualization were obtained from the Global
Self-consistent, Hierarchical, High-resolution Geography Database (GSHHG).

The original GSHHG data are not redistributed in this repository and can be
obtained directly from the original data provider:

https://www.ngdc.noaa.gov/mgg/shorelines/shorelines.html

The GSHHG data are used only for coastline and land-area visualization and
do not affect the numerical results of the analysis.

---

### 5. Multi-objective optimization

- **`Ga_main.m`**  
  Main MATLAB program implementing the multi-objective genetic-algorithm
  optimization of the data-center energy-supply structure.

- **`Data_ene_eco_system.m`**  
  Objective-function implementation used by the multi-objective optimization
  framework.

The optimization considers six decision variables describing grid electricity,
electric cooling, offshore hydrogen supply, and offshore cooling supply.

The two optimization objectives are grid electricity consumption 
and total system cost.

The implementation includes the decision-variable bounds, energy-balance
constraints, Pareto-fraction setting, population size, maximum number of
generations, stall-generation limit, and function tolerance.

These files are provided as the key implementation of the multi-objective
optimization framework and are intended to document the optimization
formulation and computational procedure.

---

## Third-party data sources

### ERA5 wind data

Wind-resource data used in this study were obtained from:

**ERA5 hourly data on single levels from 1940 to present**  
Copernicus Climate Change Service (C3S), Climate Data Store (CDS)

DOI: **10.24381/cds.adbb2d47**

Dataset:

https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=overview

The original ERA5 NetCDF files are not redistributed in this repository.
Processed wind-speed and wind-power data used in the analyses are provided
where required for reproducibility.

Users should obtain the original ERA5 data directly from the CDS and refer
to the data provider for the applicable terms of use.

### GSHHG coastline data

Coastline data used for map visualization were obtained from the:

**Global Self-consistent, Hierarchical, High-resolution Geography Database
(GSHHG)**

Data source:

https://www.ngdc.noaa.gov/mgg/shorelines/shorelines.html

Reference:

Wessel, P., and Smith, W. H. F. (1996).
*A global, self-consistent, hierarchical, high-resolution shoreline database.*
Journal of Geophysical Research, 101(B4), 8741–8743.  
DOI: **10.1029/96JB00104**

The original GSHHG data are not redistributed in this repository.

---

## Software requirements

The analysis codes were developed using MATLAB.

The integrated hydrogen-production and thermal-integration model is provided
in Simulink format.

The mapping scripts additionally require GSHHG coastline data obtained from
the original data provider.

---

## Reproducibility notes

The wind-power, Monte Carlo uncertainty, and processed spatial-analysis
materials correspond to the revised manuscript.

The integrated Simulink model provides the component-level implementation
of the SOEC-based hydrogen-production and thermal-integration system.

The optimization files provide the key source-code implementation of 
the multi-objective formulation.

Third-party source datasets, including the original ERA5 NetCDF files and
GSHHG coastline files, are not redistributed. Their original data sources
are provided above.

---

## License

Unless otherwise stated, the original source code developed for this study
is released under the MIT License.

Third-party datasets and software are not covered by the repository's MIT
License and remain subject to the licenses and terms of their respective
providers.

---

## Contact

For questions regarding the repository or the associated study, please contact
the corresponding authors:

- xusheng.wang@eng.ox.ac.uk
- binjian.nie@eng.ox.ac.uk
