
library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
library(reshape2)
library(Metrics)
library(cowplot)
library(magick)
library(RColorBrewer)
library(Ckmeans.1d.dp)
library(rstudioapi)

#Manipulation to get into the folder fishCount_in_DOV
current_dir <- getSourceEditorContext()$path
parent_dir <- dirname(current_dir)
parent_dir <- dirname(parent_dir)
setwd(parent_dir)

#NCluster - On the test labels
{
#Load Dataset
bbPerFrame <- read.csv("./03_Datasets/dataset_17/boundingboxes_class17.csv")

clusterResults <- as.data.frame(bbPerFrame$videoname)
colnames(clusterResults) <- 'videoname'
clusterResults$category <- 'test'

for(j in 1:nrow(bbPerFrame)){
  bbPerFrameVideo <- bbPerFrame[j,]
  bbPerFrameVideo <- bbPerFrameVideo[,3:ncol(bbPerFrameVideo)]
  
  #Trial of time series clustering
  videoCluster <- bbPerFrameVideo
  videoCluster <- videoCluster[,colSums(is.na(videoCluster))<nrow(videoCluster)]
  
  n <- ncol(videoCluster)-1
  t <- seq(0, ncol(videoCluster)-1, length=n)
  
  w <-  as.numeric(videoCluster[1,2:ncol(videoCluster)])
  
  res <- Ckmeans.1d.dp(t, k=c(1:9), w)
  k <- max(res$cluster)
  colors <- brewer.pal(k, "Set1")
  
  # Extract cluster assignments
  cluster_assignments <- res$cluster
  
  # Initialize a vector to store maximum values for each cluster
  max_values <- numeric(k)
  
  # Loop through each cluster
  for (i in 1:k) {
    # Get indices of data points in the current cluster
    cluster_indices <- which(cluster_assignments == i)
    
    # Get maximum value within the current cluster
    max_values[i] <- max(w[cluster_indices])
  }
  
  NCluster <- sum(max_values)
  clusterResults$NCluster[j] <- NCluster
  
  

}

clusterResults <- select(clusterResults, -category)

setwd(parent_dir)
setwd("./04_Results/")
write.csv(clusterResults, 'class_17_nCluster_onTestLabels.csv', row.names=FALSE)
}

#Nmax - On the test labels
{
  setwd(parent_dir)
  
  bbPerFrame <- read.csv("./03_Datasets/dataset_17/boundingboxes_class17.csv")
  
  nmaxResults <- data.frame(matrix(nrow = nrow(bbPerFrame), ncol = 2))
  colnames(nmaxResults) <- c('videoname', 'Nmax')
  
  nmaxResults$videoname <- bbPerFrame$videoname
  
  for(j in 1:nrow(bbPerFrame)){
    bbPerFrameVideo <- bbPerFrame[j,]
    bbPerFrameVideo <- bbPerFrameVideo[,3:ncol(bbPerFrameVideo)]
    
    bbPerFrameVideo[is.na(bbPerFrameVideo)] <- 0
    nmaxResults$Nmax[j] <- max(bbPerFrameVideo)
  }
  
  setwd(parent_dir)
  setwd("./04_Results/")
  write.csv(nmaxResults, 'class_17_nMax_onTestLabels.csv', row.names=FALSE)  
}

#NCluster - On the fully automated labels
{
  setwd(parent_dir)
  
  #Load Dataset
  bbPerFrame <- read.csv("./03_Datasets/dataset_17/boundingboxes_class17_fullyAuto.csv")
  
  clusterResults <- as.data.frame(bbPerFrame$videoname)
  colnames(clusterResults) <- 'videoname'
  clusterResults$category <- 'test'
  
  for(j in 1:nrow(bbPerFrame)){
    bbPerFrameVideo <- bbPerFrame[j,]
    bbPerFrameVideo <- bbPerFrameVideo[,3:ncol(bbPerFrameVideo)]
    
    #Trial of time series clustering
    videoCluster <- bbPerFrameVideo
    videoCluster <- videoCluster[,colSums(is.na(videoCluster))<nrow(videoCluster)]
    
    n <- ncol(videoCluster)-1
    t <- seq(0, ncol(videoCluster)-1, length=n)
    
    w <-  as.numeric(videoCluster[1,2:ncol(videoCluster)])
    
    res <- Ckmeans.1d.dp(t, k=c(1:9), w)
    k <- max(res$cluster)
    colors <- brewer.pal(k, "Set1")
    
    # Extract cluster assignments
    cluster_assignments <- res$cluster
    
    # Initialize a vector to store maximum values for each cluster
    max_values <- numeric(k)
    
    # Loop through each cluster
    for (i in 1:k) {
      # Get indices of data points in the current cluster
      cluster_indices <- which(cluster_assignments == i)
      
      # Get maximum value within the current cluster
      max_values[i] <- max(w[cluster_indices])
    }
    
    NCluster <- sum(max_values)
    clusterResults$NCluster[j] <- NCluster
    
    
    
  }
  
  clusterResults <- select(clusterResults, -category)
  
  setwd(parent_dir)
  setwd("./04_Results/")
  write.csv(clusterResults, 'class_17_nCluster_onDetections.csv', row.names=FALSE)
}

#Nmax - On the fully automated labels
{
  setwd(parent_dir)
  
  bbPerFrame <- read.csv("./03_Datasets/dataset_17/boundingboxes_class17.csv")
  
  nmaxResults <- data.frame(matrix(nrow = nrow(bbPerFrame), ncol = 2))
  colnames(nmaxResults) <- c('videoname', 'Nmax')
  
  nmaxResults$videoname <- bbPerFrame$videoname
  
  for(j in 1:nrow(bbPerFrame)){
    bbPerFrameVideo <- bbPerFrame[j,]
    bbPerFrameVideo <- bbPerFrameVideo[,3:ncol(bbPerFrameVideo)]
    
    bbPerFrameVideo[is.na(bbPerFrameVideo)] <- 0
    nmaxResults$Nmax[j] <- max(bbPerFrameVideo)
  }
  
  setwd(parent_dir)
  setwd("./04_Results/")
  write.csv(nmaxResults, 'class_17_nMax_onDetections.csv', row.names=FALSE)  
}