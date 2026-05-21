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

### Hard coded path values below, do not commit this file until these are removed
directory <- "./genome_analysis_e_faecium/counts/bh/paired"
all_dir <- "./genome_analysis_e_faecium/counts/both/paired"
serumSampleFileDir <- "./genome_analysis_e_faecium/counts/serum/paired"
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




### Most differentially expressed genes

### This portion seems to be not all that valuable. There are tons of differentially expressed genes with high significance

result <- subset(x = na.omit(result[order(-result$sig, -result$log2FoldChange),]), padj <= alpha)

selectedGenes <- c(
  "Most significant" =  rownames(result)[which.max(result$sig)])

top.logFC = rownames(result)[which.max(result$log2FoldChange)]
gn.most.sign <- rownames(result)[1]
gn.most.diff.val <- counts(dds.norm, normalized=T)[gn.most.sign,]

## Select a gene with small fold change but high significance
sel1 <- subset(
  na.omit(result), 
  sig >= 50 & log2FoldChange > 0 & log2FoldChange < 1.0)
# dim(sel1)
selectedGenes <- append(selectedGenes, 
                        c("Small FC yet significant"=rownames(sel1)[1]))

## Select the non-significant gene with the highest fold change
sel2 <- subset(x = na.omit(result), padj > alpha & log2FoldChange > 0 & baseMean > 1000 & baseMean < 10000)
# dim(sel2)
sel2 <- sel2[order(sel2$log2FoldChange, decreasing = TRUE),][1,]
selectedGenes <- append(
  selectedGenes, 
  c("Non-significant"=rownames(sel2)[1]))

par(mfrow=c(length(selectedGenes),1))

for (g in selectedGenes) {
  barplot(counts(dds.norm, normalized=TRUE)[g,], 
          col=c("blue", "blue", "blue", "red", "red", "red"), 
          main=g, las=2, cex.names=0.5)
}

