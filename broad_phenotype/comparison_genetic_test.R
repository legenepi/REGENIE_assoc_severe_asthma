#!/usr/bin/env Rscript


#module unload R/4.2.1
#module load R/4.1.0

suppressMessages(library(tidyverse))
suppressMessages(library(data.table))

#filter out additive model's sentinel variants
x_dominant <- 'cut -f 1-5 output/maf001_broad_pheno_1_5_ratio_sentinel_variants.txt | grep -F -f - output/maf001_broad_pheno_1_5_ratio_dominant_betase_input_mungestat > output/additive_sentinel_in_dominant'
system(x_dominant)

x_recessive <- 'cut -f 1-5 output/maf001_broad_pheno_1_5_ratio_sentinel_variants.txt | grep -F -f - output/maf001_broad_pheno_1_5_ratio_recessive_betase_input_mungestat > output/additive_sentinel_in_recessive'
system(x_recessive)

additive <- fread("output/maf001_broad_pheno_1_5_ratio_sentinel_variants.txt")
dominant <- fread("output/additive_sentinel_in_dominant")
recessive <- fread("output/additive_sentinel_in_recessive")

additive$model <- as.factor("additive")
dominant$model <- as.factor("dominant")
recessive$model <- as.factor("recessive")

add_dom <- rbind(additive,dominant)
add_dom_rec <- rbind(add_dom,recessive)

#create odds_ratio ci_lower ci_upper
add_dom_rec $odds_ratio <- exp(add_dom_rec$LOG_ODDS)
add_dom_rec $ci_lower <- exp(add_dom_rec$LOG_ODDS - qnorm(0.975)*add_dom_rec$se)
add_dom_rec $ci_upper <- exp(add_dom_rec$LOG_ODDS + qnorm(0.975)*add_dom_rec$se)

#for one model:
add_dom_rec %>% filter(model == "additive") %>% ggplot(aes(x = snpid, y = odds_ratio, color = factor(model))) +
  geom_boxplot() + geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), position = "dodge")

#for three models:
or_plot <- add_dom_rec %>% ggplot(aes(x = snpid, y = odds_ratio, color = factor(model))) +
  geom_boxplot(position=position_jitterdodge()) + geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), position = "dodge") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

ggsave("output/OR_genetic_model_boxplot.png",or_plot)
