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

pheno_asthma="1_5_ratio_asthma"

#run Manhattan, qqplot, lambda:
module unload R/4.2.1
module load R/4.1.0
chmod o+x src/REGENIE_plots.R
dos2unix src/REGENIE_plots.R
Rscript src/REGENIE_plots.R ${GWAS}/pheno_1_5_ratio_allchr.assoc.txt.gz ${pheno_asthma}

#Run LDSC-score:
#qsub src/LDSC.sh



