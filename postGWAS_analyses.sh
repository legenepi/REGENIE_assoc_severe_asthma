#!/bin/bash

#PBS -N post_gwas_asthma
#PBS -j oe
#PBS -o post_gwas_asthma
#PBS -l walltime=2:0:0
#PBS -l vmem=30gb
#PBS -l nodes=1:ppn=1
#PBS -d .
#PBS -W umask=022

PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="pheno_1_5_ratio" #pheno_earlyonset_1_5_ratio #pheno_adultonset_1_5_ratio

#mkdir ${PATH_OUT}/allchr
GWAS="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/allchr"

#merge all assoc file:
#zcat ${PATH_OUT}/${PHENO}.1.regenie.step2_pheno_1_5_ratio.regenie.gz > ${GWAS}/${PHENO}_allchr.assoc.txt

#for i in {2..22}
#    do zcat ${PATH_OUT}/${PHENO}.${i}.regenie.step2_pheno_1_5_ratio.regenie.gz | \
#    tail -n +2 \
#    >> ${GWAS}/${PHENO}_allchr.assoc.txt
#done
#gzip ${GWAS}/${PHENO}_allchr.assoc.txt
#rm ${GWAS}/${PHENO_allchr.assoc.txt


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

###updated with info03. maf. mac filtering:
#cd /home/n/nnp5/software ##create conda and downloand ldsc or via venv
#git clone https://github.com/bulik/ldsc.git
#cd ldsc
#home/n/nnp5/anaconda/condabin/conda env create --file environment.yml


conda activate ldsc

/home/n/nnp5/software/ldsc/munge_sumstats.py \
--sumstats ${PATH_OUT}/${PHENO}_input_mungestat \
--N ${tot_n}   \
--out ${PHENO}_allchr_step2_regenie \
--merge-alleles /data/gen1/UKBiobank/Smoking/Meta_Analysis_AWI_UGR_UKBAFR/files/w_hm3.snplist \
--chunksize 500000

/home/n/nnp5/software/ldsc/ldsc.py \
--h2 ${PHENO}_allchr_step2_regenie.sumstats.gz \
--ref-ld-chr /data/gen1/reference/ldsc/afr_w_ld_chr/ \
--w-ld-chr /data/gen1/reference/ldsc/afr_w_ld_chr/ \
--out ${PHENO}_allchr_step2_regenie_h2

conda deactivate

#ldsc_interecept='0'

#run Manhattan, qqplot, lambda:
#module unload R/4.2.1
#module load R/4.1.0
#chmod o+x src/REGENIE_plots.R
#dos2unix src/REGENIE_plots.R
#Rscript src/REGENIE_plots.R ${GWAS}/pheno_1_5_ratio_allchr.assoc.txt.gz ${pheno_asthma} ${ldsc_interecept}
