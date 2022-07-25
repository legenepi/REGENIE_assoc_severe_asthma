#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)
library(plotrix)
library(rcartocolor)
library(dplyr)

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
path_prefix_2 <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_asthmaMeds_stratification/data/"

demo_file <- paste0(path_prefix,"demographics.txt")

demo <- fread(demo_file,sep= "\t",header=TRUE)

severe <- fread(paste0(path_prefix_2,"Eid_severe_intersection"),header=F)
severe$cases <- as.factor("1")

severe_GINA <- fread(paste0(path_prefix_2,"Eid_Nociclosporine_Severe_Asthma_NoCOPD_Noecb_QC_Asthma_Meds_asthma_diagnosis_gp_script.txt"),header=F)

#Split severe asthma participants into binary corticosteroids:
severe_OCS <- fread(paste0(path_prefix_2,"Eid_severe_intersection_OCS"),header=F)
severe_OCS$OCS <- as.factor("1")

severe_noOCS <- fread(paste0(path_prefix_2,"Eid_severe_intersection_noOCS"),header=F)
severe_noOCS$OCS <- as.factor("0")

severe_OCS_status <- rbind(severe_OCS, severe_noOCS)

severe <- left_join(severe,severe_OCS_status, by="V1")

colnames(severe)[1] <- "eid"

demo_severe <- left_join(demo,severe,by="eid")

#Split participants into all-comer asthma with OCS and without:
severe_GINA$OCS_allcomer <- as.factor("1")
colnames(severe_GINA)[1] <- "eid"

demo_severe <- left_join(demo_severe,severe_GINA,by="eid")

#Split participants (both case and controls) into
#non-smokers (according to Shaw et al. 2015: previous/non current smoker with < 5 pack per year history) and
#smokers (according to Shaw et al. 2015: current smoker or ex-smokers with >= 5 pack year history)
demo$cigarette_pack_years <- as.numeric(demo$cigarette_pack_years)

demo_severe <- demo_severe %>% mutate(pack_per_year_threshold = case_when(cigarette_pack_years < 5 ~ "less_than_5",
                                                                          cigarette_pack_years >= 5 ~ "equal_or_more_than_5"))

demo_severe <- demo_severe %>% mutate(ubiopred_smk = ifelse(
                                                      demo_severe$pack_per_year_threshold == "less_than_5" & demo_severe$smoking_status == 1, "non_smoker",
                                                      ifelse(demo_severe$smoking_status == 2, "smoker",
                                                      ifelse(demo_severe$pack_per_year_threshold == "equal_or_more_than_5" & demo_severe$smoking_status == 1, "smoker", NA))))

demo_severe <- demo_severe %>% mutate(pheno = case_when(controls == 1 ~ 0, cases == 1 ~ 1))
demo <- demo_severe %>% filter(!is.na(pheno))
demo$pheno <- as.factor(demo$pheno)

pheno_smk <- demo %>% select(pheno,ubiopred_smk)
pheno_smk_stacked <- pheno_smk %>%
  count(pheno, ubiopred_smk) %>%
  group_by(pheno) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(pheno, pct, fill=ubiopred_smk) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 7) +
  scale_fill_manual(values=c("#5d8aa8","#89cff0","#f0f8ff")) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 16), legend.text = element_text(size = 15))


pheno_BMI <- demo %>% select(pheno,BMI)
means <- aggregate(BMI ~ pheno , pheno_BMI, mean)
pheno_BMI_boxplot <- pheno_BMI %>% ggplot(aes(pheno,BMI)) +
                      geom_boxplot() +
                      #ylim(c(0,2.5)) +
                      ylab("BMI") +
                      theme_classic() +
                      geom_text(data = means, aes(label = round(BMI,2), y = 0,fontface = "bold"), size = 5) +
                      theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
                      axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
                      legend.title = element_text(size = 16), legend.text = element_text(size = 15))


pheno_onset <- demo %>% select(pheno,category_onset)
pheno_onset_stacked <- pheno_onset %>%
  count(pheno,category_onset) %>%
  group_by(pheno) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(pheno, pct, fill=category_onset) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 7) +
  scale_fill_manual(values=c("#5d8aa8","#89cff0","#f0f8ff")) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 18), legend.text = element_text(size = 17))



#Define function to remove outliers:
outliers <- function(x) {

  Q1 <- quantile(x, probs=.25)
  Q3 <- quantile(x, probs=.75)
  iqr = Q3-Q1

 upper_limit = Q3 + (iqr*1.5)
 lower_limit = Q1 - (iqr*1.5)

 x > upper_limit | x < lower_limit
}

remove_outliers <- function(df, cols = names(df)) {
  for (col in cols) {
    df <- df[!outliers(df[[col]]),]
  }
  df
}

SA_LF <- demo %>% select(pheno, ratio_FEV1_FVC)
SA_LF <- SA_LF %>% filter(!is.na(ratio_FEV1_FVC))
SA_LF <- remove_outliers(SA_LF, 'ratio_FEV1_FVC')
means <- aggregate(ratio_FEV1_FVC ~ pheno, SA_LF, mean)
SA_LF %>%
     ggplot(aes(pheno,ratio_FEV1_FVC)) +
     geom_boxplot() +
     ylab("ratio_FEV1_FVC - QC LF") +
     xlab("Phenotype") +
     theme_classic() +
     geom_text(data = means, aes(label = round(ratio_FEV1_FVC,2), y = 0, fontface = "bold"), size = 5) +
     theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16))


SA_LF <- demo %>% select(pheno, perc_pred_FEV1)
SA_LF <- SA_LF %>% filter(!is.na(perc_pred_FEV1))
SA_LF <- remove_outliers(SA_LF, 'perc_pred_FEV1')
means <- aggregate(perc_pred_FEV1 ~ pheno, SA_LF, mean)
SA_LF %>%
     ggplot(aes(pheno,perc_pred_FEV1)) +
     geom_boxplot() +
     ylab("perc_pred_FEV1 - QC LF") +
     xlab("Phenotype") +
     theme_classic() +
     geom_text(data = means, aes(label = round(perc_pred_FEV1,2), y = 0, fontface = "bold"), size = 5) +
     theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16))



SA_LF <- demo %>% select(pheno, best_FEV1)
SA_LF <- SA_LF %>% filter(!is.na(best_FEV1))
SA_LF <- remove_outliers(SA_LF, 'best_FEV1')
means <- aggregate(best_FEV1 ~ pheno, SA_LF, mean)
SA_LF %>%
     ggplot(aes(pheno,best_FEV1)) +
     geom_boxplot() +
     ylab("best_FEV1 - QC LF") +
     xlab("Phenotype") +
     theme_classic() +
     geom_text(data = means, aes(label = round(best_FEV1,2), y = 0, fontface = "bold"), size = 5) +
     theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16))

age_LF <- demo %>% select(pheno, age_at_recruitment, ratio_FEV1_FVC)
age_LF <- age_LF %>% filter(!is.na(ratio_FEV1_FVC))
age_LF <- remove_outliers(age_LF, 'ratio_FEV1_FVC')

# Add a new column called 'bin': cut the initial 'carat' in bins
age_LF <- age_LF %>% mutate(bin_age=cut_width(age_at_recruitment, width=5, boundary=0))

age_LF %>%
     ggplot(aes(bin_age,ratio_FEV1_FVC,fill=pheno)) +
     geom_boxplot() +
     ylab("ratio_FEV1_FVC - QC LF") +
     scale_fill_manual(values=c("#5d8aa8","#89cff0")) +
     theme_classic() +
     theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16))
