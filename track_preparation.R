##### packages
library(data.table)
library(RcppCNPy)
library(factoextra)
library(ggfortify)
library(cowplot)
library(dplyr)
library(tidyr)

nice_layout<-   theme_cowplot()+
  panel_border(color = "grey85", size = 1, linetype = 1,
               remove = FALSE, "black")

#Build a table of summary statistics for each species
for (population in c("caudatus", "cruentus", "hybridus", "hypochondriacus", "quitensis"))
{
  population_tests <-fread(paste0("/home/student1/Downloads/",population,"_tests.bedgraph")) %>%
  dplyr::rename(CHR=V1, StartPos=V2, EndPos=V3, tW=V4, tP=V5, Tajima=V6, nSites=V7) %>%
  mutate(Watterson=tW/nSites, pi=tP/nSites, species = population)

  #Change NA to 0 to avoid problems while uploading tracks to JBrowse
  population_tests <- mutate_all(population_tests, ~replace_na(.,0))

  #Track: pi
  population_tests %>%
  select(CHR, StartPos, EndPos, pi) %>%
  fwrite(paste0(population,"_pi.bedgraph"), sep = "\t")

  #Track: Watterson's estimator
  population_tests %>%
  select(CHR, StartPos, EndPos, Watterson) %>%
  fwrite(paste0(population,"_tW.bedgraph"), sep = "\t")

  #Track: Tajima's D
  population_tests %>%
  select(CHR, StartPos, EndPos, Tajima) %>%
  fwrite(paste0(population,"_Tajima.bedgraph"), sep = "\t")

  #Build table of combined statistics

  ##Extract columns of interest
  population_tests_clear <- population_tests[,c("pi", "Watterson", "Tajima", "nSites")]

  ##Create a new column to store species information
  population_tests_clear$"species" <- rep(population, nrow(population_tests))

  ##Change table name
  assign(paste0(population,"_tests"), population_tests_clear)
}
