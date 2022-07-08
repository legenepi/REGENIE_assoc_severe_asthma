#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)
library(plotrix)
library(rcartocolor)
library(dplyr)

#upload file with plot fucntions:
source("./src/fc_donut_chart.R")

#function to find N valid values, mean and standard error for a quantitative variable in a dataset:
##NB: dataset needs to have quantitative variable only !
quant_descr <- function(dataset) {
for (col in colnames(dataset)){
print(paste0("column:",col))
print(paste0("N valid values:",length(na.omit(dataset[[col]]))))
print(paste0("mean:",mean(dataset[[col]],na.rm=TRUE)))
print(paste0("std error:",std.error(dataset[[col]],na.rm)))
print("-------------------------------")}}

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"

demo_file <- paste0(path_prefix,"demographics.txt")

demo <- fread(demo_file,sep= "\t",header=TRUE)


#pre-processing step:
#make categorical variables as factor:
demo$eid <- as.factor(demo$eid)
demo$genetic_sex <- as.factor(demo$genetic_sex)
demo$SA_scripts <- as.factor(demo$SA_scripts)
demo$SAMOSEMO_scripts <- as.factor(demo$SAMOSEMO_scripts)
demo$SAMI_scripts <- as.factor(demo$SAMI_scripts)
demo$SAPred_scripts <- as.factor(demo$SAPred_scripts)
demo$controls <- as.factor(demo$controls)
demo$asthma_diagnosis <- as.factor(demo$asthma_diagnosis)
demo$MOSE_scripts <- as.factor(demo$MOSE_scripts)
demo$MO_scripts <- as.factor(demo$MO_scripts)
demo$MI_scripts <- as.factor(demo$MI_scripts)
demo$smoking_status <- as.factor(demo$smoking_status)
demo$ethnic_background <- as.factor(demo$ethnic_background)
demo$sex <- as.factor(demo$sex)
demo <- demo %>% rename(clustered_ancestry = clustered.ethnicity)
demo$clustered.ethnicity <- as.factor(demo$clustered.ethnicity)
demo$category_onset <- as.factor(demo$category_onset)

#make numerical variables as numeric:
demo$age_onset_merge <- as.numeric(demo$age_onset_merge)
demo$cigarette_pack_years <- as.numeric(demo$cigarette_pack_years)
demo$age_at_recruitment <- as.numeric(demo$age_at_recruitment)
demo$BMI <- as.numeric(demo$BMI)
demo$best_FEV1 <- as.numeric(demo$best_FEV1)
demo$perc_pred_FEV1 <- as.numeric(demo$perc_pred_FEV1)
demo$ratio_FEV1_FVC <- as.numeric(demo$ratio_FEV1_FVC)
demo$age_onset <- as.numeric(demo$age_onset)
demo$age_onset_doc <- as.numeric(demo$age_onset_doc)
demo$age_onset_merge <- as.numeric(demo$age_onset_merge)

#all the PCs are num so it is fine

#to check the class of each columns:
str(demo)

#create the pheno cols with levels: severe_asthma, moderate_severe_asthma, moderate_asthma, mild_asthma, controls
demo <- demo %>% mutate(pheno = case_when(controls == 1 ~ "Controls",
                                          SAMOSEMO_scripts == 1 ~ "SA Moderate_Severe_Moderate",
                                          SAMI_scripts == 1 ~ "SA Mild",
                                          SAPred_scripts == 1 ~ "SA Prednisolone",
                                          MOSE_scripts == 1 ~ "Moderate_Severe",
                                          MO_scripts == 1 ~ "Moderate",
                                          MI_scripts == 1 ~ "Mild"))
demo$pheno <- as.factor(demo$pheno)

demo <- demo %>% filter(!is.na(pheno))

SA_only <- demo %>% filter(SA_scripts == 1)
controls_only <- demo %>% filter(controls == 1)
MOSE_only <- demo %>% filter(MOSE_scripts == 1)
MO_only <- demo %>% filter(MO_scripts == 1)
MI_only <- demo %>% filter(MI_scripts == 1)

#for numeric variables:
demo_num <- select_if(demo, is.numeric)
quant_descr(demo_num)
SA_only_num <- select_if(SA_only, is.numeric)
quant_descr(demo_num)
controls_only_num <- select_if(controls_only, is.numeric)
quant_descr(controls_only_num)

#genetic sex
#percentage stacked barchart:
pheno_sex <- demo %>% select(pheno,genetic_sex)

pheno_sex_stacked <- pheno_sex %>%
  count(pheno, genetic_sex) %>%
  group_by(pheno) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(pheno, pct, fill=genetic_sex) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 7) +
  scale_fill_manual(values=c("#5d8aa8","#89cff0","#f0f8ff"), labels=c('Females', 'Males', 'NA')) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 16), legend.text = element_text(size = 15))
ggsave("data/pheno_sex_stacked.png",pheno_sex_stacked,width=20,height=11)


#smoking status:
pheno_smk <- demo %>% select(pheno,smoking_status)
pheno_smk_stacked <- pheno_smk %>%
  count(pheno, smoking_status) %>%
  group_by(pheno) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(pheno, pct, fill=smoking_status) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 7) +
  scale_fill_manual(values=c("#5d8aa8","#89cff0","#f0f8ff","#7fffd4"),
                    labels=c('Prefer not to answer', 'Never', 'Previous', 'Current', 'NA')) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 16), legend.text = element_text(size = 15))
ggsave("data/pheno_smoking_status_stacked.png",pheno_smk_stacked,width=20,height=11)


#cigarette_pack_years
pheno_ciga <- demo %>% select(pheno,cigarette_pack_years)
means <- aggregate(cigarette_pack_years ~ pheno , pheno_ciga, mean)
pheno_ciga_boxplot <- pheno_ciga %>% ggplot(aes(pheno,cigarette_pack_years)) +
                      geom_boxplot() +
                      #ylim(c(0,2.5)) +
                      ylab("Cigarette pack years") +
                      theme_classic() +
                      geom_text(data = means, aes(label = round(cigarette_pack_years,2), y = 0, fontface = "bold"), size = 5) +
                      theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
                      axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
                      legend.title = element_text(size = 16), legend.text = element_text(size = 15))
ggsave("data/pheno_cigarette_pack_years_boxplot.png",pheno_ciga_boxplot,width=20,height=11)


#age
pheno_age <- demo %>% select(pheno,age_at_recruitment)
means <- aggregate(age_at_recruitment ~ pheno , pheno_age, mean)
pheno_ciga_boxplot <- pheno_age %>% ggplot(aes(pheno,age_at_recruitment)) +
                      geom_boxplot() +
                      #ylim(c(0,2.5)) +
                      ylab("Age at recruitment") +
                      theme_classic() +
                      geom_text(data = means, aes(label = round(age_at_recruitment,2), y = 38, fontface = "bold"), size = 5) +
                      theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
                      axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
                      legend.title = element_text(size = 16), legend.text = element_text(size = 15))
ggsave("data/pheno_age_at_recruitment_boxplot.png",pheno_ciga_boxplot,width=20,height=11)

#genetic ancestry
pheno_anc <- demo %>% select(pheno,clustered_ancestry)
pheno_anc_stacked <- pheno_anc %>%
  count(pheno, clustered_ancestry) %>%
  group_by(pheno) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(pheno, pct, fill=clustered_ancestry) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 5) +
  scale_fill_manual(values=c("#5d8aa8","#89cff0","#f0f8ff","#7fffd4","#ab82ff","#6495ed","#8470ff")) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 18), legend.text = element_text(size = 17))
ggsave("data/pheno_clustered_ancestry_stacked.png",pheno_anc_stacked,width=20,height=18)


#ethnic background
pheno_eth <- demo %>% select(pheno,ethnic_background)
pheno_eth_stacked <- pheno_eth %>%
  count(pheno,ethnic_background ) %>%
  group_by(pheno) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(pheno, pct, fill=ethnic_background) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  #scale_fill_manual(values=c("#5d8aa8","#89cff0","#f0f8ff","#7fffd4")) +
  theme_classic() +
  #geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
  #          position=position_stack(vjust=0.5), size = 5) +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 18), legend.text = element_text(size = 17))
ggsave("data/pheno_ethnic_background_stacked.png",pheno_eth_stacked,width=20,height=17)

#PCA plot: PC1, PC2 and genetic cluster:
PCA_anc_plot <- ggplot() +
	geom_point(data=demo,aes(x=PC1, y=PC2,colour=clustered_ancestry, shape=clustered_ancestry), cex=2.6) +
	scale_color_manual(values=c("lawngreen","lightseagreen","orchid2","navy","yellow","#ab82ff", "black"))+
	scale_shape_manual(values=c(3,2,5,0,6,15,4))+
	theme_classic() +
	theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
    axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
    legend.title = element_text(size = 16), legend.text = element_text(size = 15))
ggsave("data/PCA_anc_plot.png",PCA_anc_plot,width=12,height=12)


#BMI:
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
ggsave("data/pheno_BMI_boxplot.png",pheno_BMI_boxplot,width=20,height=11)


#category_onset
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
ggsave("data/pheno_category_onset_stacked.png",pheno_onset_stacked,width=20,height=11)

#FEV1/FVC:
pheno_ratio_FEV1_FVC <- demo %>% select(pheno,ratio_FEV1_FVC)
means <- aggregate(ratio_FEV1_FVC ~ pheno , pheno_ratio_FEV1_FVC, mean)
pheno_ratio_FEV1_FVC_boxplot <- pheno_ratio_FEV1_FVC %>% ggplot(aes(pheno,ratio_FEV1_FVC)) +
                      geom_boxplot() +
                      #ylim(c(0,2.5)) +
                      ylab("FEV1/FVC") +
                      theme_classic() +
                      geom_text(data = means, aes(label = round(ratio_FEV1_FVC,2), y = 0.10, fontface = "bold"), size = 7) +
                      theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
                      axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
                      legend.title = element_text(size = 16), legend.text = element_text(size = 15))
ggsave("data/pheno_ratio_FEV1_FVC_boxplot.png",pheno_ratio_FEV1_FVC_boxplot,width=20,height=11)