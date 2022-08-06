#!/bin/bash

#PBS -N ex_LDSC
#PBS -j oe
#PBS -o ex_LDSC
#PBS -l walltime=1:0:0
#PBS -l vmem=70gb
#PBS -l nodes=1:ppn=1
#PBS -d .
#PBS -W umask=022


file_PATH="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/"
PHENO="pheno_1_5_ratio" #early_onset #adult_onset
cases_n='3761'
controls_n='22840'
tot_n='26601'


module unload R/4.2.1
module load R/4.1.0
chmod o+x src/create_input_munge_summary_stats.R
dos2unix src/create_input_munge_summary_stats.R
Rscript src/create_input_munge_summary_stats.R \
    ${GWAS}/${PHENO}_allchr.assoc.txt.gz \
    ${PHENO} \
    ${cases_n} \
    ${controls_n}

###updated with inof03. maf. mac filtering:
#cd /home/n/nnp5/software ##create conda and downloand ldsc or via venv
#git clone https://github.com/bulik/ldsc.git
#cd ldsc
#home/n/nnp5/anaconda/condabin/conda env create --file environment.yml


conda activate ldsc
./munge_sumstats.py \
--sumstats ${file_PATH}/pheno_1_5_ratio_input_mungestat \
--N ${tot_n}   \
--out ${PHENO}_allchr_step2_regenie \
--merge-alleles /data/gen1/UKBiobank/Smoking/Meta_Analysis_AWI_UGR_UKBAFR/files/w_hm3.snplist \
--chunksize 500000

./ldsc.py \
--h2 ${PHENO}_allchr_step2_regenie.sumstats.gz \
--ref-ld-chr /data/gen1/reference/ldsc/afr_w_ld_chr/ \
--w-ld-chr /data/gen1/reference/ldsc/afr_w_ld_chr/ \
--out ${PHENO}_allchr_step2_regenie_h2
