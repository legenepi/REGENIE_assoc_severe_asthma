#!/bin/bash

#PBS -N plinkQC_sexchr
#PBS -j oe
#PBS -o log_plinkQC_sexchr
#PBS -l walltime=4:0:0
#PBS -l nodes=1:ppn=2
#PBS -l vmem=50gb
#PBS -W umask=022

#execute as: qsub src/broad_phenotype/plink_QC_eur_addsexchr.sh

PATH_DATA="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
geno_dir="/data/ukb/genotyped"
scratch_dir="/scratch/gen1/nnp5/REGENIE_assoc/tmp_data"


#to create list of eur ids
#awk {'print $1, $2'} ${PATH_DATA}/demo_EUR_pheno_cov.txt | tail -n +2 > ${PATH_DATA}/ukb_eur_ids

#cp from /rfs to my home the .fam
#cp /rfs/TobinGroup/data/UKBiobank/application_56607/ukb56607_cal_chr1_v2_s488239.fam ${PATH_DATA}/

#rm ${PATH_DATA}/list_plink_files_sexchr
#for chr in {2..22} X Y XY
#do echo "${geno_dir}/ukb_cal_chr${chr}_v2.bed ${geno_dir}/ukb_cal_chr${chr}_v2.bim ${PATH_DATA}/ukb56607_cal_chr1_v2_s488239.fam" >> ${PATH_DATA}/list_plink_files_sexchr
#done

#module load plink
#plink --bed ${geno_dir}/ukb_cal_chr1_v2.bed \
#	--bim ${geno_dir}/ukb_cal_chr1_v2.bim \
#	--fam ${PATH_DATA}/ukb56607_cal_chr1_v2_s488239.fam \
#	--merge-list ${PATH_DATA}/list_plink_files_sexchr \
#	--make-bed --out ${scratch_dir}/ukb_cal_allchr_v2_sexchr &&

#awk '{print $1, $1}' /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/Eid_withdrawn_participants_upFeb2022.txt \
#    > ${PATH_DATA}/ukb_withdrawns_ids &&

module load plink2
plink2 --bfile ${scratch_dir}/ukb_cal_allchr_v2_sexchr \
	--maf 0.01 --mac 100 --geno 0.1 --hwe 1e-15 \
	--keep ${PATH_DATA}/ukb_eur_ids \
	--remove ${PATH_DATA}/ukb_withdrawns_ids \
	--mind 0.1 \
	--write-snplist --write-samples --no-id-header \
	--out ${scratch_dir}/ukb_cal_allchr_eur_qc_sexchr &&

cp ${scratch_dir}/ukb_cal_allchr_eur_qc_sexchr.id ${PATH_DATA}
 
 
