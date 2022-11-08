#!/bin/env/bash


#broad asthma phenotype with death for asthma as primary cause and hospitalisation for asthma as primary cause

#work on venv environment
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

#work inside the project

#BTS stage 4 and 5 phenotype participants:
#/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_bts2019_4plus

#asthma primary cause of hospitalisation:
awk '$4 == 1 {print $1}' ../../../UKBiobank_datafields/output/QC_hesin_diag_asthma.txt | sort -u \
    > ../../data/eid_asthma_level1_hes

#asthma primary cause of death:
awk '{print $1}' ../../../UKBiobank_datafields/output/QC_asthma_PrimaryCauseOfDeath_40001.txt \
    > ../../data/eid_asthma_primarycause_death

#combine eid together:
cat /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_bts2019_4plus  \
    ../../data/eid_asthma_level1_hes \
    ../../data/eid_asthma_primarycause_death |
    sort -u \
    > ../../data/eid_broad_asthma_pheno

rm ../../data/eid_asthma_level1_hes ../../data/eid_asthma_primarycause_death
cp ../../data/eid_broad_asthma_pheno /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/

module unload R/4.2.1
module load R/4.1.0
dos2unix broad_pheno_cov_EUR_file.R
chmod o+x broad_pheno_cov_EUR_file.R
Rscript broad_pheno_cov_EUR_file.R

