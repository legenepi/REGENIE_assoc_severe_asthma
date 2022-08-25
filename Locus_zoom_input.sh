#!/bin/env/bash

#for the online software:
PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="maf001_pheno_1_5_ratio"

head -n 1 ${PATH_OUT}/${PHENO}_betase_input_mungestat >  ${PATH_OUT}/header

#chr2:
awk '$2==2 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr2_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr2_input_mungestat > ${PATH_OUT}/header_chr2_input_mungestat


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
module unload R/4.2.1
module load R/4.1.0
module load plink
cd ${PATH_OUT}/Locuszoom_builtin/
/scratch/gen1/nnp5/locuszoom/locuszoom/bin/locuszoom \
    --metal ${PATH_OUT}/header_chr${i}_input_mungestat \
    --refsnp "rs12470864" --flank 1Mb \
    --plotonly \
    signifLine=7.3 \
    --prefix EUR \
    --ld \
    --build hg19 --pop EUR --source 1000G_Nov2014 --delim tab --pvalcol pval --markercol snpid \
    --plotonly --verbose


#TO BE FINISHED:
geno_dir="/data/ukb/genotyped"
sample_DIR="/data/gen1/UKBiobank_500K/severe_asthma/data"
PATH_DATA="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data"
module load plink
plink --bfile ${geno_dir}/ukb_cal_chr8_v2 \
    	--fam ${PATH_DATA}/ukb56607_cal_chr1_v2_s488239.fam \
    	--r2



#for chromosome 8 and 10:
#for the built-in software:
module unload R/4.2.1
module load R/4.1.0
module load plink
cd ${PATH_OUT}/Locuszoom_builtin/
/scratch/gen1/nnp5/locuszoom/locuszoom/bin/locuszoom \
    --metal ${PATH_OUT}/header_chr${i}_input_mungestat \
    --refsnp "rs12470864" --flank 1Mb \
    --plotonly \
    signifLine=7.3 \
    --prefix EUR \
    --ld ${PATH_OUT}\
    --build hg19 --pop EUR --source 1000G_Nov2014 --delim tab --pvalcol pval --markercol snpid \
    --plotonly --verbose