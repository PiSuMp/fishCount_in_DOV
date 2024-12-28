
library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
library(reshape2)
library(Metrics)
library(cowplot)
library(magick)

#Manipulation to get into the folder fishCount_in_DOV
current_dir <- getwd()
parent_dir <- dirname(current_dir)
setwd(parent_dir)

#For the image
logo_file <- magick::image_read("./06_Imgs/image_SU_noeyes.png")

#EPINEPHELUS MARGINATUS
#CALIBRATION
{
setwd("./03_Datasets/dataset_17/")
bbs_Overall <- read.csv("combined_data_17.csv", sep=",")
bbs <- read.csv("boundingboxes_class17.csv", sep=",")
bbs <- subset(bbs, category == 'train')

test <- bbs[5:nrow(bbs),]

bbs_actual <- select(test, category, videoname, Nact)

bbs_Overall_joined <- left_join(bbs_Overall, bbs_actual)

bbs_Overall_joined$category <- as.factor(bbs_Overall_joined$category)

#Get density value
densityData <- bbs_Overall_joined %>%
  group_by(category, Nmax_improved, Nact) %>%
  summarise(frequency = n()) %>%
  ungroup()

densityData <- drop_na(densityData)

bbs_Overall_joined <- subset(bbs_Overall_joined, category == 'train')

bbs_Overall_joined$threshold <- as.factor(bbs_Overall_joined$threshold)
bbs_Overall_joined$n_frames <- as.factor(bbs_Overall_joined$n_frames)
bbs_Overall_joined$method <- paste0(bbs_Overall_joined$n_frames, '_', bbs_Overall_joined$threshold)

# Get frequency of Nmax_improved and Nact pairs for each combination of n_frames and threshold
densityData <- bbs_Overall_joined %>%
  group_by(method, n_frames, threshold, Nmax_improved, Nact) %>%
  summarise(frequency = n(), .groups = 'drop')

# New facet label names for th variable
threshold.labs <- c("threshold 0", "threshold 1", "threshold 2", 'threshold 3', "threshold 4", "threshold 5")
names(threshold.labs) <- c("0", "1", "2", '3', "4", "5")

# New facet label names for n_frames variable
nframes.labs <- c("n_frames 0", "n_frames 1", "n_frames 2", 'n_frames 3', "n_frames 4", "n_frames 5", "n_frames 6", "n_frames 7", "n_frames 8", "n_frames 9", "n_frames 10","n_frames 11","n_frames 12","n_frames 13","n_frames 14","n_frames 15","n_frames 16","n_frames 17","n_frames 18")
names(nframes.labs) <- c("0", "1", "2", '3', "4", "5", "6", "7", "8", "9","10","11","12","13","14","15","16","17","18")

densityData$frequency[densityData$Nmax_improved==0 & densityData$Nact==0] <- 1

# Define the line parameters
intercept <- 0
slope <- 1

errorData <- densityData %>%
  mutate(
    y_line = intercept + slope * Nmax_improved,
    error = Nact - y_line
  )

densityData_forGraph <- subset(densityData, as.numeric(n_frames) > 14)
densityData_forGraph <- subset(densityData_forGraph, as.numeric(n_frames) < 20)

gplot <- ggplot(data= densityData_forGraph, aes(y=Nact,x=Nmax_improved, size = as.factor(densityData_forGraph$frequency))) +
  #geom_smooth(method=lm) +
  geom_abline(intercept = 0, color = "red",linetype=3) +
  #geom_segment(data= errorData, aes(x = Nmax_improved, y = Nact, xend = Nmax_improved, yend = y_line), size = 0.5, color = 'red') +
  geom_point() +
  geom_smooth(method=lm, level = 0.95, color="NA", size = 0, se=TRUE) + #add linear trend line with a 95% confidence interval
  theme_bw() +
  theme(text=element_text(size=20), axis.text.x = element_text(angle = 25), axis.text.y = element_text(angle = 25)) +
  facet_grid(threshold ~ n_frames, labeller = labeller(threshold = threshold.labs, n_frames = nframes.labs)) +
  scale_y_continuous(name = 'True FishAbundance', breaks = seq(0, 10, 2), limits=c(-0.1,10.1)) +
  scale_x_continuous(name = 'Estimated FishAbundance', breaks = seq(0, 10, 2), limits=c(-0.1,10.1)) +
  labs(size = "Number of videos")

my_plot_2 <- ggdraw() +
  draw_plot(gplot) +
  draw_image(logo_file,  x = 0.41, y = 0.42, scale = .17)

my_plot_2

# Calculate the correlation for each method
correlations <- bbs_Overall_joined %>%
  group_by(method) %>%
  summarize(metric = cor(Nmax_improved, Nact, use = "complete.obs"))

correlations$metric <- round(correlations$metric, 3)

# Calculate the absolute errors for each method
absolute_errors <- bbs_Overall_joined %>%
  group_by(method) %>%
  summarize(metric = sum(ae(Nmax_improved, Nact)))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~END OF CALIBRATION

}


#On Test Labels
#Before running this part, copy the best performing NHeuristic into the ./04_Results/ folder and name the file 'class_13_nheuristic_onTestLabels.csv'
{
setwd(parent_dir)
setwd("./04_Results/")

bbs_actual <- read.csv("class_17_nact.csv", sep=",")
bbs_nmax <- read.csv("class_17_nMax_onTestLabels.csv", sep=",")
bbs_nCluster <- read_csv("class_17_nCluster_onTestLabels.csv")
bbs_NTCN <- read_csv("class_17_Ntcn_onTestLabels.csv")
bbs_nimproved <- read.csv("class_17_nheuristic_onTestLabels.csv", sep=",")

bbs_nCluster <- bbs_nCluster %>% distinct(videoname, .keep_all = TRUE)

#Data manipulation
bbs_NTCN <- select(bbs_NTCN, -trueValue)

bbs <- left_join(bbs_actual, bbs_nCluster)
bbs <- left_join(bbs, bbs_nmax)
bbs <- left_join(bbs, bbs_NTCN)

bbs_nimproved <- select(bbs_nimproved, 'videoname', 'Nimproved')

bbs_ALL <- bbs

bbs_ALL <- select(bbs_ALL, c('videoname', 'category', 'Nact','Nmax','NCluster', 'Ntcn'))

bbs_ALL <- left_join(bbs_ALL, bbs_nimproved)

bbs_ALL <- drop_na(bbs_ALL)
bbs_ALL <- subset(bbs_ALL, category == 'test')

bbs_actual <- bbs_ALL$Nact

bbsMelted <- melt(bbs_ALL)
bbsMelted$Nact <- bbs_actual
bbsMelted <- drop_na(bbsMelted)

bbsMelted <- subset(bbsMelted, variable != 'Nact')
bbsMelted <- subset(bbsMelted, category != 'train')

#With the CLUSTER
# New facet label names for dose variable
methods.labs <- c("Nimproved", "Nmax", "NCluster", 'Ntcn')
names(methods.labs) <- c("Nth0n3", "Nmax", "NCluster", 'Ntcn')

#Get density value
densityData <- bbsMelted %>%
  group_by(variable, value, Nact) %>%
  summarise(frequency = n()) %>%
  ungroup()

summary(densityData)

densityData$frequency[densityData$value==0 & densityData$Nact==0] <- 1

#Reorder to make it look nice
densityData$variable <- as.character(densityData$variable)
densityData$variable[densityData$variable=='Nimproved'] <- 'NHeuristic'
densityData$variable[densityData$variable=='Ntcn'] <- 'NTCN'

densityData$variable_f = factor(densityData$variable, levels=c('Nmax', 'NCluster', 'NHeuristic', 'NTCN'))

densityData$highlight <- ifelse(densityData$Nact == 19, "Special", "Normal")
textdf <- densityData[densityData$Nact == 19, ]
mycolours <- c("Special" = "red", "Normal" = "black")

# Define the line parameters
intercept <- 0
slope <- 1

errorData <- densityData %>%
  mutate(
    y_line = intercept + slope * value,
    error = Nact - y_line
  )

# Custom labeller using as_labeller directly
label_values <- c(Nmax = "N[max]", NCluster = "N[Cluster]", NHeuristic = "N[Heuristic]", NTCN = "N[TCN]")
custom_labeller <- as_labeller(
  label_values,
  default = label_parsed # Important to parse mathematical expressions
)

gplot <- ggplot(data= densityData, aes(y=Nact,x=value, size = as.factor(densityData$frequency))) +
  #geom_smooth(method=lm) +
  geom_abline(intercept = 0, color = "red",linetype=3) +
  geom_segment(data= errorData, aes(x = value, y = Nact, xend = value, yend = y_line), size = 0.5, color = 'red') +
  geom_point() +
  scale_color_manual("Special video", values = mycolours) +
  geom_smooth(method=lm, level = 0.95, color="NA", size = 0) + #add linear trend line with a 95% confidence interval
  theme_bw() +
  theme(text=element_text(size=20), axis.text.x = element_text(angle = 25), axis.text.y = element_text(angle = 25)) +
  facet_grid(. ~ variable_f, labeller = custom_labeller) +
  scale_y_continuous(name = 'True FishAbundance', breaks = seq(0, max(densityData$value), 2), limits=c(-0.1,max(densityData$Nact)+0.1)) +
  scale_x_continuous(name = 'Estimated FishAbundance', breaks = seq(0, max(densityData$value), 2), limits=c(-0.1,max(densityData$Nact)+0.1)) +
  labs(size = "Number of videos")

my_plot_2 <- ggdraw() +
  draw_plot(gplot) +
  draw_image(logo_file,  x = 0.385, y = 0.4, scale = .15)

my_plot_2

#Get dataset information!
bbs_ALL_test <- subset(bbs_ALL, category == 'test')
bbs_ALL_test <- drop_na(bbs_ALL_test)
sum(bbs_ALL_test$Nact)
length(bbs_ALL_test$Nact[bbs_ALL_test$Nact != 0])
length(bbs_ALL_test$Nact[bbs_ALL_test$Nact == 0])

bbs_ALL_train <- subset(bbs_ALL, category == 'train')
sum(bbs_ALL_train$Nact)
length(bbs_ALL_train$Nact[bbs_ALL_train$Nact != 0])
length(bbs_ALL_train$Nact[bbs_ALL_train$Nact == 0])

All_EM <- sum(bbs_ALL$Nact)
All_EM

#get n of videos for this species 
length(bbs_ALL_test$Nact[bbs_ALL_test$Nact != 0])
length(bbs_ALL_test$Nact[bbs_ALL_test$Nact == 0])
#get n of individuals over test
sum(bbs_ALL$Nact)

#CORRLATIONS
cor(bbs_ALL$Nmax, bbs_ALL$Nact)
cor(bbs_ALL$NCluster, bbs_ALL$Nact)
cor(bbs_ALL$Nimproved, bbs_ALL$Nact)
cor(bbs_ALL$Ntcn, bbs_ALL$Nact)

sum(ae(bbs_ALL$Nmax, bbs_ALL$Nact))
sum(ae(bbs_ALL$NCluster, bbs_ALL$Nact))
sum(ae(bbs_ALL$Nimproved, bbs_ALL$Nact))
sum(ae(bbs_ALL$Ntcn, bbs_ALL$Nact))

#GET CORRELATION WITHOUT 0s
bbs_ALL_wo0 <- subset(bbs_ALL, Nact >= 1)

#wo0
cor(bbs_ALL_wo0$Nmax, bbs_ALL_wo01$Nact)
cor(bbs_ALL_wo0$NCluster, bbs_ALL_wo01$Nact)
cor(bbs_ALL_wo0$Nimproved, bbs_ALL_wo01$Nact)
cor(bbs_ALL_wo0$Ntcn, bbs_ALL_wo01$Nact)

#GET CORRELATION WITHOUT 0s AND 1s
bbs_ALL_wo01 <- subset(bbs_ALL, Nact >= 2)

#wo01
cor(bbs_ALL_wo01$Nmax, bbs_ALL_wo01$Nact)
cor(bbs_ALL_wo01$NCluster, bbs_ALL_wo01$Nact)
cor(bbs_ALL_wo01$Nimproved, bbs_ALL_wo01$Nact)
cor(bbs_ALL_wo01$Ntcn, bbs_ALL_wo01$Nact)
}

#On fully automated labels
#Before running this part, copy the best performing NHeuristic into the ./04_Results/ folder and name the file 'class_13_nheuristic_onDetections.csv'
{
  setwd(parent_dir)
  setwd("./04_Results/")
  
  bbs_actual <- read.csv("class_17_nact.csv", sep=",")
  bbs_nmax <- read.csv("class_17_nMax_onDetections.csv", sep=",")
  bbs_nCluster <- read_csv("class_17_nCluster_onDetections.csv")
  bbs_NTCN <- read_csv("class_17_Ntcn_onDetections.csv")
  bbs_nimproved <- read.csv("class_17_nheuristic_onDetections.csv", sep=",")
  
  bbs_nCluster <- bbs_nCluster %>% distinct(videoname, .keep_all = TRUE)
  
  #Data manipulation
  bbs_NTCN <- select(bbs_NTCN, -trueValue)
  
  bbs <- left_join(bbs_actual, bbs_nCluster)
  bbs <- left_join(bbs, bbs_nmax)
  bbs <- left_join(bbs, bbs_NTCN)
  
  bbs_nimproved <- select(bbs_nimproved, 'videoname', 'Nimproved')
  
  bbs_ALL <- bbs
  
  bbs_ALL <- select(bbs_ALL, c('videoname', 'category', 'Nact','Nmax','NCluster', 'Ntcn'))
  
  bbs_ALL <- left_join(bbs_ALL, bbs_nimproved)
  
  bbs_ALL <- drop_na(bbs_ALL)
  bbs_ALL <- subset(bbs_ALL, category == 'test')
  
  bbs_actual <- bbs_ALL$Nact
  
  bbsMelted <- melt(bbs_ALL)
  bbsMelted$Nact <- bbs_actual
  bbsMelted <- drop_na(bbsMelted)
  
  bbsMelted <- subset(bbsMelted, variable != 'Nact')
  bbsMelted <- subset(bbsMelted, category != 'train')
  
  #With the CLUSTER
  # New facet label names for dose variable
  methods.labs <- c("Nimproved", "Nmax", "NCluster", 'Ntcn')
  names(methods.labs) <- c("Nth0n3", "Nmax", "NCluster", 'Ntcn')
  
  #Get density value
  densityData <- bbsMelted %>%
    group_by(variable, value, Nact) %>%
    summarise(frequency = n()) %>%
    ungroup()
  
  summary(densityData)
  
  densityData$frequency[densityData$value==0 & densityData$Nact==0] <- 1
  
  #Reorder to make it look nice
  densityData$variable <- as.character(densityData$variable)
  densityData$variable[densityData$variable=='Nimproved'] <- 'NHeuristic'
  densityData$variable[densityData$variable=='Ntcn'] <- 'NTCN'
  
  densityData$variable_f = factor(densityData$variable, levels=c('Nmax', 'NCluster', 'NHeuristic', 'NTCN'))
  
  densityData$highlight <- ifelse(densityData$Nact == 19, "Special", "Normal")
  textdf <- densityData[densityData$Nact == 19, ]
  mycolours <- c("Special" = "red", "Normal" = "black")
  
  # Define the line parameters
  intercept <- 0
  slope <- 1
  
  errorData <- densityData %>%
    mutate(
      y_line = intercept + slope * value,
      error = Nact - y_line
    )
  
  # Custom labeller using as_labeller directly
  label_values <- c(Nmax = "N[max]", NCluster = "N[Cluster]", NHeuristic = "N[Heuristic]", NTCN = "N[TCN]")
  custom_labeller <- as_labeller(
    label_values,
    default = label_parsed # Important to parse mathematical expressions
  )
  
  gplot <- ggplot(data= densityData, aes(y=Nact,x=value, size = as.factor(densityData$frequency))) +
    #geom_smooth(method=lm) +
    geom_abline(intercept = 0, color = "red",linetype=3) +
    geom_segment(data= errorData, aes(x = value, y = Nact, xend = value, yend = y_line), size = 0.5, color = 'red') +
    geom_point() +
    scale_color_manual("Special video", values = mycolours) +
    geom_smooth(method=lm, level = 0.95, color="NA", size = 0) + #add linear trend line with a 95% confidence interval
    theme_bw() +
    theme(text=element_text(size=20), axis.text.x = element_text(angle = 25), axis.text.y = element_text(angle = 25)) +
    facet_grid(. ~ variable_f, labeller = custom_labeller) +
    scale_y_continuous(name = 'True FishAbundance', breaks = seq(0, max(densityData$value), 2), limits=c(-0.1,max(densityData$Nact)+0.1)) +
    scale_x_continuous(name = 'Estimated FishAbundance', breaks = seq(0, max(densityData$value), 2), limits=c(-0.1,max(densityData$Nact)+0.1)) +
    labs(size = "Number of videos")
  
  my_plot_2 <- ggdraw() +
    draw_plot(gplot) +
    draw_image(logo_file,  x = 0.385, y = 0.4, scale = .15)
  
  my_plot_2
  
  #Get dataset information!
  bbs_ALL_test <- subset(bbs_ALL, category == 'test')
  bbs_ALL_test <- drop_na(bbs_ALL_test)
  sum(bbs_ALL_test$Nact)
  length(bbs_ALL_test$Nact[bbs_ALL_test$Nact != 0])
  length(bbs_ALL_test$Nact[bbs_ALL_test$Nact == 0])
  
  bbs_ALL_train <- subset(bbs_ALL, category == 'train')
  sum(bbs_ALL_train$Nact)
  length(bbs_ALL_train$Nact[bbs_ALL_train$Nact != 0])
  length(bbs_ALL_train$Nact[bbs_ALL_train$Nact == 0])
  
  All_EM <- sum(bbs_ALL$Nact)
  All_EM
  
  #get n of videos for this species 
  length(bbs_ALL_test$Nact[bbs_ALL_test$Nact != 0])
  length(bbs_ALL_test$Nact[bbs_ALL_test$Nact == 0])
  #get n of individuals over test
  sum(bbs_ALL$Nact)
  
  #CORRLATIONS
  cor(bbs_ALL$Nmax, bbs_ALL$Nact)
  cor(bbs_ALL$NCluster, bbs_ALL$Nact)
  cor(bbs_ALL$Nimproved, bbs_ALL$Nact)
  cor(bbs_ALL$Ntcn, bbs_ALL$Nact)
  
  sum(ae(bbs_ALL$Nmax, bbs_ALL$Nact))
  sum(ae(bbs_ALL$NCluster, bbs_ALL$Nact))
  sum(ae(bbs_ALL$Nimproved, bbs_ALL$Nact))
  sum(ae(bbs_ALL$Ntcn, bbs_ALL$Nact))
  
  #GET CORRELATION WITHOUT 0s
  bbs_ALL_wo0 <- subset(bbs_ALL, Nact >= 1)
  
  #wo0
  cor(bbs_ALL_wo0$Nmax, bbs_ALL_wo01$Nact)
  cor(bbs_ALL_wo0$NCluster, bbs_ALL_wo01$Nact)
  cor(bbs_ALL_wo0$Nimproved, bbs_ALL_wo01$Nact)
  cor(bbs_ALL_wo0$Ntcn, bbs_ALL_wo01$Nact)
  
  #GET CORRELATION WITHOUT 0s AND 1s
  bbs_ALL_wo01 <- subset(bbs_ALL, Nact >= 2)
  
  #wo01
  cor(bbs_ALL_wo01$Nmax, bbs_ALL_wo01$Nact)
  cor(bbs_ALL_wo01$NCluster, bbs_ALL_wo01$Nact)
  cor(bbs_ALL_wo01$Nimproved, bbs_ALL_wo01$Nact)
  cor(bbs_ALL_wo01$Ntcn, bbs_ALL_wo01$Nact)
}