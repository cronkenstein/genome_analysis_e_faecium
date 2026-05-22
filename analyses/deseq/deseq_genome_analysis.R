# Here is an deseq2 script for plotting our counts for CDS feature hits
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.22")
BiocManager::install("DESeq2")

library("DESeq2")

# Install the gplots library if needed then load it
if(!require("gplots")){
  install.packages("gplots")
}
library("gplots")
library(pheatmap)

directory <- "./genome_analysis_e_faecium/results/counts/bh/paired"
all_dir <- "./genome_analysis_e_faecium/results/counts/both/paired"
serumSampleFileDir <- "./genome_analysis_e_faecium/results/counts/serum/paired"
sampleNames <- grep("trim",list.files(directory),value=TRUE)
serumSampleFiles <- grep("trim",list.files(serumSampleFileDir),value=TRUE)
bhSampleTable <- data.frame(sampleName = sampleNames,
                          fileName = sampleNames,
                          condition = "bh")
serumSampleTable <- data.frame(sampleName = serumSampleFiles, 
                               fileName = serumSampleFiles,
                               condition = "serum")
sampleTable <- rbind(bhSampleTable, serumSampleTable)
sampleTable$condition <- factor(sampleTable$condition)
ddsHTSeq <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,
                                       directory = all_dir,
                                       design= ~ condition)
ddsHTSeq
ddsHTSeq$condition
ddsHTSeq$condition <- relevel(ddsHTSeq$condition, ref = "bh")
ddsHTSeq$condition
dds <- DESeq(ddsHTSeq)
result <- results(dds)

# normalize
dds.norm <-  estimateSizeFactors(ddsHTSeq)
sizeFactors(dds.norm)

alpha <- 0.001 # Threshold on the p-value

# par(mfrow=c(1,2))

# Compute significance, with a maximum of 320 for the p-values set to 0 due to limitation of computation precision
result$sig <- -log10(result$padj)
sum(is.infinite(result$sig))

result[is.infinite(result$sig),"sig"] <- 350
# View(result[is.na(result$pvalue),])

# Select genes with a defined p-value (DESeq2 assigns NA to some genes)
genes.to.plot <- !is.na(result$pvalue)
# sum(genes.to.plot)
range(result[genes.to.plot, "log2FoldChange"])

# View(result[genes.to.plot,])

## Volcano plot of adjusted p-values
cols <- densCols(result$log2FoldChange, result$sig)
cols[result$pvalue ==0] <- "purple"
cols[result$]
result$pch <- 19
result$pch[result$pvalue ==0] <- 6
plot(result$log2FoldChange, 
     result$sig, 
     col=cols, panel.first=grid(),
     main="Volcano plot", 
     xlab="Effect size: log2(fold-change)",
     ylab="-log10(adjusted p-value)",
     pch=result$pch, cex=0.4)
abline(v=0)
abline(v=c(-1,1), col="red")
abline(h=-log10(alpha), col="red")

## Plot the names of a reasonable number of genes, by selecting those begin not only significant but also having a strong effect size
gn.selected <- abs(result$log2FoldChange) > 5 & result$padj < alpha
text(result$log2FoldChange[gn.selected],
     -log10(result$padj)[gn.selected],
     lab=rownames(result)[gn.selected ], cex=0.6)



# Sort by adjusted p-value and take the top 1000
top_genes <- head(order(result$padj), 1000)
mat_top <- counts(dds.norm)[top_genes, ]

# Optional: Center/Scale rows (z-score) for better visualization
mat_scaled <- na.omit(t(apply(mat_top, 1, scale)))
colnames(mat_scaled) <- colnames(mat_top)

# Create annotation for samples
annotation_col <- data.frame(Condition = colData(dds.norm)$condition)
rownames(annotation_col) <- colnames(dds.norm)

# Generate Heatmap
pheatmap(mat_scaled,
         show_rownames = FALSE,
         show_colnames = TRUE,
         annotation_col = annotation_col,
         main = "Differentially Expressed Genes",
         color = colorRampPalette(c("blue", "white", "red"))(1000))


# 1. Normalize and extract counts
norm_counts <- counts(dds, normalized=TRUE)

# 2. Plot histogram of log2 transformed counts to make it readable
hist(log2(norm_counts + 1), breaks=100, 
     col="grey", main="Distribution of Normalized Counts", 
     xlab="Log2(Normalized Counts + 1)")
