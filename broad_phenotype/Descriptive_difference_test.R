#!/usr/bin/env Rscript


#run and save it as : Rscript src/broad_phenotype/Descriptive_difference_test.R > /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/descriptive_difference_test_report

library(tidyverse)
library(dplyr)
library(data.table)
library(hablar)


#load input
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_asthmaMeds_stratification/"
demo <- read.table("/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov_broadasthma.txt",header=T,sep=" ")
demo$eid <- as.factor(demo$eid)
demo <- demo %>% rename(clustered_ancestry = clustered.ethnicity)
demo$clustered_ancestry  <- as.factor(demo$clustered_ancestry)
demo$smoking_status <- as.factor(demo$smoking_status)
demo$broad_pheno_1_5_ratio <- as.factor(demo$broad_pheno_1_5_ratio)
demo <- demo %>% filter(!is.na(broad_pheno_1_5_ratio))

#eosinophil:
eos <- fread(paste0(path_prefix,"data/Eosinophill_count_30150.csv"))
colnames(eos) <- c("eid","eos1","eos2","eso3")
eos$eid <- as.factor(eos$eid)

demo_eos <- left_join(demo,eos,by="eid") %>% select(broad_pheno_1_5_ratio,eos1,eos2,eso3)
demo_eos <- demo_eos %>%
  rowwise() %>%
  mutate(min_eos = min_(c_across(-broad_pheno_1_5_ratio)),
         max_eos = max_(c_across(-broad_pheno_1_5_ratio)))

#neutrophil:
neu <- fread(paste0(path_prefix,"data/Neutrophill_count_30140.csv"))
colnames(neu) <- c("eid","neu1","neu2","eso3")
neu$eid <- as.factor(neu$eid)

demo_neu <- left_join(demo,neu,by="eid") %>% select(broad_pheno_1_5_ratio,neu1,neu2,eso3)
demo_neu <- demo_neu %>%
  rowwise() %>%
  mutate(min_neu = min_(c_across(-broad_pheno_1_5_ratio)),
         max_neu = max_(c_across(-broad_pheno_1_5_ratio)))

#smoking as per ubiopred:
#Split participants (both case and controls) into
#non-smokers (according to Shaw et al. 2015: previous/non current smoker with < 5 pack per year history) and
#smokers (according to Shaw et al. 2015: current smoker or ex-smokers with >= 5 pack year history)

demo <- demo %>% mutate(pack_per_year_threshold = case_when(cigarette_pack_years < 5 ~ "less_than_5",
                                                                          cigarette_pack_years >= 5 ~ "equal_or_more_than_5"))

demo <- demo %>% mutate(ubiopred_smk = ifelse((demo$pack_per_year_threshold == "less_than_5" & demo$smoking_status == 1) | demo$smoking_status == 0 , "non_smoker",
                                                      ifelse(demo$smoking_status == 2, "smoker",
                                                      ifelse(demo$pack_per_year_threshold == "equal_or_more_than_5" & demo$smoking_status == 1, "smoker", NA))))


##Hay fever-rhinitis, eczema/atopic dermatitis:
allergy <- fread("/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt",header=F)
allergy <- unique(allergy)
colnames(allergy)[1] <- "eid"
allergy$eid <- as.character(allergy$eid)
allergy$allergy <- as.factor("1")
demo_allergy <- left_join(demo,allergy,by="eid")

#Lung function from Kath file:
bridge_app648_8389 <- fread("/data/gen1/UKBiobank/application_648/mapping_to_app8389.txt",header=T)
bridge_app648_8389$app8389 <- as.character(bridge_app648_8389$app8389)
bridge_app648_8389$app648 <- as.character(bridge_app648_8389$app648)
#awk '{print $1, $52}' /data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_master_app56607.sample \
#    > /data/gen1/UKBiobank_500K/severe_asthma/data/bridge_app648_56607
bridge_app648_56607 <- fread("/data/gen1/UKBiobank_500K/severe_asthma/data/bridge_app648_56607",sep=" ",header=T)
colnames(bridge_app648_56607) <- c("app648","app56607")
bridge_app648_56607$app56607 <- as.character(bridge_app648_56607$app56607)
bridge_app648_56607$app648 <- as.character(bridge_app648_56607$app648)
bridge_648_8389_56607 <- inner_join(bridge_app648_8389,bridge_app648_56607,by="app648")

perc_pred_fev1_kath <- fread("/data/gen1/UKBiobank_500K/severe_asthma/data/percent_pred_fev1.txt",header=T)
fev1_fvc_kath <- fread("/data/gen1/UKBiobank_500K/severe_asthma/data/ff.txt",header=T)
LF_kath <- inner_join(perc_pred_fev1_kath,fev1_fvc_kath,by="ID_1") %>% rename(app648=ID_1)
LF_kath$app648 <- as.character(LF_kath$app648)
LF_kath_app56607 <- left_join(LF_kath, bridge_648_8389_56607, by="app648") %>% select(app56607,fev1_perc_pred,ff.best) %>% rename(eid=app56607)
demo_LF_kath <- left_join(demo,LF_kath_app56607,by="eid")

print("Test continuous variable with Wilcox Mann-Whitney test:")
#age :
print("Age")
wilcox.test(demo$age_at_recruitment~demo$broad_pheno_1_5_ratio)

#BMI
print("BMI")
wilcox.test(demo$BMI~demo$broad_pheno_1_5_ratio)

#FEV1 % predicted
print("FEV1 % predicted")
wilcox.test(demo_LF_kath$fev1_perc_pred~demo_LF_kath$broad_pheno_1_5_ratio)


#ratio_FEV1_FVC
print("ratio FEV1 FVC")
wilcox.test(demo_LF_kath$ff.best~demo_LF_kath$broad_pheno_1_5_ratio)

#eosinophil:
print("eosinophil")
wilcox.test(demo_eos$max_eos~demo_eos$broad_pheno_1_5_ratio)

#neutrophil:
print("neutrophil")
wilcox.test(demo_neu$max_neu~demo_eos$broad_pheno_1_5_ratio)

print("Test categorical variable with chi-square test:")
print("NB: Category onset, Prednisolone use, hospitalisation cannot be test as specific to cases only")

#sex:
print("sex")
chisq.test(table(demo$genetic_sex,demo$broad_pheno_1_5_ratio))

#Smoking status (ubiopred):
print("smokig status")
chisq.test(table(demo$ubiopred_smk,demo$broad_pheno_1_5_ratio))

#Hay fever-rhinitis, eczema/atopic dermatitis:
print("allergic condition")
chisq.test(table(demo_allergy$allergy,demo_allergy$broad_pheno_1_5_ratio))