setwd('.')

library(tibble)
library(dplyr)

#Boundingboxes per class  
bbs1 <- read.csv("./boundingboxes_class1_fullyAuto.csv")
bbs13 <- read.csv("./boundingboxes_class13_fullyAuto.csv")
bbs17 <- read.csv("./boundingboxes_class17_fullyAuto.csv")

#Save per species - ONLY DONE ONCE
joined1 <- left_join(Nact1, bbs1, by="videoname")
#joined1 <- select(joined1, -category.y)
#names(joined1)[names(joined1) == 'category.x'] <- 'category'
write.csv(joined1,"./boundingboxes_class1_fullyAuto.csv", row.names = FALSE)

joined13 <- left_join(Nact13, bbs13, by="videoname")
#joined13 <- select(joined13, -category.y)
#names(joined13)[names(joined13) == 'category.x'] <- 'category'
write.csv(joined13,"./boundingboxes_class13_fullyAuto.csv", row.names = FALSE)

joined17 <- left_join(Nact17, bbs17, by="videoname")
#joined17 <- select(joined17, -category.y)
#names(joined17)[names(joined17) == 'category.x'] <- 'category'
write.csv(joined17,"./boundingboxes_class17_fullyAuto.csv", row.names = FALSE)

#Join the files together
# joined1 <- left_join(Nact1, bbs1, by="videoname")
# joined1 <- joined1[13:nrow(joined1),]
# joined1 <- select(joined1, -category.y)
joined1 <- bbs1
joined1 <- add_column(joined1, Nact13=0, .before = "Nact")
joined1 <- add_column(joined1, Nact17=0, .before = "Nact")
joined1 <- add_column(joined1, species_id=1, .after = "Nact")
names(joined1)[names(joined1) == 'Nact'] <- 'Nact1'

# joined13 <- left_join(Nact13, bbs13, by="videoname")
# joined13 <- joined13[13:nrow(joined13),]
# joined13 <- select(joined13, -category.y)
joined13 <- bbs13
joined13 <- add_column(joined13, Nact1=0, .after = "Nact")
joined13 <- add_column(joined13, Nact17=0, .after = "Nact")
joined13 <- add_column(joined13, species_id=13, .after = "Nact1")
names(joined13)[names(joined13) == 'Nact'] <- 'Nact13'

# joined17 <- left_join(Nact17, bbs17, by="videoname")
# joined17 <- joined17[13:nrow(joined17),]
# joined17 <- select(joined17, -category.y)
joined17 <- bbs17
joined17 <- add_column(joined17, Nact13=0, .before = "Nact")
joined17 <- add_column(joined17, Nact1=0, .after = "Nact")
joined17 <- add_column(joined17, species_id=17, .after = "Nact1")
names(joined17)[names(joined17) == 'Nact'] <- 'Nact17'

#Concatenate all the files
finalFile <- rbind(joined1, joined13)
finalFile <- rbind(finalFile, joined17)

#Change the last column name
names(finalFile)[names(finalFile) == 'category.x'] <- 'category'

#Save the file
write.csv(finalFile,"./03_Datatsets/boundingboxes_joined_3heads_fullyAuto.csv", row.names = FALSE)


