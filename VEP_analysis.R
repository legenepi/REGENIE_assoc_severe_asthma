#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))
suppressMessages(library(data.table))

#input:
sentinel <- fread("output/maf001_pheno_1_5_ratio_sentinel_variants_OR.txt",header=T)
sentinel$b37chr <- as.factor(sentinel$b37chr)
sentinel$bp <- as.numeric(sentinel$bp)

VEP <- fread("output/VEP_results.txt",header=T) %>% select('#Uploaded_variation','Location','Allele','Consequence',
                                                           'SYMBOL','PHENOTYPES')

VEP <- VEP %>% rename(snpid='#Uploaded_variation',a1=Allele)
VEP <- VEP %>% separate(Location, c("b37chr","bp_VEP"),sep = c(":")) %>% separate(bp_VEP, c("bp_VEP","bp_to_exclude"),sep = c("-"))
VEP$'bp_to_exclude' <- NULL
VEP$b37chr <- as.factor(VEP$b37chr)

VEP_sentinel <- left_join(sentinel, VEP,by=c('snpid','b37chr','a1')) %>% filter(SYMBOL!="-") %>% unique()
VEP_sentinel <- VEP_sentinel %>% separate(Consequence, c("Consequence","Consequence_rest"),sep=",")
VEP_sentinel$Consequence_rest <- NULL
VEP_sentinel <- VEP_sentinel %>% unique()

VEP_sentinel <- VEP_sentinel %>% select(snpid, b37chr, bp, SYMBOL, Consequence, a1, a2, eaf, OR_95_CI, pval, PHENOTYPES)
VEP_sentinel <- VEP_sentinel %>% mutate(Minor_allele = ifelse(VEP_sentinel$eaf < 0.5, VEP_sentinel$a1, VEP_sentinel$a2))
VEP_sentinel$eaf <- paste0(round(VEP_sentinel$eaf*100,2),"%")

VEP_sentinel <- VEP_sentinel %>% relocate(Minor_allele, .after=a2)
VEP_sentinel$pval <- signif(VEP_sentinel$pval,digits=3)
VEP_sentinel <- VEP_sentinel %>% rename(SNP_id=snpid, Chromosome=b37chr,Position=bp,Gene_symbol=SYMBOL,Effect_allele=a1,
                                        Non_effect_allele=a2,Effect_allele_frequency=eaf,P_value=pval)



#retrieve the 3 snpid not found::
VEP_sentinel_rs9271365 <- left_join(sentinel, VEP,by=c('snpid','b37chr')) %>% filter(snpid == "rs9271365" | snpid == "rs113880645" | snpid == "rs201499805")
VEP_sentinel_rs9271365$'a1.y' <- NULL
VEP_sentinel_rs9271365 <- VEP_sentinel_rs9271365 %>% separate(Consequence, c("Consequence","Consequence_rest"),sep=",")
VEP_sentinel_rs9271365$Consequence_rest <- NULL
VEP_sentinel_rs9271365 <- VEP_sentinel_rs9271365 %>% unique()
VEP_sentinel_rs9271365 <- VEP_sentinel_rs9271365 %>% select(snpid, b37chr, bp, SYMBOL, Consequence, a1.x, a2, eaf, OR_95_CI, pval,PHENOTYPES)
VEP_sentinel_rs9271365 <- VEP_sentinel_rs9271365 %>% mutate(Minor_allele = ifelse(VEP_sentinel_rs9271365$eaf < 0.5, VEP_sentinel_rs9271365$a1, VEP_sentinel_rs9271365$a2))
VEP_sentinel_rs9271365$eaf <- paste0(round(VEP_sentinel_rs9271365$eaf*100,2),"%")

VEP_sentinel_rs9271365 <- VEP_sentinel_rs9271365 %>% relocate(Minor_allele, .after=a2)
VEP_sentinel_rs9271365$pval <- signif(VEP_sentinel_rs9271365$pval,digits=3)
VEP_sentinel_rs9271365 <- VEP_sentinel_rs9271365 %>% rename(SNP_id=snpid, Chromosome=b37chr,Position=bp,Gene_symbol=SYMBOL,Effect_allele=a1.x,
                                        Non_effect_allele=a2,Effect_allele_frequency=eaf,P_value=pval)

VEP_sentinel_tot <- rbind(VEP_sentinel,VEP_sentinel_rs9271365)
VEP_sentinel_tot <- VEP_sentinel_tot %>% arrange(Chromosome,Position)
write.table(VEP_sentinel_tot,"output/VEP_annotation_plus_assoc_sentinel_vars.txt",sep="\t",row.names=F,quote=F)


VEP_sentinel_tot$PHENOTYPES <- NULL
write.table(VEP_sentinel_tot,"output/VEP_annotation_sentinel_vars.txt",sep="\t",row.names=F,quote=F)

