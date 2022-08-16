#!/usr/bin/env Rscript


suppressMessages(library(tidyverse))
suppressMessages(library(data.table))
library(dlookr)
library(dplyr)
library(pals)
library(RColorBrewer)
library(ggplot2)


input_file = "output/maf001_pheno_1_5_ratio_genomewide_signif"
#input:
sumstat <- fread(input_file,header=T)
colnames(sumstat) <- c("snpid", "b37chr", "bp", "a1", "a2", "LOG_ODDS", "se", "eaf", "pval", "MAF")

#number of genome-wide significant variants by eaf bins:
sumstat <- sumstat %>% mutate(eaf_bin=binning(sumstat$eaf,type = "pretty"))

#Mean eaf:
mean(sumstat$eaf)
sd(sumstat$eaf)
##for all varis maf001:
df <- fread("output/maf001_pheno_1_5_ratio_betase_input_mungestat",header=T)
mean(df$eaf)
#0.2609518
sd(df$eaf)
#0.2634782
exp(mean(df$LOG_ODDS))
exp(mean(df$LOG_ODDS) - qnorm(0.975)*mean(df$se))
exp(mean(df$LOG_ODDS) + qnorm(0.975)*mean(df$se))

#Mean OR and 95% CI:
exp(mean(sumstat$LOG_ODDS))
exp(mean(sumstat$LOG_ODDS) - qnorm(0.975)*mean(sumstat$se))
exp(mean(sumstat$LOG_ODDS) + qnorm(0.975)*mean(sumstat$se))

#P-value count by eaf bin:
# Define the number of colors you want
png("output/pvaluefreq_by_eafbins_genomesignif_vars.png",width = 1900, height = 800)
sumstat %>%
  ggplot() + aes(eaf_bin) +
  geom_histogram(aes(y = after_stat(count / sum(count))), stat = "count") +
  ylab("P-value (frequency)") +
  xlab("Effect allele frequency (bin)") + theme_classic() +
  theme(axis.title.x = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.title.y = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.text.y = element_text(size=16),
      axis.text.x = element_text(size=16), legend.position = "none")
dev.off()


png("output/pvaluecount_by_eafbins_genomesignif_vars.png",width = 1900, height = 800)
sumstat %>%
  ggplot() + aes(eaf_bin) +
  geom_histogram(stat = "count") +
  ylab("P-value (count)") +
  xlab("Effect allele frequency (bin)") + theme_classic() +
  theme(axis.title.x = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.title.y = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.text.y = element_text(size=16),
      axis.text.x = element_text(size=16), legend.position = "none")
dev.off()


#OR values by eaf bin:
sumstat$OR <- exp(sumstat$LOG_ODDS)
png("output/OR_by_eafbins_genomesignif_vars.png",width = 1500, height = 600)
sumstat %>% mutate(eaf_bin=binning(sumstat$eaf,type = "pretty") %>% extract()) %>% target_by(OR) %>% relate(eaf_bin) %>% plot() +
xlab("Effect allele frequency (bin)") +
ylab("Odds Ratio") +
labs() +
scale_fill_manual(values=as.vector(polychrome(26))) +
ggtitle("P-values by effect allele frequency (bins)") +
theme(axis.title.x = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.title.y = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.text.y = element_text(size=16),
      axis.text.x = element_text(size=16), legend.position = "none")
dev.off()




#For odds ratio:
#number of genome-wide significant variants by eaf bins:
sumstat <- sumstat %>% mutate(eaf_bin=binning(sumstat$eaf,type = "quantile"))
sumstat$eaf_bin <- recode_factor(sumstat$eaf_bin, "[0.0273758,0.1555505]" = "[0.027,0.156]",
"(0.1555505,0.2108449]" = "(0.156,0.211]",
"(0.2108449,0.287111]" = "(0.156,0.287]",
"(0.287111,0.3339469]" = "(0.287,0.334]",
"(0.3339469,0.3511515]"= "(0.334,0.351]",
"(0.3511515,0.3587672]" = "(0.351,0.359]",
"(0.3587672,0.3724535]" = "(0.359,0.372]",
"(0.3724535,0.4090092]" = "(0.372,0.409]",
"(0.4090092,0.4658285]" = "(0.409,0.466]",
"(0.4658285,0.599728]" = "(0.466,0.600]",
"(0.599728,0.6092652]" = "(0.600,0.609]",
"(0.6092652,0.6104076]" = "(0.609,0.610]",
"(0.6104076,0.831513]" = "(0.610,0.832]" )
sumstat$OR <- exp(sumstat$LOG_ODDS)
png("output/OR_by_eafbins_genomesignif_vars.png",width = 1500, height = 600)
sumstat %>% mutate(eaf_bin=binning(sumstat$eaf,type = "quantile") %>% extract()) %>% target_by(OR) %>% relate(eaf_bin) %>% plot() +
xlab("Effect allele frequency (bin)") +
ylab("Odds Ratio") +
labs() +
scale_fill_manual(values=as.vector(polychrome(26))) +
ggtitle("P-values by effect allele frequency (bins)") +
theme(axis.title.x = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.title.y = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.text.y = element_text(size=16),
      axis.text.x = element_text(size=16), legend.position = "none")
dev.off()




#it's pretty, but atually not informative
png("output/pvalue_by_eafbins_genomesignif_vars.png",width = 1500, height = 600)
sumstat %>% mutate(eaf_bin=binning(sumstat$eaf,type = "quantile") %>% extract()) %>% target_by(pval) %>% relate(eaf_bin) %>% plot() +
xlab("Effect allele frequency (bin)") +
ylab("P-value") +
labs() +
scale_fill_manual(values=as.vector(polychrome(26))) +
ggtitle("P-values by effect allele frequency (bins)") +
theme(axis.title.x = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.title.y = element_text(vjust = 0.5, hjust=0.5, size=21),
      axis.text.y = element_text(size=16),
      axis.text.x = element_text(size=16), legend.position = "none")
dev.off()