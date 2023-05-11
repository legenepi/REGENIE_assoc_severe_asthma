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

#hospitalisation:
hesin <- read.table(paste0(path_prefix,"data/QC_hesin_diag_asthma.txt"),sep="\t",header=TRUE) %>%
         select(app56607_ids, level) %>% unique()
colnames(hesin) <- c("eid","hesin")
hesin$eid<- as.factor(hesin$eid)
hesin$hesin <- as.factor(hesin$hesin)

demo_hesin <- left_join(demo,hesin,by="eid")

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

#Prednisolone use:
eid_pred <- fread(paste0(path_prefix,"data/all_UKBB_with_prednisolone_gp_scripts_edit"))
eid_scripts <- fread(paste0(path_prefix,"data/all_UKBB_with_any_gp_scripts_edit"))
eid_pred$pred_use <- as.factor(1)
eid_scripts$scripts <- as.factor(1)
eid_pred$V1 <- as.factor(eid_pred$V1)
eid_scripts$V1 <- as.factor(eid_scripts$V1)
eid_script_pred <- left_join(eid_scripts,eid_pred,by="V1")
eid_script_pred <- eid_script_pred %>% mutate(pred_use = ifelse(is.na(eid_script_pred$pred_use), 0, 1))
colnames(eid_script_pred)[1] <- "eid"
eid_script_pred$eid <- as.factor(eid_script_pred$eid)
eid_script_pred <- eid_script_pred %>% select(eid,pred_use)
demo <- left_join(demo,eid_script_pred,by="eid")


##Hay fever-rhinitis, eczema/atopic dermatitis:
allergy <- fread("/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt",header=F)
allergy <- unique(allergy)
colnames(allergy)[1] <- "eid"
allergy$eid <- as.character(allergy$eid)
allergy$allergy <- as.factor("1")
demo_allergy <- left_join(demo,allergy,by="eid")



#Test continuous variable with Wilcox Mann-Whitney test:
#age :
print("Age")
wilcox.test(demo$age_at_recruitment~demo$broad_pheno_1_5_ratio)

#BMI
print("BMI")
wilcox.test(demo$BMI~demo$broad_pheno_1_5_ratio)

#FEV1 % predicted
print("FEV1 % predicted")
wilcox.test(demo$perc_pred_FEV1~demo$broad_pheno_1_5_ratio)

#ratio_FEV1_FVC
print("ratio FEV1 FVC")
wilcox.test(demo$ratio_FEV1_FVC~demo$broad_pheno_1_5_ratio)

#eosinophil:
print("eosinophil")
wilcox.test(demo_eos$max_eos~demo_eos$broad_pheno_1_5_ratio)

#neutrophil:
print("neutrophil")
wilcox.test(demo_neu$max_neu~demo_eos$broad_pheno_1_5_ratio)

#Test categorical variable with chiqs.test():

#sex:
print("sex")
chisq.test(table(demo$genetic_sex,demo$broad_pheno_1_5_ratio))

#hesin
print("hesin")
demo_hesin_2 <- demo_hesin %>% select(broad_pheno_1_5_ratio,hesin) %>% drop_na()
chisq.test(table(demo_hesin_2$hesin,demo_hesin_2$broad_pheno_1_5_ratio))

#Smoking status (ubiopred):
print("smokig status")
chisq.test(table(demo$ubiopred_smk,demo$broad_pheno_1_5_ratio))

#Category onset:
print("category onset")
chisq.test(table(demo$category_onset,demo$broad_pheno_1_5_ratio))

#Prednisolone use:
print("prednisolone use")
chisq.test(table(demo$pred_use,demo$broad_pheno_1_5_ratio))

#Hay fever-rhinitis, eczema/atopic dermatitis:
print("allergic condition")
chisq.test(table(demo_allergy$allergy,demo_allergy$broad_pheno_1_5_ratio))