#Combine statistics tables for all species
population_tests <- rbind(caudatus_tests, cruentus_tests, hybridus_tests, hypochondriacus_tests, quitensis_tests)

#Filter for a minimum of 250 sites
all_species.filtered <- population_tests %>%
  filter(nSites>250)

#Summarise table based on groups and get summary
all_species.filtered %>%
  group_by(species) %>%
  summarise_if(is.numeric, mean)

#Build plots
##Tajima's D
plot_Tajima_all_species_filtered <- ggplot(all_species.filtered, aes(x=Tajima)) +
  geom_density(aes(color = species, fill=species), alpha=0.4) +
  nice_layout +
  labs(title = "Tajima")

##Pi
plot_pi_all_species_filtered<- ggplot(all_species.filtered, aes(x=pi)) +
  geom_density(aes(color = species, fill=species), alpha=0.4) +
  nice_layout +
  labs(title = "pi")

##Watterson's Estimator
plot_Watterson_all_species_filtered<-     ggplot(all_species.filtered, aes(x=Watterson)) +
  geom_density(aes(color = species, fill=species), alpha=0.4) +
  nice_layout      +
  labs(title = "Watterson")



title.filtered <- ggdraw() +
  draw_label(
    "All species nsites >250",
    fontface = 'bold',
    x = 0,
    hjust = 0
  )

plot_grid(plot_Tajima_all_species_filtered, plot_pi_all_species_filtered, plot_Watterson_all_species_filtered, labels="AUTO", title.filtered)
