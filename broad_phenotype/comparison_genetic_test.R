#!/usr/bin/env Rscript


module unload R/4.2.1
module load R/4.1.0

suppressMessages(library(tidyverse))
suppressMessages(library(data.table))

#filter out additive test's sentinel variants
x_dominant <- 'cut -f 1-5 output/maf001_broad_pheno_1_5_ratio_sentinel_variants.txt | grep -F -f - output/maf001_broad_pheno_1_5_ratio_dominant_betase_input_mungestat > output/additive_sentinel_in_dominant'
system(x_dominant)

x_recessive <- 'cut -f 1-5 output/maf001_broad_pheno_1_5_ratio_sentinel_variants.txt | grep -F -f - output/maf001_broad_pheno_1_5_ratio_recessive_betase_input_mungestat > output/additive_sentinel_in_recessive'
system(x_recessive)

additive <- fread("output/maf001_broad_pheno_1_5_ratio_sentinel_variants.txt")
dominant <- fread("output/additive_sentinel_in_dominant")
recessive <- fread("output/additive_sentinel_in_recessive")

additive$test <- as.factor("additive")
dominant$test <- as.factor("dominant")
recessive$test <- as.factor("recessive")

add_dom <- rbind(additive,dominant)
add_dom_rec <- rbind(add_dom,recessive)

#create odds_ratio ci_lower ci_upper
add_dom_rec$odds_ratio <- exp(add_dom_rec$LOG_ODDS)
add_dom_rec$ci_lower <- exp(add_dom_rec$LOG_ODDS - qnorm(0.975)*add_dom_rec$se)
add_dom_rec$ci_upper <- exp(add_dom_rec$LOG_ODDS + qnorm(0.975)*add_dom_rec$se)

add_dom_rec$test <- as.factor(add_dom_rec$test)

#plot OR for the different tests:
or_plot <- add_dom_rec %>% ggplot(aes(x = snpid, y = odds_ratio, color = test)) +
  geom_boxplot(position=position_jitterdodge()) + geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), position = "dodge") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

#and save plot:
ggsave("output/OR_sentinel_genetic_test_boxplot.png",or_plot,width = 11, height = 8)

#plot p-value:
pval_plot <- add_dom_rec %>% ggplot(aes(x = snpid, y = -log10(pval), color = test)) +
  geom_point() +
  geom_hline(yintercept=7.3, linetype="dashed", color = "black") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

#and save plot:
ggsave("output/pval_sentinel_genetic_test_plot.png",pval_plot,width = 11, height = 8)

#compare variants with maf < 0.01
columns = c("snpid", "b37chr", "bp", "a1", "a2", "LOG_ODDS", "se", "eaf", "LOG10P", "MAF", "test")
add_dom_rec_aboveMAF001 = data.frame(matrix(nrow = 0, ncol = length(columns)))
colnames(add_dom_rec_aboveMAF001) = columns

for (i in c("_", "_dominant", "_recessive")){
df_file <- paste0("output/allchr/broad_pheno_1_5_ratio",i,"allchr.assoc.txt.gz")
df <- fread(df_file,header=F)
#CHROM GENPOS ID ALLELE0 ALLELE1 A1FREQ INFO N TEST BETA SE CHISQ LOG10P
#REGENIE: reference allele (allele 0), alternative allele (allele 1)
#REGENIE:  estimated effect sizes (for allele 1 on the original scale)
colnames(df) <- c("CHROM", "GENPOS", "ID", "ALLELE0", "ALLELE1", "A1FREQ", "INFO", "N","TEST", "BETA", "SE", "CHISQ", "LOG10P")
df <- df %>% select(CHROM,ID,GENPOS,ALLELE1,ALLELE0,A1FREQ,LOG10P,BETA,SE,TEST)
#select column in order:
df <- df %>% select(ID,CHROM,GENPOS,ALLELE1,ALLELE0,BETA,SE,A1FREQ,LOG10P, TEST)
#rename columns :
colnames(df) <- c("snpid", "b37chr", "bp", "a1", "a2", "LOG_ODDS", "se", "eaf", "LOG10P", "test")
df <- df %>% mutate(MAF = ifelse(df$eaf <= 0.5, df$eaf, 1 - df$eaf))
df_above_MAF001 <- df %>% filter(MAF < 0.01)
add_dom_rec_aboveMAF001 <- rbind(add_dom_rec_aboveMAF001,df_above_MAF001)
}

add_dom_rec_aboveMAF001$test <- as.factor(add_dom_rec_aboveMAF001$test)

#plot MAF by test:
maf_plot <- ggplot(add_dom_rec_aboveMAF001, aes(x=MAF)) + geom_histogram(position="identity", alpha=0.5) + facet_grid(~test)
#and save plot:
ggsave("output/MAF_genetic_test_boxplot.png",maf_plot,width = 11, height = 8)

#plot p-val by test:
pval_plot <- ggplot(add_dom_rec_aboveMAF001, aes(x=-LOG10P)) + geom_histogram(position="identity", alpha=0.5) + facet_grid(~test)
#and save plot:
ggsave("output/pval_genetic_test_boxplot.png",maf_plot,width = 11, height = 8)

