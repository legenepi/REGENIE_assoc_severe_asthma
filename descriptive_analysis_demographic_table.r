#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)
library(plotrix)
library(rcartocolor)


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
path_prefix <- "/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data/"

demo_file <- paste0(path_prefix,"demo_pheno_cov.txt")

demo <- read.table(demo_file,sep= " ",header=TRUE)

#make eid, genetic_sex, pheno_modsev_all_age categorical variables:
demo$eid <- as.factor(demo$eid)
demo$genetic_sex <- as.factor(demo$genetic_sex)
demo$pheno_modsev_all_age <- as.factor(demo$pheno_modsev_all_age)
#make age_onset_merge numeric:
demo$age_onset_merge <- as.numeric(demo$age_onset_merge)


#remove any participant neither case nor control for pheno_modsev_all_age
modsev_demo <- demo %>% filter(!is.na(pheno_modsev_all_age))

#modsev descriptive:
modsev_demo_quantitative <- modsev_demo %>% select(eid, genetic_sex, pheno_modsev_all_age,
                                                            age_at_recruitment,
                                                            BMI,
                                                            age_onset_merge,
                                                            best_FEV1,
                                                            perc_pred_FEV1,
                                                            ratio_FEV1_FVC,
                                                            cigarette_pack_years
                                                            )
#all modsev dataset:
quant_descr(modsev_demo_quantitative[,-c(1,2,3)])

#venn diagram for cases showing numbers of participants sharing or not sharing different evidences of diagnosis:
# take the code from previous script !

#case modsev dataset:
case_modsev_demo_quantitative <- modsev_demo_quantitative %>% filter(pheno_modsev_all_age == 1)
quant_descr(case_modsev_demo_quantitative[,-c(1,2,3)])

female_case_modsev_demo_quantitative <- case_modsev_demo_quantitative %>% filter(genetic_sex == "0")
quant_descr(female_case_modsev_demo_quantitative[,-c(1,2,3)])

male_case_modsev_demo_quantitative <- case_modsev_demo_quantitative %>% filter(genetic_sex == "1")
quant_descr(male_case_modsev_demo_quantitative[,-c(1,2,3)])


#control modsev dataset:
control_modsev_demo_quantitative <- modsev_demo_quantitative %>% filter(pheno_modsev_all_age == 0)
quant_descr(control_modsev_demo_quantitative[,-c(1,2,3)])

female_control_modsev_demo_quantitative <- control_modsev_demo_quantitative %>% filter(genetic_sex == "0")
quant_descr(female_control_modsev_demo_quantitative[,-c(1,2,3)])

male_control_modsev_demo_quantitative <- control_modsev_demo_quantitative %>% filter(genetic_sex == "1")
quant_descr(male_control_modsev_demo_quantitative[,-c(1,2,3)])


#qualitative:
table(modsev_demo$pheno_modsev_all_age, modsev_demo$clustered.ethnicity)
table(modsev_demo$pheno_modsev_all_age, modsev_demo$ethnic_background)
table(modsev_demo$pheno_modsev_all_age, modsev_demo$smoking_status)

table(case_modsev_demo$pheno_modsev_all_age, case_modsev_demo$clustered.ethnicity)
table(case_modsev_demo$pheno_modsev_all_age, case_modsev_demo$ethnic_background)
table(case_modsev_demo$pheno_modsev_all_age, case_modsev_demo$smoking_status)

table(female_case_modsev_demo$pheno_modsev_all_age, female_case_modsev_demo$clustered.ethnicity)
table(female_case_modsev_demo$pheno_modsev_all_age, female_case_modsev_demo$ethnic_background)
table(female_case_modsev_demo$pheno_modsev_all_age, female_case_modsev_demo$smoking_status)

table(male_case_modsev_demo$pheno_modsev_all_age, male_case_modsev_demo$clustered.ethnicity)
table(male_case_modsev_demo$pheno_modsev_all_age, male_case_modsev_demo$ethnic_background)
table(male_case_modsev_demo$pheno_modsev_all_age, male_case_modsev_demo$smoking_status)

##same for control, but look again to fin a smarter way to do this. Maybe use barplot ?

#barplot for ethnicity:
ggplot(modsev_demo %>% filter(clustered.ethnicity != "", clustered.ethnicity != "NA")) +
  aes(x = clustered.ethnicity, fill = clustered.ethnicity) +
  geom_bar() +
  xlab("Genetic ancestry") +
  ylab("Count") +
  theme_light() +
  scale_fill_carto_d(palette = "Earth") +
  theme(legend.position = "none")
ggsave(paste0(path_prefix,"genetic_ancestry_modsev_allage.png"))

#barplot for ethnic background:
#coding1001.tsv from UKBiobank showcase to retrieve actual name for each ethnic group
ethnic_codename <- read.table(paste0(path_prefix,"coding1001.tsv"),sep="\t",header=TRUE)
colnames(ethnic_codename)[1] <- "ethnic_background"
ethnic_codename <- ethnic_codename %>% select(ethnic_background,meaning)
demo_ethnic <- demo %>% select(eid, ethnic_background)
demo_ethnic_codename <- left_join(demo_ethnic,ethnic_codename,by="ethnic_background")
ggplot(demo_ethnic_codename) +
  aes(x = meaning, fill = meaning) +
  geom_bar() +
  xlab("Ethnic background") +
  ylab("Count") +
  theme_light() +
  scale_fill_manual(values = c("#A16928","#c29b64","#e0cfa2","#cbd5bc","#85adaf","#2887a1",
  "#66C5CC","#F6CF71","#F89C74","#DCB0F2","#87C55F","#9EB9F3","#B3B3B3",
  "#ffc6c4","#f4a3a8","#e38191","#cc607d","#ad466c","#8b3058","#672044",
  "#fcde9c","#faa476","#f0746e","#e34f6f","#dc3977")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  theme(legend.position = "none")
ggsave(paste0(path_prefix,"ethnic_background_modsev_allage.png"))

#Donut Plots for ethnicity with pie chart in the middle for case/control status:


#PCA plot:
TO BE MODIFIED
pca12_plot <- ggplot(modsev_demo, aes(PC1, PC2, col= clustered.ethnicity, shape = pheno_modsev_all_age))
pca12_plot <- pca12_plot + geom_point(aes(PC1, PC2, col= clustered.ethnicity))
pca12_plot <- pca12_plot + scale_color_manual(values = c("#A16928","#c29b64","#e0cfa2","#cbd5bc","#85adaf","#2887a1","#"))
pca12_plot <- pca12_plot + theme_light()
pca12_plot <- pca12_plot + xlab("PC1") + ylab("PC2")
pca12_plot + ggtitle(paste0("PCs plot modsev asthma"))
ggsave(paste0(path_prefix,"PCA12_plot_modsev_allage.png"))