#!/usr/bin/env Rscript

library(tidyverse)
library(dplyr)
library(data.table)
library(hablar)


#load input
demo <- read.table("/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data/demo_EUR_pheno_cov.txt",header=T,sep=" ")
demo$eid <- as.factor(demo$eid)
demo <- demo %>% rename(clustered_ancestry = clustered.ethnicity)
demo$clustered_ancestry  <- as.factor(demo$clustered_ancestry)
demo$smoking_status <- as.factor(demo$smoking_status)
demo$pheno_1_5_ratio <- as.factor(demo$pheno_1_5_ratio)
demo <- demo %>% filter(!is.na(pheno_1_5_ratio))


##Plot categorical variables:
categorical_plot <- function(df,cat_var){
colnames(df) <- c("Phenotype","cat_var")
df %>%
  count(Phenotype,cat_var) %>%
  group_by(Phenotype) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(Phenotype, pct, fill=cat_var) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 7) +
  scale_fill_manual(name=cat_var,values= c("#5d8aa8","#89cff0","#f0f8ff")) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 18), legend.text = element_text(size = 17))
ggsave(paste0("data/EUR_case_control_",cat_var,"_plot.png"))
}

df <- demo %>% select(pheno_1_5_ratio,genetic_sex)
df$genetic_sex <- as.factor(df$genetic_sex)
categorical_plot(df,as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,sex)
df$sex <- as.factor(df$sex)
categorical_plot(df,as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,sex_sample_file)
df$sex_sample_file <- as.factor(df$sex_sample_file)
categorical_plot(df,as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,category_onset)
categorical_plot(df,as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,smoking_status)
colnames(df) <- c("Phenotype","smoking_status")
df %>%
  count(Phenotype,smoking_status) %>%
  group_by(Phenotype) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(Phenotype, pct, fill=smoking_status) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 7) +
  scale_fill_manual(name=as.character(colnames(df)[2]),values=c("#5d8aa8","#89cff0","#f0f8ff","#7fffd4")) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 18), legend.text = element_text(size = 17))
ggsave(paste0("data/EUR_case_control_",as.character(colnames(df)[2]),"_plot.png"))

df <- demo %>% select(pheno_1_5_ratio,clustered_ancestry)
colnames(df) <- c("Phenotype","clustered_ancestry")
df %>%
  count(Phenotype,clustered_ancestry) %>%
  group_by(Phenotype) %>%
  mutate(pct= prop.table(n) * 100) %>%
  ggplot() + aes(Phenotype, pct, fill=clustered_ancestry) +
  geom_bar(stat="identity") +
  ylab("Frequency") +
  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5), size = 7) +
  scale_fill_manual(name=as.character(colnames(df)[2]),values=c("#5d8aa8","#89cff0","#f0f8ff","#7fffd4","#ab82ff","#6495ed","#8470ff")) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15),
  axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16),
  legend.title = element_text(size = 18), legend.text = element_text(size = 17))
ggsave(paste0("data/EUR_case_control_",as.character(colnames(df)[2]),"_plot.png"))

#hospitalisation:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_asthmaMeds_stratification/"
hesin <- read.table(paste0(path_prefix,"data/QC_hesin_diag_asthma.txt"),sep="\t",header=TRUE) %>%
         select(app56607_ids, level) %>% unique()
colnames(hesin) <- c("eid","hesin")
hesin$eid<- as.factor(hesin$eid)
hesin$hesin <- as.factor(hesin$hesin)

demo_hesin <- left_join(demo,hesin,by="eid")
df <- demo_hesin %>% select(pheno_1_5_ratio,hesin)
categorical_plot(df,as.character(colnames(df)[2]))





##Plot numeric variables:
#function outliers:
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

#df with cols: category (lancet or our), LF.
numeric_plot <- function(df,num_var){
colnames(df) <- c("Phenotype","num_var")
df <- df %>% filter(!is.na(num_var))
df <- remove_outliers(df, 'num_var')
means <- aggregate(num_var ~ Phenotype, df, mean)
df %>%
     ggplot(aes(Phenotype,num_var)) +
     geom_boxplot() +
     ylab(paste0(num_var, "- QC LF")) +
     theme_classic() +
     geom_text(data = means, aes(label = round(num_var,2), y = 0, fontface = "bold"), size = 5) +
     theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), axis.title.y = element_text(size = 16), axis.title.x = element_text(size = 16))
ggsave(paste0("data/EUR_case_control_",num_var,"_plot.png"))
}

df <- demo %>% select(pheno_1_5_ratio, perc_pred_FEV1)
numeric_plot(df, as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio, ratio_FEV1_FVC)
numeric_plot(df, as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,best_FEV1)
numeric_plot(df, as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,BMI)
numeric_plot(df, as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,age_at_recruitment)
numeric_plot(df, as.character(colnames(df)[2]))

df <- demo %>% select(pheno_1_5_ratio,cigarette_pack_years)
numeric_plot(df, as.character(colnames(df)[2]))

#eosinophil:
eos <- fread(paste0(path_prefix,"data/Eosinophill_count_30150.csv"))
colnames(eos) <- c("eid","eos1","eos2","eso3")
eos$eid <- as.factor(eos$eid)

demo_eos <- left_join(demo,eos,by="eid") %>% select(pheno_1_5_ratio,eos1,eos2,eso3)

demo_eos <- demo_eos %>%
  rowwise() %>%
  mutate(min_eos = min_(c_across(-pheno_1_5_ratio)),
         max_eos = max_(c_across(-pheno_1_5_ratio)))

df <- demo_eos %>% select(pheno_1_5_ratio,max_eos)
numeric_plot(df, as.character(colnames(df)[2]))

#neutrophil:
neu <- fread(paste0(path_prefix,"data/Neutrophill_count_30140.csv"))
colnames(neu) <- c("eid","neu1","neu2","eso3")
neu$eid <- as.factor(neu$eid)

demo_neu <- left_join(demo,neu,by="eid") %>% select(pheno_1_5_ratio,neu1,neu2,eso3)

demo_neu <- demo_neu %>%
  rowwise() %>%
  mutate(min_neu = min_(c_across(-pheno_1_5_ratio)),
         max_neu = max_(c_across(-pheno_1_5_ratio)))

df <- demo_neu %>% select(pheno_1_5_ratio,max_neu)
numeric_plot(df, as.character(colnames(df)[2]))


#smoking as per ubiopred:
#Split participants (both case and controls) into
#non-smokers (according to Shaw et al. 2015: previous/non current smoker with < 5 pack per year history) and
#smokers (according to Shaw et al. 2015: current smoker or ex-smokers with >= 5 pack year history)

demo <- demo %>% mutate(pack_per_year_threshold = case_when(cigarette_pack_years < 5 ~ "less_than_5",
                                                                          cigarette_pack_years >= 5 ~ "equal_or_more_than_5"))

demo <- demo %>% mutate(ubiopred_smk = ifelse((demo$pack_per_year_threshold == "less_than_5" & demo$smoking_status == 1) | demo$smoking_status == 0 , "non_smoker",
                                                      ifelse(demo$smoking_status == 2, "smoker",
                                                      ifelse(demo$pack_per_year_threshold == "equal_or_more_than_5" & demo$smoking_status == 1, "smoker", NA))))

table(demo$pheno_1_5_ratio,demo$ubiopred_smk,exclude = NULL)
df <- demo %>% select(pheno_1_5_ratio,ubiopred_smk)
df$ubiopred_smk <- as.factor(df$ubiopred_smk)
categorical_plot(df,as.character(colnames(df)[2]))

#Find number for descriptive table:
#case-control:
summary(demo$pheno_1_5_ratio)

cases <- demo %>% filter(pheno_1_5_ratio == 1)
controls <- demo %>% filter(pheno_1_5_ratio == 0)

#sex:
summary(as.factor(cases$genetic_sex),exclude=NULL)
prop.table(table(cases$genetic_sex))
summary(as.factor(controls$genetic_sex),exclude=NULL)
prop.table(table(controls$genetic_sex))

#age : mean and SD:
mean(cases$age_at_recruitment,na.rm=TRUE)
sd(cases$age_at_recruitment,na.rm=TRUE)
mean(controls$age_at_recruitment,na.rm=TRUE)
sd(controls$age_at_recruitment,na.rm=TRUE)

#BMI : mean and SD:
mean(cases$BMI,na.rm=TRUE)
sd(cases$BMI,na.rm=TRUE)
mean(controls$BMI,na.rm=TRUE)
sd(controls$BMI,na.rm=TRUE)


#LF : mean and SD:
##FEV1 % predicted
df <- cases %>% filter(!is.na(perc_pred_FEV1))
df <- remove_outliers(df, 'perc_pred_FEV1')
mean(df$perc_pred_FEV1)
sd(df$perc_pred_FEV1)

df <- controls %>% filter(!is.na(perc_pred_FEV1))
df <- remove_outliers(df, 'perc_pred_FEV1')
mean(df$perc_pred_FEV1)
sd(df$perc_pred_FEV1)


##FEV1/FVC:
df <- cases %>% filter(!is.na(ratio_FEV1_FVC))
df <- remove_outliers(df, 'ratio_FEV1_FVC')
mean(df$ratio_FEV1_FVC)
sd(df$ratio_FEV1_FVC)

df <- controls %>% filter(!is.na(ratio_FEV1_FVC))
df <- remove_outliers(df, 'ratio_FEV1_FVC')
mean(df$ratio_FEV1_FVC)
sd(df$ratio_FEV1_FVC)


##Best FEV1
df <- cases %>% filter(!is.na(best_FEV1))
df <- remove_outliers(df, 'best_FEV1')
mean(df$best_FEV1)
sd(df$best_FEV1)

df <- controls %>% filter(!is.na(best_FEV1))
df <- remove_outliers(df, 'best_FEV1')
mean(df$best_FEV1)
sd(df$best_FEV1)

##blood cell count
#eosinophil:
demo_eos_cases <- demo_eos %>% filter(pheno_1_5_ratio == 1)
df <- demo_eos_cases %>% filter(!is.na(max_eos))
df <- remove_outliers(df, 'max_eos')
mean(df$max_eos)
sd(df$max_eos)

demo_eos_controls <- demo_eos %>% filter(pheno_1_5_ratio == 0)
df <- demo_eos_controls %>% filter(!is.na(max_eos))
df <- remove_outliers(df, 'max_eos')
mean(df$max_eos)
sd(df$max_eos)

#neutrophils:
demo_neu_cases <- demo_neu %>% filter(pheno_1_5_ratio == 1)
df <- demo_neu_cases %>% filter(!is.na(max_neu))
df <- remove_outliers(df, 'max_neu')
mean(df$max_neu)
sd(df$max_neu)

demo_neu_controls <- demo_neu %>% filter(pheno_1_5_ratio == 0)
df <- demo_neu_controls %>% filter(!is.na(max_neu))
df <- remove_outliers(df, 'max_neu')
mean(df$max_neu)
sd(df$max_neu)

#hospitalisation:


#Smoking status (ubiopred):

#Prednisolone use:


#Category onset: