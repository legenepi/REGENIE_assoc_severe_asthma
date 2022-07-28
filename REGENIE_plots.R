#!/usr/bin/env Rscript
library(qqman) #qq plot and manhattan plot
library(ggplot2)
library(data.table)
library(grid)
library(gridGraphics)
library(tidyverse)
#call the plot_functions.R for QQ-plot,Manhattan and lambda:
source("src/plot_functions.R")

args = commandArgs(TRUE)


#inputfile:
input_file = args[1] #REGENIE result file
input_file <- "output/pheno_allchr_step2_regenie.gz"
#input
meta <- fread(input_file, header=T, fill=T)
#filter out first row of the original header:

pval <- 10^(as.numeric(meta$LOG10P))


#QQ plot with qqman package: one genome-wide for each test-statistic p-val:
plot.qqplot(pval_vec = pval, title= "REGENIE_diff_treat_asthma")

#Lambda (inflation of genetic factor):
lambda_func(pval, title = "REGENIE_diff_treat_asthma")

#Manhattan plot: one for each test-statistic p-val: p_wald p_lrt p_score:
# require these columns: rs,chr,ps,pval
df <- meta %>% select(ID,CHROM,GENPOS,pval)
colnames(df) <- c("rs","chr",ps","pval")
df$chr <- as.numeric(df$chr)
df$rs <- as.numeric(df$rs)
plot.Manha(df, title = "REGENIE_diff_treat_asthma")



