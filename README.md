# Automated Counting of Fish in Diver Operated Videos (DOV) for Biodiversity Assessments
## Automated Fish Counting in DOV


# Description
This repository functions as the code and script database for the publication:

Kilian Bürgi, Rémy Sun, Charles Bouveyron, Diane Lingrand, Benoit Dérijard, et al.. Automated Counting of Fish in Diver Operated Videos (DOV) for Biodiversity Assessments. 2025. [⟨hal-04865293⟩](https://hal.science/hal-04865293)


# Demo
## Training of the Temporal Convolutional Network
1. Open 2.1_TCN_FC_joinedSpecies_3heads_PerfectCase.ipynb and 2.2_TCN_FC_joinedSpecies_3heads_FullyAutomatedCase.ipynb
2. Run the contents of the notebooks and the models will be saved accordingly

## Calibration of NHeuristic
1. Open 1_NHeuristic_Thresholding.ipynb
2. Change in the second cell the 'currentClass' variable to whatever class number your species is and then run the cell

## Get Nmax and NCluster
1. Run the scripts './02_Scripts_R/get_NCluster_NMax_classXX.R'

## Getting the graphs
Depending on the species you would like to assess use the different final_XX.R scripts in the folder 02_Scripts_R

If calibration already done:
1. Run lines from the final_XX.R script \
  1.1a Run final_XX.R lines 0 to 270 for the perfect case (this also includes the calibration) \
  1.1b Run final_XX.R lines 271 to 429 for the fully automated case

If calibration not done:
1. Run the lines 0 to 113 of the final_XX.R script
2. The two variables 'absolute_errors' and 'correlations' will give you the best performing parameters on the training set
3. Copy the file in folder '03_Datasets/dataset_XX/best performing parameters/ into the folder 04_Results and rename it to 'class_XX_nheuristic_onTestLabels.csv' OR 'class_XX_nheuristic_onDetections.csv'
4. Run lines from the final_XX.R script \
  4.1a Run final_XX.R lines 0 to 270 for the perfect case (this also includes the calibration) \
  4.1b Run final_XX.R lines 271 to 429 for the fully automated case
