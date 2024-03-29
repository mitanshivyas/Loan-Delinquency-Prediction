library(tidycensus)
library(tidyverse)
library(sf)
library(dplyr)
options(tigris_use_cache = TRUE)

total_pop <- c("B01001_001")

states <- c("AL","AZ","AR","CA","CO","CT","DE","DC","FL","GA","ID","IL","IN",
            "IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV",
            "NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT",
            "VT","VA","WA","WV","WI","WY")

ma_pop <- get_acs( state="MA",geography = "zcta",
                   variables =total_pop,
                   geometry = T)

us_pop <- get_acs( state=states,geography = "zcta",
                   variables =total_pop,
                   geometry = T)

setwd("M:/Terms/Fall 2021/DS5110/Project")
zip <- read.csv("zip1.csv")


zip_tidy <- zip %>% pivot_wider(names_from = loan_default, values_from = loan_status) %>% 
  mutate_all(~replace(., is.na(.), 0)) %>%
  mutate(id=substr(zip_code,1,3),default_pct=(default/(paid+default))*100)

#Scale Default Rates to 25% 

zip_scale <- zip_tidy %>% mutate(scale_default=case_when((default_pct/25) >1 ~ 100,
                                            TRUE ~ default_pct*100/25))

us_scale <- merge(x=us_pop_zip,y=zip_scale,by="id",all.x=TRUE)

colnames(us_scale)[11] <- "Default(%)"

ma_pop_zip <- ma_pop %>% mutate(id=substr(GEOID,1,3))

us_pop_zip <- us_pop%>% mutate(id=substr(GEOID,1,3))

mass_combined <-merge(x=ma_pop_zip,y=zip_tidy,by="id",all.x=TRUE)

us_combined <- merge(x=us_pop_zip,y=zip_tidy,by="id",all.x=TRUE)

plot4 <- us_scale %>% ggplot(aes(fill = `Default(%)`)) +
  geom_sf(color = NA) + coord_sf(crs = 26918) + 
  scale_fill_viridis_c(option="magma",direction=-1)+
  theme(legend.position = 'right')+
  labs(title = "Default Rates in Mainland US", y = "Latitude", x = "Longitude")+
  theme(
    text=element_text(family="Gerbera"),
    plot.title = element_text(size = 24,hjust = 0.5,colour = "white",family="Gerbera-Bold"),
    plot.subtitle = element_text(size = 14,hjust=0.5,colour = "white"),
    axis.text = element_text(colour = "white"),
    axis.title = element_text(colour = "white"),
    legend.text = element_text(colour = "white"),
    legend.title = element_text(colour = "white"),
    panel.background = element_rect(fill = '#1a1d2c'),
    plot.background = element_rect(fill='#1a1d2c',colour = "white"),
    legend.background = element_rect(fill='#1a1d2c',colour = "white")) 

us_acs <- get_acs(state = states, geography = "county", variables = 'B19013_001',
                    geometry = T)

colnames(us_acs)[4] <- "Estimate"

plot3 <- us_acs %>% ggplot(aes(fill = Estimate)) +
  geom_sf(color = NA) + coord_sf(crs = 26918) + 
  scale_fill_viridis_c(option="magma",direction=-1,label = scales::dollar)+
  theme(legend.position = 'right')+
  labs(title = "Median Income in Mainland US", y = "Latitude", x = "Longitude")+
  theme(
    text=element_text(family="Gerbera"),
    plot.title = element_text(size = 24,hjust = 0.5,colour = "white",family="Gerbera-Bold"),
    plot.subtitle = element_text(size = 14,hjust=0.5,colour = "white"),
    axis.text = element_text(colour = "white"),
    axis.title = element_text(colour = "white"),
    legend.text = element_text(colour = "white"),
    legend.title = element_text(colour = "white"),
    panel.background = element_rect(fill = '#1a1d2c'),
    plot.background = element_rect(fill='#1a1d2c',colour = "white"),
    legend.background = element_rect(fill='#1a1d2c',colour = "white")) 

require(gridExtra)
grid.arrange(plot3, plot4, ncol=2)

####################################################################################

colnames(mass_combined)[10] <- "Default(%)"

plot2 <- mass_combined %>% ggplot(aes(fill = `Default(%)`)) +
  geom_sf(color = NA) + coord_sf(crs = 26918) + 
  scale_fill_viridis_c(direction=-1)+
  theme(legend.position = 'right')+
  labs(title = "Default Rates in Massachusetts", y = "Latitude", x = "Longitude")+
  theme(
    text=element_text(family="Gerbera"),
    plot.title = element_text(size = 24,hjust = 0.5,colour = "white",family="Gerbera-Bold"),
    plot.subtitle = element_text(size = 14,hjust=0.5,colour = "white"),
    axis.text = element_text(colour = "white"),
    axis.title = element_text(colour = "white"),
    legend.text = element_text(colour = "white"),
    legend.title = element_text(colour = "white"),
    panel.background = element_rect(fill = '#1a1d2c'),
    plot.background = element_rect(fill='#1a1d2c',colour = "white"),
    legend.background = element_rect(fill='#1a1d2c',colour = "white")) 


###Get Median Income Data)
mass_acs <- get_acs(state = "MA", geography = "county", variables = 'B19013_001',
                    geometry = T)

colnames(mass_acs)[4] <- "Estimate"


plot1 <- mass_acs %>% ggplot(aes(fill = Estimate)) +
  geom_sf(color = NA) + coord_sf(crs = 26918) + 
  scale_fill_viridis_c(direction=-1,label = scales::dollar)+
  theme(legend.position = 'right')+
  labs(title = "Median Income in Massachusetts", y = "Latitude", x = "Longitude")+
  theme(
    text=element_text(family="Gerbera"),
    plot.title = element_text(size = 24,hjust = 0.5,colour = "white",family="Gerbera-Bold"),
    plot.subtitle = element_text(size = 14,hjust=0.5,colour = "white"),
    axis.text = element_text(colour = "white"),
    axis.title = element_text(colour = "white"),
    legend.text = element_text(colour = "white"),
    legend.title = element_text(colour = "white"),
    panel.background = element_rect(fill = '#1a1d2c'),
    plot.background = element_rect(fill='#1a1d2c',colour = "white"),
    legend.background = element_rect(fill='#1a1d2c',colour = "white")) 

require(gridExtra)
grid.arrange(plot1, plot2, ncol=2)

#Density Plot
d <- density(zip_tidy$default_pct)
plot(d, type="n", main="Default rates by Zip Code",xlim=c(0,30))
polygon(d, col="dodgerblue", border="darkgray")
rug(zip_tidy$default_pct, col="red")


zip_tidy %>% ggplot(aes(x = default_pct)) + geom_density(aes(fill = 'default_pct')) +
  xlim(0,25)

