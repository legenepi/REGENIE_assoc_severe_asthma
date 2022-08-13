sink(stderr())

args <- commandArgs(T)
argc <- length(args)

if (argc < 1) {
    cat("Usage: sentinels.R HITS [ WIDTH (default", WIDTH, ")]\n")
    q()
}

tier_file = args[1]
pheno = args[2]
tier_number = args[3]
WIDTH <- ifelse(argc > 3, as.integer(args[4]), 500000)

print(WIDTH)

suppressMessages(library(data.table))
suppressMessages(library(tidyverse))


selectSentinels <- function(data.dt) {
    regions.list <- list()
    while(nrow(data.dt) > 0) {
        top.dt <- data.dt[ which.min(pval) ]
        regions.list[[top.dt$snpid]] <- top.dt
        data.dt <- data.dt[ b37chr != top.dt$b37chr
            | bp <= top.dt$bp - WIDTH
            | bp >= top.dt$bp + WIDTH ]
    }
    rbindlist(regions.list)
}

tier_file <- "/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/pheno_1_5_ratio_betase_input_mungestat"
tier.dt <- fread(tier_file,header=T)
tier.dt <- tier.dt %>% filter(pval <= 5e-8)
sentinels.dt <- selectSentinels(tier.dt)
write.table(sentinels.dt, "output/pheno_1_5_ratio_sentinel_variants.txt" , row.names=F, quote=F, sep="\t")


#Compare with Lancet results:
lancet_file <- "/data/gen1/AIRPROM/assoc/severe_asthma/severe_asthma_signals.txt"
lancet <- fread(lancet_file,header=T,fill=T)
lancet <- lancet %>% rename(b37chr="chrom")
lancet <- lancet %>% rename(bp=pos)
inner_join(sentinels,lancet,by=c("b37chr",2bp"))

