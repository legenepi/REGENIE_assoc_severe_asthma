#!/bin/env/bash


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
