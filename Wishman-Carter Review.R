---

title: "R Assignment Workflow"

author: "Carter Newton"

date: "19 March 2021"

output:

  html_document: default

  pdf_document: default

  word_document: default

---



# Part 1  



### Data Inspection  

\ 



The code below was used to obtain the file size for both of the original files in this project.  



```{r echo=TRUE}

file.info("original_files/fang_et_al_genotypes.txt")

```

```{r echo=TRUE}

file.info("original_files/snp_position.txt")

```

\ 



Next I set both files to variables respective of their names.   

When these commands are ran and displayed in the Environment tab, information is provided about the amount of columns and rows in each file.   



- fang_et_al_genotypes.txt has 986 columns and 2782 lines  

- snp_position.txt has 15 columns and 983 lines  



```{r results='asis'}

f <- read.delim("original_files/fang_et_al_genotypes.txt")

```

```{r results='asis'}

s <- read.delim("original_files/snp_position.txt")

```

\ 



Knowing the titles for each column is important, so to know these titles I set a variable to represent the column names for each file.   



- the column names for "s" were transferred to variable "col_s"  

- the column names for "f" were transferred to variable "col_f"  

  - the output for colnames(f) will not be shown due to its massive output  

  

```{r echo=TRUE, results='hide'}

colnames(f)

```

```{r echo=TRUE}

colnames(s)

```



***



### Data Processing  

\ 



First, I needed to transpose the file "t".   



```{r echo=TRUE, results='hide'}

trans_f <- t(f)

```

\ 



There was a major issue with this code, as it converted the file from a data.frame to a matrix.   

To fix this issue I changed up the command a bit to ensure that the "trans_f" file would be a data.frame still and not a matrix.   



```{r echo=TRUE, results='hide'}

trans_f <- as.data.frame(t(f))

```

\ 



Now that my file was a data.frame and not a matrix I needed to do one more modification.  

I noticed the SNP_IDs that would be used to match with the "s" file were not their own column in the "trans_f" file, but instead were embedded in the row names.   

To fix this, I used the following code to create a column at position 1 that contained a replica of the row names.  



```{r echo=TRUE, results='hide'}

trans_f_rows <- tibble::rownames_to_column(trans_f, "row_names")

```

\ 



Now to prepare my file to be merged with "s", I tidied up the file by first removing two rows that are not needed in the final file.   

These rows were named "JG_OTU" and "Sample_ID" in row positions 2 and 1 respectively.   



```{r echo=TRUE, results='hide'}

trans_f_rows_group <- trans_f_rows[-c(1, 2),]

```

\ 



Now, I needed to move the row "Group" into the column names so that I can successfully merge the "s" file with my end product of the transposed "f" file.   



```{r echo=TRUE, results='hide'}

colnames(trans_f_rows_group) <- as.character(trans_f_rows_group[1, ])

```

\ 



And then since the "Group" row is still present in the table we know want to remove it so it is only the column names.   



```{r echo=TRUE, results='hide'}

trans_f_rows_group <- trans_f_rows_group[-c(1),]

```

\ 



Now to finally merge the files together. 



```{r echo=TRUE, results='hide'}

s_f <- merge(s, trans_f_rows_group, by.x="SNP_ID", by.y="Group", all=TRUE)

```

\ 



To reference back to the "Data Inspection" section, we're going to create another character file that contains the column names in our "s_f" file so we know what columns to work with in the future. 



```{r eval=FALSE}

col_s_f <- colnames(s_f)

```

\ 



Looking at the file "col_s_f" we can see that the columns needed in the final files are columns 1, 3, 4, and everything including and above 15.   

We will then delete the other columns and create a new file consisting of only SNP_ID, Chromosome #, Position, and genotypic data.   



```{r echo=TRUE, results='hide'}

s_f_SCP <- s_f[-c(2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)]

```

\ 



We will now use "s_f_SCP" as a template to create our final chromosome-ordered files.   

Before we do that, we need to create another data.frame that contains only data related to maize (ZMMIL, ZMMLR, ZMMMR).   

To create this file we need to know what columns "ZMMIL", "ZMMLR", and "ZMMMR" reside in within "s_f_SCP".

Like earlier, we will make a character vector for the column names of the file "s_f_SCP".

We will then use the grep command to find the pattern "ZMMIL" or the other group names and take note of what column numbers the console outputs.



```{r echo=TRUE, results='asis'}

col_s_f_SCP <- colnames(s_f_SCP);

grep("ZMMIL", col_s_f_SCP)

```

\



After running this code above, we find that each of the groups encompass the following columns in file "s_f_SCP". 



- ZMMIL: columns 2496-2785

- ZMMLR: columns 1213-2468

- ZMMMR: columns 2469-2495  



\ 



Next, we need to create a new data.frame that consists of "SNP_ID", "Chromosome #", "Position", and all genotypic data that falls under the columns listed above. 



```{r echo=TRUE, results='hide'}

maize_SCP <- s_f_SCP[c(1, 2, 3, 1213:2468, 2469:2495, 2496:2785)]

```

\ 



Now that we have a file consisting of SNP_ID, Chromosome, Position, and all genotypic data related to the maize groups, we will now begin making files based on chromosome number. 

The code below will be repeated for each chromosome number.

The output of this command will produce a dataframe of rows consisting of the specified chromosome number, but won't be in any numerical order based on position. 



- To also accommodate for the remaining chromosomes, simply replace "1" with whichever chromosome number you tend to organize next



```{r echo=TRUE, results='hide'}

chromosome1_maize <- as.data.frame(filter(maize_SCP, "Chromosome" == "1"))

```

\ 



After the unsorted chromosome files have been generated, we now need to sort them numerically.

Starting with increasing order, the following code was used.



- Similarly to the code above, we will repeat this code for all other chromosome numbers

- To do this, replace the value "1" with whichever chromosome number you intend to work with in that code



```{r echo=TRUE, results='hide'}

chromosome1_maize_increasing <- chromosome1_maize[order(as.numeric(as.character(chromosome1_maize$Position))),]

```

\



Now we will create files of individual chromosome dataframes that are organized in a decreasing numerical order based on the "Position" column. 



- Similar to the code above, I will type code for the result of chromosome 1 and to make the results for all other chromosomes simply replace "1" wherever it appears in the code with the corresponding chromosome number you intend to work with next

- The code needed to be changed slightly to make sure that the values in the "Position" column were correctly being ordered in a decreasing numeric fashion



```{r echo=TRUE, results='hide'}

chromosome1_maize_decreasing <- chromosome1_maize[order(decreasing = TRUE, as.numeric(as.character(chromosome1_maize$Position))),]

```

\ 



We now have all of the maize files done and can move onto Teosinte!



***



A lot of code used earlier in Data Processing will be reused during this section.  

We're going to reuse the file "s_f_SCP" as it contains strictly "SNP_IDs", "Chromosome", "Position", and all genotypic data.  

First we need to find out what columns the groups that correspond to teosinte belong in.  

To do this, we will use our grep command as we did earlier on.  

We also will use the vector we created "col_s_f_SCP" to find out the column number of the groups in the "s_f_SCP" file before we make further edits to it.  



- The groups belonging to teosinte are "ZMPBA", "ZMPIL", and "ZMPJA"

- I will show the code for one group and to find the others simply replace "ZMPBA" with the other group names in the code



```{r echo=TRUE, results='hide'}

grep("ZMPBA", col_s_f_SCP)

```

\ 



After running the code above, we find that the groups for teosinte encompass the following columns in "s_f_SCP"



- ZMPBA: columns 77-976

- ZMPIL: columns 1166-1206

- ZMPJA: columns 977-1010



\ 



Next we need to create a new data.frame that consists of "SNP_IDs", "Chromosome", "Position", and genotypic data for the groups we defined above. 



```{r echo=TRUE, results='hide'}

teosinte_SCP <- s_f_SCP[c(1, 2, 3, 77:976, 977:1010, 1166:1206)]

```

\ 



Now that we have a data.frame generated, we now want to make data.frame files for each chromosome.  

We won't organize these files by the "Position" column for now.  

These files generated will be used as templates for when we want to sort by the "Position" column. 



- I am only showing code for one chromosome, to make the files for all other chromosome numbers simply replace the number "1" wherever it appears in the code to the respective chromosome number you intend to work with next

- Changed the code a bit from when working with maize, for some reason copying the code from that section didn't work with teosinte



```{r echo=TRUE, results='hide'}

chromosome1_teosinte <- as.data.frame(filter(teosinte_SCP, teosinte_SCP$Chromosome == "1"))

```

\ 



Now that we have our unsorted files for each chromosome, we can now start creating files that are sorted by the column "Position" for each chromosome.

We will begin with increasing numeric order. 



- Once again, I am only showing code for one chromosome and to make the files for the remaining chromosomes simply replace "1" with the respective chromosome number you intend to work with throughout the code



```{r echo=TRUE, results='hide'}

chromosome1_teosinte_increasing <- chromosome1_teosinte[order(as.numeric(as.character(chromosome1_teosinte$Position))),]

```

\ 



Now that we have created increasing position files specific to chromosome number, we will go on to do decreasing position for specific chromosome numbers.



- Once again, I am only showing code for one chromosome and to make the files for the remaining chromosomes simply replace "1" with the respective chromosome number you intend to work with throughout the code



```{r echo=TRUE, results='hide'}

chromosome1_teosinte_decreasing <- chromosome1_teosinte[order(decreasing = TRUE, as.numeric(as.character(chromosome1_teosinte$Position))),]

```

\ 



We now have all of the teosinte files created!



***



# Part 2



### SNPs per chromosome

\ 



Our first graph is going to plot the total number of SNPs per chromosome.  

What makes sense is to form a bar graph for this information where we plot "Chromosome number" on the x-axis and "Total SNPs" on the y-axis.

To begin we're going to revive an old file "s_f" and use this because it contains all the groups in one folder and contains any other information we may need.  

First, we are going to find out the total number of times a specific chromosome number appears which correlates to the total number of SNPs on that chromosome. 



- Make sure to have the package "dplyr" installed to use the "filter" command

- Repeat this code for all other chromosome numbers by simplying replacing "1" wherever it appears in the code with the next chromosome you intend to work on



```{r include=FALSE, results='hide'}

library("dplyr")

```

```{r echo=TRUE, results='asis'}

chromo1 <- as.data.frame(filter(s_f, s_f$Chromosome == "1"))

chromo1 <- grep("1", chromo1$Chromosome)

chromo1 

```

\ 



With this information we now need to make a data.frame with two columns that resembles the following 



Chromosome # | Total SNPs

:----------: | :--------:

1            | 155

2            | 127

3            | 107

4            | 91

5            | 122

6            | 76

7            | 97

8            | 62

9            | 60

10           | 53



To do this we will first form two vectors and then combine them together to form a data.frame. 



```{r echo=TRUE}

chromo <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10");

SNPs <- c("155", "127", "107", "91", "122", "76", "97", "62", "60", "53");

graph1 <- data.frame(chromo, SNPs);

graph1

```

\ 

 

Now that we have our data.frame made to make our graph we will type up the command to generate our graph.

I will compute everything into one large command and explain each piece following the output. 

Also, make sure to run the command library("tidyverse") to ensure you can use the ggplot() command. 



```{r include=FALSE}

library("tidyverse")

```



```{r echo=TRUE, results='asis'}

total_SNP <- ggplot(graph1, aes(as.numeric(chromo), as.numeric(SNPs))) + geom_bar(stat = "identity", colour = "black", fill = "#f08080") + scale_x_continuous(breaks = scales::pretty_breaks(n=10)) + scale_y_continuous(breaks = scales::pretty_breaks(n=8)) + labs( x = "Chromosome Number", y = "Total Number of SNPs") + theme_minimal();

total_SNP

```

\ 



- First we default the entire command to "total_SNP"

- Next we use ggplot() to define the data and axis values of our graph

  - I put as.numeric() in the x and y positions because without the command the axis values are unorganized

- Following this we signify a bar graph with geom_bar(), stat = "identity" gets rid of an error while the alst two commands apply the black outline and fill the bars with the indicated color

- The scale_x_continuous() and scale_y_continuous commands signify how many tick marks to have on each axis

- The labs() command allows us to change the labels for the respective axis

- Lastly, the theme_minimal() applies a theme to our graph to fit your personal aesthetic 

\ 



Next we are going to make a graph showing the distribution of SNP position on the respective chromosome.

Like earlier, I will compute everything in one command and explain each chunk below.

We will use the previous file "s_f_SCP" for this command.



```{r echo=TRUE, results='asis'}

distribution <- ggplot(s_f_SCP) + geom_point(mapping = aes(x = as.numeric(s_f_SCP$Chromosome), y = as.numeric(s_f_SCP$Position)), color = s_f_SCP$Chromosome, size = 5, shape = "_") + scale_x_continuous(breaks = scales::pretty_breaks(n=10)) + labs(x = "Chromosome Number", y= "SNP Position on Chromosome", title = "Distribution of SNPs on Chromosomes") + scale_y_continuous(breaks = scales::pretty_breaks(n=8)) + theme_minimal();

distribution 

```

\ 



- First we defined the plot using the data set "s_f_SCP"

- Next we signified that we wanted a scatter plot by using gem_point()

  - Within gem_point() we set our axis variables and also modified our point shapes and colors on the graph

- Next, we went on to modify the scale_x_continuous() and scale_y_continuous() by indicating how many tick marks we wanted on each axis

- Lastly, the labs() command was used to give out graph axis labels and a title



\ 



We now have all the graphs formed for the SNPs per Chromosome section!



***



### Missing Data and Amount of Heterozygosity 

\ 



To begin forming these graphs, we need to revive the file "trans_f".  

This files will be used to create a data.frame consisting of columns that represent a "Sample_ID" and rows that are labeled by "SNP_ID" and all data within this data.frame will be genotypic data that we will convert to say either "Missing" "Homozygous" or "Heterozygous". 

\ 



To begin, let's modify "trans_f" to contain the information we want it to have.  

To do this, we will remove the rows containing "JG_OTU" and "Group".

After this we will then move the row "Sample_ID" to be the column labels and then remove the "Sample_ID" row so it is only present in the column labels.  



```{r echo=TRUE, results='hide'}

f_remove <- trans_f[-c(2, 3),];

colnames(f_remove) <- as.character(f_remove[1, ]);

f_final <- f_remove[-c(1),]

```

\ 



Now we are going to replace all genotypic data with either "Homozygous" "Heterozygous" or "Missing". 



```{r echo=TRUE, results='hide'}

f_final[f_final == "A/A"] <- "Homozygous";

f_final[f_final == "T/T"] <- "Homozygous";

f_final[f_final == "C/C"] <- "Homozygous"; 

f_final[f_final == "G/G"] <- "Homozygous";

f_final[f_final == "?/?"] <- "Missing";

f_final[f_final != "Homozygous" & f_final != "Missing"] <- "Heterozygous"

```

\ 



I don't really know where to go from here. I feel like I am taking the wrong approach but don't know what to fix. 

##Missing data and heterozygosity plots
maize_hetero_plot <- ggplot(f_final, aes(x=hetero, fill = Chromosome)) + geom_bar()
ggsave("maize_heterozygosity.png", plot = maize_hetero_plot)
teosinte_hetero_plot <- ggplot(f_final aes(x=hetero, fill = Chromosome)) + geom_bar()
ggsave("teosinte_heterozygosity.png", plot = teosinte_hetero_plot)
