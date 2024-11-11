# Get EPA ecoregions and USFS pyromes in for visualization and comparison.

library(tidyverse)
library(terra)
library(tidyterra)
library(magrittr)

# area of interest

dat_boundaries = 
  "data/Admin/S_USA.ALPGeopoliticalUnit.gdb" %>% 
  vect %>% 
  subset(STATENAME == "California" | STATENAME == "Oregon" | STATENAME == "Washington", NSE = TRUE) %>% 
  aggregate %>% 
  project("EPSG:32610") # UTM 10N. Change to modified Albers to center the projection about the states' centroid(s).

# ecoregions

#  L3

dat_ecoregions_3 = 
  "data/EPA Ecoregions/us_eco_l3/us_eco_l3.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries)

#  L4

dat_ecoregions_4 = 
  "data/EPA Ecoregions/us_eco_l4/us_eco_l4_no_st.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries)

 # pyromes

dat_pyromes = 
  "data/USFS Pyromes/Data/Pyromes_CONUS_20200206.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries)

# show: Pyromes ~ Ecoregions III; Ecoregions IV add quite a bit more detail.