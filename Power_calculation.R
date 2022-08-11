#!/usr/bin/env Rscript

library(tidyverse)
library(dplyr)
library(data.table)
library(devtools)
#install_github("camillemmoore/Power_Genetics", subdir="genpwr")
library(genpwr)


#Sample Size Calculation for a Case Control Study
ss <- genpwr.calc(calc = "ss", model = "logistic", ge.interaction = NULL,
   OR=1.2, Case.Rate=NULL, k=5,
   MAF=seq(0.01, 0.5, 0.05), Power=0.8, Alpha=0.05,
   True.Model=c("Dominant", "Recessive", "Additive"),
   Test.Model=c("Dominant", "Recessive", "Additive", "2df"))
ss.plot(ss)

ss <- genpwr.calc(calc = "ss", model = "logistic", ge.interaction = NULL,
   OR=1.2, Case.Rate=NULL, k=5,
   MAF=seq(0.01, 0.5, 0.01), Power=0.8, Alpha=0.05,
   True.Model=c("Additive"),
   Test.Model=c("Additive"))
ss.plot(ss)


# Power Calculation for a Case Control Study
# binary outcome and no gene/environment interaction
# odds ratio of 1.2 according to Kuruvilla et al. 2019:
pw <- genpwr.calc(calc = "power", model = "logistic", ge.interaction = NULL,
   N=27408, Case.Rate=NULL, k=5,
   MAF=seq(0.01, 0.5, 0.01), OR=c(1.2),Alpha=0.05,
   True.Model=c("Dominant", "Recessive", "Additive"),
   Test.Model=c("Dominant", "Recessive", "Additive", "2df"))

power.plot(pw)




#Detectable Odds Ratio Calculation for a Case Control Study
or <- genpwr.calc(calc = "es", model = "logistic", ge.interaction = NULL,
   N=27408, Case.Rate=NULL, k=5,
   MAF=seq(0.01, 0.5, 0.05), Power=0.8, Alpha=0.05,
   True.Model="All",Test.Model="All")
or.plot(or)

or <- genpwr.calc(calc = "es", model = "logistic", ge.interaction = NULL,
   N=27408, Case.Rate=NULL, k=5,
   MAF=seq(0.01, 0.5, 0.01), Power=0.8, Alpha=0.05,
   True.Model=c("Additive"),
   Test.Model=c("Additive"))
 or.plot(or)