#!/usr/bin/env Rscript
library(qqman) #qq plot and manhattan plot
library(ggplot2)
library(data.table)
library(grid)
library(tidyverse)
#call the plot_functions.R for QQ-plot,Manhattan and lambda:
source("src/plot_functions.R")

args = commandArgs(TRUE)


#inputfile:
input_file = args[1] #REGENIE result file
pheno = args[2] #1_5_ratio_pheno #1_5_ratio_pheno_earlyonset #1_5_ratio_pheno_adultonset
#input_file <- "output/allchr/pheno_1_5_ratio_allchr.assoc.txt.gz"
#input
meta <- fread(input_file, header=T, fill=T)

title_plot <- paste0("GWAS_",pheno)


#QQ plot with qqman package: one genome-wide for each test-statistic p-val:
plot.qqplot(pval_vec = meta$LOG10P, title= title_plot)


#Manhattan plot:
# require these columns: rs,chr,ps,pval
df <- meta %>% select(ID,CHROM,GENPOS,LOG10P)
colnames(df) <- c("rs","chr","ps","pval")
df$chr <- as.numeric(df$chr)
df$ps <- as.numeric(df$ps)
plot.Manha(df, title = title_plot)


#Lambda (inflation of genetic factor) from pval:
lambda <- lambda_func(meta$CHISQ, title = title_plot)

if (lambda >= 1.05) {
    print("Correct for lambda >= 1.05")
    meta$se_gc <- meta$SE * sqrt(as.numeric(lambda))
    #recalculate pval corrected with a two sided z-score : z-score=-abs(estimate/se_corrected). because under Ho a=0, so estimate-0=estimate
    #-abs: because z-score should be always negative
    z <- -abs(meta$BETA/meta$se_gc)
    #2*pnorm: two-sided test
    meta$pval_gc <- 2*pnorm(z)
    title_plot <- paste0("gc_GWAS_",pheno)
    #QQ plot:
    #plot.qqplot(pval_vec = meta$pval_gc, title= title_plot)
    #Manhattan plot:
    df <- meta %>% select(ID,CHROM,GENPOS,pval_gc)
    colnames(df) <- c("rs","chr","ps","pval")
    df$chr <- as.numeric(df$chr)
    df$ps <- as.numeric(df$ps)
    plot.Manha(df, title = title_plot)
}


