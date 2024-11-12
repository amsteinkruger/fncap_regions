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

dat_boundaries_less = 
  "data/Admin/S_USA.ALPGeopoliticalUnit.gdb" %>% 
  vect %>% 
  subset(STATENAME == "Washington", NSE = TRUE) %>% 
  aggregate %>% 
  project("EPSG:32610") 

# ecoregions

#  L3

dat_ecoregions_3 = 
  "data/EPA Ecoregions/us_eco_l3/us_eco_l3.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries)

dat_ecoregions_3

dat_ecoregions_3_less = 
  "data/EPA Ecoregions/us_eco_l3/us_eco_l3.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries_less)

#  L4

dat_ecoregions_4 = 
  "data/EPA Ecoregions/us_eco_l4/us_eco_l4_no_st.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries)

dat_ecoregions_4

dat_ecoregions_4_less = 
  "data/EPA Ecoregions/us_eco_l4/us_eco_l4_no_st.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries_less)

# pyromes

dat_pyromes = 
  "data/USFS Pyromes/Data/Pyromes_CONUS_20200206.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries)

dat_pyromes_less = 
  "data/USFS Pyromes/Data/Pyromes_CONUS_20200206.shp" %>% 
  vect %>% 
  project("EPSG:32610") %>% 
  crop(dat_boundaries_less)

# show: Pyromes ~ Ecoregions III; Ecoregions IV add quite a bit more detail.

# Ecoregions III and Ecoregions IV

#  More

library(patchwork)
library(RColorBrewer)

pal_ecoregions = brewer.pal(7, "Blues")[5:6]

vis_ecoregions_3 = 
  dat_ecoregions_3 %>% 
  ggplot() +
  geom_spatvector(fill = pal_ecoregions[1],
                  color = "white") +
  labs(title = "EPA Ecoregions III")

vis_ecoregions_4 = 
  dat_ecoregions_4 %>% 
  ggplot() +
  geom_spatvector(fill = pal_ecoregions[2],
                  color = "white") +
  labs(title = "EPA Ecoregions IV")

vis_ecoregions = vis_ecoregions_3 + vis_ecoregions_4

ggsave("out/vis_ecoregions.png",
       vis_ecoregions,
       dpi = 300,
       width = 6.5,
       height = 5,
       bg = "transparent")

#  Less

vis_ecoregions_3_less = 
  dat_ecoregions_3_less %>% 
  ggplot() +
  geom_spatvector(fill = pal_ecoregions[1],
                  color = "white") +
  labs(title = "EPA Ecoregions III") +
  coord_sf(xlim = c(375000, 975000),
           ylim = c(5037500, 5457500))

vis_ecoregions_4_less = 
  dat_ecoregions_4_less %>% 
  ggplot() +
  geom_spatvector(fill = pal_ecoregions[2],
                  color = "white") +
  labs(title = "EPA Ecoregions IV") +
  coord_sf(xlim = c(375000, 975000),
           ylim = c(5037500, 5457500))

vis_ecoregions_less = vis_ecoregions_3_less + vis_ecoregions_4_less

ggsave("out/vis_ecoregions_less.png",
       vis_ecoregions_less,
       dpi = 300,
       width = 6.5,
       bg = "transparent")

# Ecoregions III and Pyromes 

pal_pyromes = brewer.pal(3, "Oranges")[3]

#  More

vis_pyromes = 
  dat_pyromes %>% 
  ggplot() + 
  geom_spatvector(fill = pal_pyromes,
                  color = "white") +
  labs(title = "Pyromes, Short et al. (2020)")

vis_ecoregions_pyromes = vis_ecoregions_3 + vis_pyromes

ggsave("out/vis_ecoregions_pyromes.png",
       vis_ecoregions_pyromes,
       dpi = 300,
       width = 6.5,
       height = 5,
       bg = "transparent")

#  Less

vis_pyromes_less = 
  dat_pyromes_less %>% 
  ggplot() + 
  geom_spatvector(fill = pal_pyromes,
                  color = "white") +
  labs(title = "Pyromes, Short et al. (2020)") +
  coord_sf(xlim = c(375000, 975000),
           ylim = c(5037500, 5457500))

vis_ecoregions_pyromes_less = vis_ecoregions_3_less + vis_pyromes_less

ggsave("out/vis_ecoregions_pyromes_less.png",
       vis_ecoregions_pyromes_less,
       dpi = 300,
       width = 6.5,
       bg = "transparent")

# Ecoregions III and Pyromes with burn probability

library(viridis)
library(scales)

dat_burn = 
  "data/FSIM/WA/BP_WA.tif" %>% 
  rast %>% 
  project("EPSG:32610")

vis_ecoregions_burn = 
  ggplot() + 
  geom_spatraster(data = dat_burn,
                  maxcell = 1000000) +
  geom_spatvector(data = dat_ecoregions_3_less,
                  fill = NA,
                  color = "white") +
  scale_fill_viridis(option = "magma",
                     na.value = NA,
                     breaks = pretty_breaks(n = 3)) +
  labs(title = "Ecoregions III with Burn Probability") +
  coord_sf(xlim = c(375000, 975000),
           ylim = c(5037500, 5457500)) +
  theme(legend.position = "none")

vis_pyromes_burn = 
  ggplot() + 
  geom_spatraster(data = dat_burn,
                  maxcell = 1000000) +
  geom_spatvector(data = dat_pyromes_less,
                  fill = NA,
                  color = "white") +
  scale_fill_viridis(option = "magma",
                     na.value = NA,
                     breaks = pretty_breaks(n = 3)) +
  labs(title = "Pyromes with Burn Probability") +
  coord_sf(xlim = c(375000, 975000),
           ylim = c(5037500, 5457500)) +
  theme(legend.position = "none")

vis_burn = vis_ecoregions_burn + vis_pyromes_burn

ggsave("out/vis_burn.png",
       vis_burn,
       dpi = 300,
       width = 6.5,
       bg = "transparent")
