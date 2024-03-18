library(dplyr)
library(stringr)
library(tidyr)

## Check what tags there are in the gff3 output of interproscan ##

#read the annotation files into R
intpro <- read.table("path/to/interproscan_annotations.gff3", header = F, sep = "\t", comment.char = "#", stringsAsFactors = FALSE)
genes <- read.table("path/to/gene_annotations.gff", header = F, sep = "\t", comment.char = "#", stringsAsFactors = FALSE)
orthologs <- read.table("psth/to/MM_8wexw920.emapper.orthologs", header = F, sep = "\t", fill = T, comment.char = "#", stringsAsFactors = FALSE)

#retrieve orthologs from arabidopsis thaliana
orthologs <- orthologs %>%
  filter(V3 == "Arabidopsis thaliana(3702)") %>%
  select(c(V1, V4)) %>%
  rename("seqid" = V1, "A.thaliana_Orthologs" = V4)

#extract tags (last column) based on database (second column)
tags <- intpro %>%
  group_by(intpro[,2]) %>%
  summarise(ids = list(unique(unlist(str_extract_all(intpro[,9], "(\\w+)(?==)")))))


## Add the tag information of interest from interpro output to the gene annotation file ##

#Rename columns
intpro <- intpro %>%
  rename(seqid = V1,
         source = V2,
         type = V3,
         start = V4,
         end = V5,
         score = V6,
         strand = V7,
         phase = V8,
         attributes = V9) %>%
  select(seqid, source, attributes)




## For the time being we are interested in Ontology_term, and Name
intpro_organized <- intpro %>%
  #break rows using separator ";"
  separate_rows(attributes, sep= ";") %>%
  #divide each row into two columns using separator "="
  separate(attributes, into = c("Attribute", "Value"), sep = "=")


# New columns to store Pfam and PANTHER IDs
db_ids <- intpro_organized %>%
  filter(Attribute == "Name") %>%
  distinct(seqid, source,.keep_all = T) %>%
  pivot_wider(names_from = source, values_from = Value) %>%
  select(seqid, Pfam, PANTHER) %>%
  rename(Pfam_ID = Pfam, PANTHER_ID = PANTHER)

intpro_organized <- intpro_organized %>%
  #only keep distinct combinations of transcript name, attribute tag, and attribute value
  distinct(seqid, Attribute, Value) %>%
  #collect values of the attributes for each transcript in a single row corresponding to that transcript
  pivot_wider(names_from = Attribute, values_from = Value,
  values_fn = function (x) paste(x, collapse = ",")) %>%
  #filter columns
  select(seqid, Ontology_term)

  #add database IDs
  annotation_tbl <- left_join(db_ids, intpro_organized, by ="seqid") %>%
    left_join(orthologs, by = "seqid") %>%
    #prepend values with attribution tag (column name)
    mutate(across(-1, ~ paste0(cur_column(), "=", .))) %>%
    #concatenate columns
    unite(Attributes, Pfam_ID:A.thaliana_Orthologs, sep = ";")

# add attributes to the gff3 gene annotation file

## select transcripts only
transcripts <- genes %>%
  filter(V3 == 'transcript')

## extract IDs
transcripts$id <- gsub(".*ID=(.*?);.*", "\\1", transcripts$V9)

##join with proteins table
joined_tbl <- left_join(transcripts, annotation_tbl, by = c("id" = "seqid"))

##join with genes table
genes <- genes %>%
  left_join(select(joined_tbl, V9, Attributes), by = c("V9"="V9"))  %>%
  unite(V9, V9, Attributes, sep = ";", na.rm = T)

#save file
write.table(genes, "Downloads/Ahypochondriacus_2.2.gff", sep = "\t", row.names = FALSE)
