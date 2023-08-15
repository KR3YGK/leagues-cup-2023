#(1) data prep.do 
#*(2) bivariate Poisson.do
#*(3) bar chart.R <-- you are here

library(ggplot2)
library(readxl)
library(grid)
library(ggimage)
library(RCurl)
library(tidyverse)
library(ggrepel)

#!!!CHANGE FILE PATHS BELOW TO MATCH WHERE YOU PUT THE DATA FOLDER!!!

#import coefficients from bivariate Poisson estimated in Stata
coefficients = read_excel("C:/Users/.../data/output/coefficients.xls")
#made excel file of logos by hand. Links to Wiki.
logos = read_excel("C:/Users/.../data/raw/logos.xlsx")

coefficients=coefficients %>%
  left_join(logos, by=c("hid"="team"))

###############################################
# Create the horizontal bar chart using ggplot#
###############################################

#all teams (not in Substack article)
ggplot(coefficients, aes(x = coef, y = reorder(hid,coef), fill=league)) +
  geom_col() +
  geom_image(aes(image = local), size = 0.1)+
  scale_fill_manual(values = c("#e31b23", "#0e9b5c"))+
  theme_classic() +  
  labs(x = "Strength (average = 0)", y = "Team")+
  coord_cartesian(clip = "off")+#prevents Monterry logo from being clipped (mostly)
  theme(plot.margin = unit(c(1, 1, 1.5, 1), "lines")) #need this as well to 100% prevent logo clipping

#all teams above ave
ggplot(coefficients[coefficients$coef>0,], aes(x = coef, y = reorder(hid,coef), fill=league)) +
  geom_col() +
  geom_image(aes(image = local), size = 0.1)+
  scale_fill_manual(values = c("#e31b23", "#0e9b5c"))+
  theme_classic() +  
  labs(x = "Strength (average = 0)", y = "Team")+
  coord_cartesian(clip = "off")+#prevents Monterry logo from being clipped (mostly)
  theme(plot.margin = unit(c(1, 1, 1.5, 1), "lines")) #need this as well to 100% prevent logo clipping

#how many below ave? 29 --> split into 14/14
nrow(coefficients[coefficients$coef<0,])
#which rows? (start at 20 go to 32)
nrow(coefficients)-nrow(coefficients[coefficients$coef<0,])+1


ggplot(coefficients[20:33,], aes(x = coef, y = reorder(hid,coef), fill=league)) +
  geom_col() +
  geom_image(aes(image = local), size = 0.1)+
  scale_fill_manual(values = c("#e31b23", "#0e9b5c"))+
  theme_classic() + 
  labs(x = "Strength (average = 0)", y = "Team")+
  coord_cartesian(clip = "off")+
  theme(plot.margin = unit(c(1, 1, 1.5, 1), "lines"))


ggplot(coefficients[34:47,], aes(x = coef, y = reorder(hid,coef), fill=league)) +
  geom_col() +
  geom_image(aes(image = local), size = 0.1)+
  scale_fill_manual(values = c("#e31b23", "#0e9b5c"))+
  theme_classic() +  
  labs(x = "Strength (average = 0)", y = "Team")+
  coord_cartesian(clip = "off")+
  theme(plot.margin = unit(c(1, 1, 1.5, 1), "lines")) 
