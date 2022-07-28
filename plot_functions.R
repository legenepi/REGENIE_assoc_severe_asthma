#Plot inflation plot with qqman package and qq() function.
plot.qqplot <- function(pval_vec,title){
	       filename = paste0("output/Q-Q_plot_of_GWAS",title,".png")
	       plot_title = paste0("Q-Q plot of GWAS ",title)
	       png(filename, width = 480, height = 480, units = "px", pointsize = 12, bg = "white")
               print(qq(pval_vec, main = plot_title, xlim = c(0,8), ylim = c(0,8), cex.axis = 0.9, cex = 0.9, las = 1)) #function from qqman library
               dev.off()

}

# Create a Manhattan plot from a data frame containing the results of
# a GEMMA association analysis.
plot.Manha <- function (dataset,test_type,title) {
	      colnames(dataset) <- c("SNP","CHR","BP","P") #the Manhattan function needs this format
              filename <- paste0("output/Manhattan_plot_of_GWAS",title,".png")
              plot_title = paste0("Manhattan plot of GWAS ",title)
	      png(filename, width = 1200, height = 480, units = "px", pointsize = 12, bg = "white")
	      manhattan(dataset, main = title, col = c("lightblue","blue3"), chrlabs = as.character(c(1:22)), ylim = c(0,9),
	      cex = 0.9, cex.axis = 0.8, suggestiveline = F, genomewideline = F) #function from qqman library     
	      abline(h=-log10(0.00000005),lty="dashed",col="black")
	      abline(h=-log10(0.000005),lty="solid",col="black")
	      dev.off()
}





# Estimate lambda using the genabel package and the estlambda function:
lambda_func <- function(p_val,title){
		filename <- paste0("output/lambda_",title,"_.txt")
		z_frompval <- qnorm(pval/2)
        lambda_values <- round(median(z_frompval^2,na.rm=T)/qchisq(0.5,df=1),4)
		write.table(lambda_values,filename)
}














# Create a simple Manhattan plot from a data frame containing the
# results of a GEMMA association analysis, in which p-values are
# plotted against base-pair positions (in Mb).
plot.region.pvalues <- function (gwscan, size = 1) {

  # Convert the p-values to the -log10 scale.
  gwscan <- transform(gwscan,p_lrt = -log10(p_lrt))

  # Convert the positions to the Megabase (Mb) scale.
  gwscan <- transform(gwscan,ps = ps/1e6)
  
  # Create a Manhattan plot.
  return(ggplot(gwscan,aes(x = ps,y = p_lrt)) +
         geom_point(color = "darkblue",size = size,shape = 20) +
         labs(x = "base-pair position (Mb)",y = "-log10 p-value") +
         theme_cowplot(font_size = 10) +
         theme(axis.line = element_blank()))
}
