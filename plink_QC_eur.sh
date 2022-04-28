#!/bin/bash

#PBS -N plinkQC
#PBS -j oe
#PBS -o log
#PBS -l walltime=23:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=64gb
#PBS -W umask=022



#to create list of eur ids
#awk '{if($6 == "European") print $1" "$1}' ancestry_covars_PCs.txt > ukb_eur_ids


geno_dir="/data/ukb/genotyped"
eye_dir="/data/neuroretinal/ukb_master/genetics"
out_dir="/scratch/gen1/cb334"



rm ${out_dir}/list_plink_files
for chr in {2..22}
do echo "${geno_dir}/ukb_cal_chr${chr}_v2.bed ${geno_dir}/ukb_cal_chr${chr}_v2.bim ${eye_dir}/fam/ukb22418_c5_b0_v2_s488175.fam" >> ${eye_dir}/list_plink_files
done

module load plink
plink --bed ${geno_dir}/ukb_cal_chr1_v2.bed \
	--bim ${geno_dir}/ukb_cal_chr1_v2.bim \
	--fam ${eye_dir}/fam/ukb22418_c5_b0_v2_s488175.fam \
	--merge-list ${eye_dir}/list_plink_files \
	--make-bed --out ${out_dir}/ukb_cal_allchr_v2 &&

module load plink2
plink2 --bfile ${out_dir}/ukb_cal_allchr_v2 \
	--maf 0.01 --mac 100 --geno 0.1 --hwe 1e-15 \
	--keep ${eye_dir}/ukb_eur_ids \
	--mind 0.1 \
	--write-snplist --write-samples --no-id-header \
	--out ${out_dir}/ukb_cal_allchr_eur_qc
 
 
