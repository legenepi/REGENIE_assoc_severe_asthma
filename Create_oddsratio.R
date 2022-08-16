#!/usr/bin/env Rscript


suppressMessages(library(tidyverse))
suppressMessages(library(data.table))

#inputfile:
input_file = "output/maf001_pheno_1_5_ratio_sentinel_variants.txt"
output_file = "output/maf001_pheno_1_5_ratio_sentinel_variants_OR.txt"

#input:
sumstat <- read.table(input_file,header=T)

#create odds_ratio ci_lower ci_upper
sumstat$odds_ratio <- exp(sumstat$LOG_ODDS)
sumstat$ci_lower <- exp(sumstat$LOG_ODDS - qnorm(0.975)*sumstat$se)
sumstat$ci_upper <- exp(sumstat$LOG_ODDS + qnorm(0.975)*sumstat$se)

#create unique column:
sumstat$'OR_95_CI' <- paste0(format(round(sumstat$odds_ratio,2),nsmall=2)," [",format(round(sumstat$ci_lower,2),nsmall=2),"-",format(round(sumstat$ci_upper,2),nsmall=2),"]")

#direction of effect:
sumstat <- sumstat %>% mutate(direction_of_effect=ifelse(sumstat$LOG_ODDS > 0, "+","-"))

write.table(sumstat,output_file,sep="\t",quote=F,row.names=F)


#For genome-wide sumstat:
#inputfile:
input_file = "output/maf001_pheno_1_5_ratio_genomewide_signif"
output_file = "output/maf001_pheno_1_5_ratio_genomewide_signif_OR.txt"

#input:
sumstat <- fread(input_file,header=T)
colnames(sumstat) <- c("snpid", "b37chr", "bp", "a1", "a2", "LOG_ODDS", "se", "eaf", "pval", "MAF")

#create odds_ratio ci_lower ci_upper
sumstat$odds_ratio <- exp(sumstat$LOG_ODDS)
sumstat$ci_lower <- exp(sumstat$LOG_ODDS - qnorm(0.975)*sumstat$se)
sumstat$ci_upper <- exp(sumstat$LOG_ODDS + qnorm(0.975)*sumstat$se)

#create unique column:
sumstat$'OR_95_CI' <- paste0(format(round(sumstat$odds_ratio,2),nsmall=2)," [",format(round(sumstat$ci_lower,2),nsmall=2),"-",format(round(sumstat$ci_upper,2),nsmall=2),"]")

#direction of effect:
sumstat <- sumstat %>% mutate(direction_of_effect=ifelse(sumstat$LOG_ODDS > 0, "+","-"))

write.table(sumstat,output_file,sep="\t",quote=F,row.names=F)


#Mean OR and 95%CI for all maf001 variants:
exp(mean(sumstat$LOG_ODDS))