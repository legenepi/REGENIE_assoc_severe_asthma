sink(stderr())

args <- commandArgs(T)
argc <- length(args)

if (argc < 1) {
    cat("Usage: sentinels.R HITS [ WIDTH (default", WIDTH, ")]\n")
    q()
}

tier_file = args[1]
pheno = args[2]
WIDTH <- ifelse(argc > 2, as.integer(args[3]), 500000)

print(paste0("total genomic window used for signal selection:",WIDTH))

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


tier.dt <- fread(tier_file,header=T)
tier.dt <- tier.dt %>% filter(pval <= 5e-8)
sentinels.dt <- selectSentinels(tier.dt)
sentinels.dt <- sentinels.dt %>% arrange(b37chr)
write.table(sentinels.dt, paste0("output/",pheno,"_sentinel_variants.txt"), row.names=F, quote=F, sep="\t")


#Compare with Lancet results:
lancet_file <- "/data/gen1/AIRPROM/assoc/severe_asthma/severe_asthma_signals.txt"
lancet <- fread(lancet_file,header=T,fill=T)
lancet <- lancet %>% rename(b37chr="chrom")
lancet <- lancet %>% rename(bp=pos)
print(inner_join(sentinels.dt,lancet,by=c("b37chr","bp")))

