#!/bin/env/bash


PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="pheno_1_5_ratio"


head -n 1 ${PATH_OUT}/${PHENO}_betase_input_mungestat >  ${PATH_OUT}/header
awk '$2==6 {print 0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat > ${PATH_OUT}/chr6_input_mungestat
cat ${PATH_OUT}/header ${PATH_OUT}/chr6_input_mungestat > ${PATH_OUT}/header_chr6_input_mungestat