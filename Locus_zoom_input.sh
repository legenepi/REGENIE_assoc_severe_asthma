#!/bin/env/bash

#for the online software:
PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="maf001_broad_pheno_1_5_ratio"

head -n 1 ${PATH_OUT}/${PHENO}_betase_input_mungestat >  ${PATH_OUT}/header

#chr2:
awk '$2==2 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr2_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr2_input_mungestat > ${PATH_OUT}/header_chr2_input_mungestat

#chr3:
awk '$2==3 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr3_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr3_input_mungestat > ${PATH_OUT}/header_chr3_input_mungestat

#chr5:
awk '$2==5 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr5_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr5_input_mungestat > ${PATH_OUT}/header_chr5_input_mungestat


#chr6:
awk '$2==6 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr6_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr6_input_mungestat > ${PATH_OUT}/header_chr6_input_mungestat


#chr8
awk '$2==8 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr8_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr8_input_mungestat > ${PATH_OUT}/header_chr8_input_mungestat


#chr9:
awk '$2==9 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr9_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr9_input_mungestat > ${PATH_OUT}/header_chr9_input_mungestat


#chr10:
awk '$2==10 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr10_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr10_input_mungestat > ${PATH_OUT}/header_chr10_input_mungestat


#input: change i and rsid for each sentinel:
i=2
rsid="rs12470864"

#for the built-in software:
#create the LD file:
##A1. create plink file for case/control cohort (as a job array) in plink2
module load plink2
plink2 \
  --bgen /data/ukb/nobackup/imputed_v3/ukb_imp_chr${i}_v3.bgen ref-first \
  --keep /home/n/nnp5/PhD/PhD_project/Post_GWAS/input/broadasthma_individuals \
  --make-bed \
  --out /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/broad_pheno_plink_file_v3_chr${i} \
  --sample /data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_app56607_for_regenie.sample

##B.Calculate ld in plink v1.9b:
module unload plink2
module load plink
plink \
    --bfile /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/broad_pheno_plink_file_v3_chr${i} \
    --r2 \
    --ld-snp ${rsid} \
    --ld-window-kb 1000 \
    --ld-window 99999 \
    --ld-window-r2 0 \
    --out /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ld_chr${i}_${rsid}

##the User-supplied LD should have columns:
#snp1	Any SNP in your plotting region.
#snp2	Should always be the reference SNP in the region.
#dprime	D' between snp2 (reference SNP) and snp1.
#rsquare	r2 between snp2 (reference SNP) and snp1.
#The dprime column can be all missing if it is not known. Rsquare must be present, and must be valid data.
#The file should be whitespace delimited, and the header (column names shown above) must exist.
echo "snp1 snp2 dprime rsquare" > /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/header_ld
awk '{print $6, $3, "NA", $7}' /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ld_chr${i}.ld | \
    tail -n +2 | \
    cat /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/header_ld - \
    > /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ld_chr${i}_locuszoom


#using my pre-calculated LD file:
module unload R/4.2.1
module load R/4.1.0
module load plink
cd ${PATH_OUT}/Locuszoom_builtin/
/scratch/gen1/nnp5/locuszoom/locuszoom/bin/locuszoom \
    --metal ${PATH_OUT}/header_chr${i}_input_mungestat \
    --refsnp ${rsid} --flank 1Mb \
    --plotonly \
    signifLine=7.3 \
    --prefix EUR \
    --ld /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ld_chr${i}_locuszoom \
    --delim tab --pvalcol pval --markercol snpid \
    --build hg19 \
    --plotonly --verbose

##############Other ways, but I did not use them:
#using pre-computed LD from 10k Europeans UKB:
##Calculate ld in plink v1.9b for 10k Eur-UKB:
##rs778801698 is not present in these 10k eur-ukb !!
module unload plink2
module load plink
plink \
    --bfile /data/gen1/LF_HRC_transethnic/LD_reference/EUR_UKB/ukb_imp_chr${i}_EUR_selected_nodups\
    --r2 \
    --ld-snp ${rsid} \
    --ld-window-kb 1000 \
    --ld-window 99999 \
    --ld-window-r2 0 \
    --out /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ukb10k_EUR_ld_chr${i}

echo "snp1 snp2 dprime rsquare" > /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/header_ld
awk '{print $6, $3, "NA", $7}' /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ukb10k_EUR_ld_chr${i}.ld | \
    tail -n +2 | \
    cat /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/header_ld - \
    > /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ukb10k_EUR_ld_chr${i}_locuszoom

module unload R/4.2.1
module load R/4.1.0
module load plink
cd ${PATH_OUT}/Locuszoom_builtin/
/scratch/gen1/nnp5/locuszoom/locuszoom/bin/locuszoom \
    --metal ${PATH_OUT}/header_chr${i}_input_mungestat \
    --refsnp ${rsid} --flank 1Mb \
    --plotonly \
    signifLine=7.3 \
    --prefix EUR \
    --ld /scratch/gen1/nnp5/REGENIE_assoc/tmp_data/ukb10k_EUR_ld_chr${i}_locuszoom \
    --delim tab --pvalcol pval --markercol snpid \
    --build hg19 \
    --plotonly --verbose


#using data from locuszoom:
module unload R/4.2.1
module load R/4.1.0
module load plink
cd ${PATH_OUT}/Locuszoom_builtin/
/scratch/gen1/nnp5/locuszoom/locuszoom/bin/locuszoom \
    --metal ${PATH_OUT}/header_chr${i}_input_mungestat \
    --refsnp ${rsid} --flank 1Mb \
    --plotonly \
    signifLine=7.3 \
    --prefix EUR \
    --build hg19 --pop EUR --source 1000G_Nov2014 --delim tab --pvalcol pval --markercol snpid \
    --plotonly --verbose