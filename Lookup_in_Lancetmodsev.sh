#!/bin/env/bash


PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="maf001_pheno_1_5_ratio"
PATH_MODSEV="/data/gen1/AIRPROM/assoc/severe_asthma_GC.snptest.gz"



zgrep -w "rs12470864\|rs6761047\|rs10455025\|rs2188962\|rs2428494\|rs6462\|rs9271365\|rs113880645\|rs1888909\|rs201499805" \
    /data/gen1/AIRPROM/assoc/severe_asthma_GC.snptest.gz > ${PATH_OUT}/sentinel_in_Lancetmodsev

zgrep "5     131770805" /data/gen1/AIRPROM/assoc/severe_asthma_GC.snptest.gz >> ${PATH_OUT}/sentinel_in_Lancetmodsev

zgrep "10     9042744" /data/gen1/AIRPROM/assoc/severe_asthma_GC.snptest.gz >> ${PATH_OUT}/sentinel_in_Lancetmodsev