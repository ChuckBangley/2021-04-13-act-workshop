# Intro to R for Telemetry Summaries ---------------------------------
# GLATOS workshop 2021-03-30
# Instructors: Bruce Delo and Caitlin Bate

#install.packages("readxl")
#install.packages("viridis")
#install.packages("lubridate")
#install.packages("ggmap")
#install.packages("plotly")
#install.packages("tidyverse")  


library(tidyverse) # really neat collection of packages! https://www.tidyverse.org/

#make sure to read all "mask" messages

setwd('C:/Users/ct991305/Documents/Workshop Material/2021-03-30-glatos-workshop/data/') #set folder you're going to work in
getwd() #check working directory

#Everyone check to make sure all the files in the /data folder are UNZIPPED

## Operators ---------------------------------

3 + 5 #maths! including - , *, /

weight_kg <- 55 #assignment operator! for objects/variables. shortcut: alt + - 
weight_kg

weight_lb <- 2.2 * weight_kg #can assign output to an object. can use objects to do calculations

# Challenge 1:
# if we change the value of weight_kg to be 100, does the value of weight_lb also change automatically?
# remember: you can check the contents of an object by simply typing out its name



## Functions ---------------------------------

ten <- sqrt(weight_kg) #contain calculations wrapped into one command to type. 
#functions take "arguments": you have to tell them what to run their script against

round(3.14159) #don't have to assign

args(round) #the args() function will show you the required arguments of another function

?round #will show you the full help page for a function, so you can see what it does, 
#what argument it takes etc.

#Challenge 2: can you round the value 3.14159 to two decimal places?
# using args() should give a clue!



## Vectors and Data Types ---------------------------------

weight_g <- c(21, 34, 39, 54, 55) #use the combine function to join values into a vector object

length(weight_g) #explore vector
class(weight_g) #a vector can only contain one data type
str(weight_g) #find the structure of your object.
#our vector is numeric. 
#other options include: character (words), logical (TRUE or FALSE), integer etc.

animals <- c("mouse", "rat", "dog") #to create a character vector, use quotes


#Challenge 3: what data type will this vector become? You can check using class()
#challenge3 <- c(1, 2, 3, "4")



#R will convert (force) all values in a vector to the same data type.
#for this reason: try to keep one data type in each vector
#a data table / data frame is just multiple vectors (columns)
#this is helpful to remember when setting up your field sheets!

## Missing Data ---------------------------------

heights <- c(2, 4, 4, NA, 6)
mean(heights) #some functions cant handle NAs
mean(heights, na.rm = TRUE) #remove the NAs before calculating

#other ways to get a dataset without NAs:

heights[!is.na(heights)] #select for values where its NOT NA 
#[] square brackets are the base R way to select a subset of data --> called indexing
#! is an operator that reverses the function

na.omit(heights) #omit the NAs

heights[complete.cases(heights)] #select only complete cases

#Challenge 4: 
#1. Using this vector of heights in inches, create a new vector, heights_no_na, with the NAs removed.
  #heights <- c(63, 69, 60, 65, NA, 68, 61, 70, 61, 59, 64, 69, 63, 63, NA, 72, 65, 64, 70, 63, 65)
#2. Use the function median() to calculate the median of the heights vector.
#BONUS: Use R to figure out how many people in the set are taller than 67 inches.



## Exploring Detection Extracts ---------------------------------
# what is a detection extract? https://members.oceantrack.org/data/otn-detection-extract-documentation-matched-to-animals 

lamprey_dets <- read_csv("inst_extdata_lamprey_detections.csv", guess_max = 3102) 

#imports file into R. paste the filepath to the unzipped file here!
#read_csv() is from tidyverse's readr package --> you can also use read.csv() from base R but it created a dataframe (not tibble) so loads slower
#see https://link.medium.com/LtCV6ifpQbb 
#the guess_max argument is helpful when there are many rows of NAs at the top. R will not assign a data type to that columns until it reaches the max guess.
#I chose to use this here because I got the following warning from read_csv()
# Warning: 4497 parsing failures.
#row                col           expected     actual                                  file
#3102 sensor_value       1/0/T/F/TRUE/FALSE 66.000     'inst_extdata_lamprey_detections.csv'
#3102 sensor_unit        1/0/T/F/TRUE/FALSE ADC        'inst_extdata_lamprey_detections.csv'
##3102 glatos_caught_date 1/0/T/F/TRUE/FALSE 2012-07-04 'inst_extdata_lamprey_detections.csv'
#3103 sensor_value       1/0/T/F/TRUE/FALSE 62.000     'inst_extdata_lamprey_detections.csv'
#3103 sensor_unit        1/0/T/F/TRUE/FALSE ADC        'inst_extdata_lamprey_detections.csv'

head(lamprey_dets) #first 6 rows
View(lamprey_dets) #can also click on object in Environment window
str(lamprey_dets) #can see the type of each column (vector)
glimpse(lamprey_dets) #similar to str()

summary(lamprey_dets$release_latitude) #summary() is a base R function that will spit out some quick stats about a vector (column)
#the $ syntax is the way base R selects columns from a data frame

#Challenge 5: 
#1. What is is the class of the station column in lamprey_dets?
#2. How many rows and columns are in the lamprey_dets dataset?



## Data Manipulation with dplyr --------------------------------------

library(dplyr) #can use tidyverse package dplyr to do exploration on dataframes in a nicer way

# %>% is a "pipe" which allows you to join functions together in sequence. 
#it can be read as "and then". shortcut: ctrl + shift + m

lamprey_dets %>% dplyr::select(6) #selects column 6

# dplyr::select this syntax is to specify that we want the select function from the dplyr package. 
#often functions are named the same but do diff things

lamprey_dets %>% slice(1:5) #selects rows 1 to 5 dplyr way

lamprey_dets %>% 
  distinct(glatos_array) %>% 
  nrow #number of arrays that detected my fish in dplyr! first: find the distinct values, then count 


lamprey_dets %>% 
  distinct(animal_id) %>% 
  nrow #number of animals that were detected 

lamprey_dets %>% filter(animal_id=="A69-1601-1363") #filtering in dplyr!

lamprey_dets %>% filter(detection_timestamp_utc >= '2012-06-01 00:00:00') #all dets on/after June 1 2012 - conditional filtering!


#get the mean value across a column using GroupBy and Summarize

lamprey_dets %>%
  group_by(animal_id) %>%  #we want to find meanLat for each animal
  summarise(MeanLat=mean(deploy_lat)) #uses pipes and dplyr functions to find mean latitude for each fish. 
                                      #we named this new column "MeanLat" but you could name it anything

#Challenge 6: 
#1. find the max lat and max longitude for animal "A69-1601-1363"
#2. find the min lat/long of each animal for detections occurring in July 2012



## Dealing with Datetimes in lubridate ---------------------------------

library(lubridate) 

lamprey_dets %>% mutate(detection_timestamp_utc=ymd_hms(detection_timestamp_utc)) #Tells R to treat this column as a date, not number numbers

#as.POSIXct(lamprey_dets$detection_timestamp_utc) #this is the base R way - if you ever see this function

#lubridate is amazing if you have a dataset with multiple datetime formats / timezone
#the function parse_date_time() can be used to specify multiple date formats if you have a dataset with mixed rows
#the function with_tz() can change timezone. accounts for daylight savings too!

#example code to change timezone:
#My_Data_Set %>% mutate(datetime = ymd_hms(datetime, tz = "America/Nassau")) #change your column to a datetime format, specifying TZ (eastern)
#My_Data_Set %>% mutate(datetime_utc = with_tz(datetime, tzone = "UTC")) #make new column called datetime_utc which is datetime converted to UTC


## Plotting with ggplot2 ---------------------------------

# basic formula:
# ggplot(data = <DATA>, mapping = aes(<MAPPINGS>)) +  <GEOM_FUNCTION>()

library(ggplot2) #tidyverse-style plotting, a very customizable plotting package


# Assign plot to a variable
lamprey_dets_plot <- ggplot(data = lamprey_dets, 
                  mapping = aes(x = deploy_lat, y = deploy_long)) #can assign a base plot to data

# Draw the plot 
lamprey_dets_plot + 
  geom_point(alpha=0.1, 
             colour = "blue") 
#layer whatever geom you want onto your plot template
#very easy to explore diff geoms without re-typing
#alpha is a transparency argument in case points overlap. try with alpha = 0.02 for fun!

lamprey_dets %>%  
  ggplot(aes(deploy_lat, deploy_long)) + #aes = the aesthetic/mappings. x and y etc.
  geom_point() #geom = the type of plot

lamprey_dets %>%  
  ggplot(aes(deploy_lat, deploy_long, colour = animal_id)) + #colour by individual! specify in the aesthetic
  geom_point()

#anything you specify in the aes() is applied to the actual data points/whole plot, 
#anything specified in geom() is applied to that layer only (colour, size...). sometimes you have >1 geom layer so this makes more sense!

#Challenge 7: try making a scatterplot showing the lat/long for animal "A69-1601-1363", 
            # coloured by detection array



#Question: what other geoms are there? Try typing `geom_` into R to see what it suggests!



# Answering Qs for Reporting ---------------------------------

View(lamprey_dets) #already have our Lamprey tag matches

walleye_dets <- read_csv("inst_extdata_walleye_detections.csv", guess_max = 9595) #remember guess_max from prev section!


#Warning: 9595 parsing failures.
#row          col           expected actual                                  file
#3047 sensor_value 1/0/T/F/TRUE/FALSE    11  'inst_extdata_walleye_detections.csv'
#3047 sensor_unit  1/0/T/F/TRUE/FALSE    ADC 'inst_extdata_walleye_detections.csv'
#3048 sensor_value 1/0/T/F/TRUE/FALSE    11  'inst_extdata_walleye_detections.csv'
#3048 sensor_unit  1/0/T/F/TRUE/FALSE    ADC 'inst_extdata_walleye_detections.csv'
#3049 sensor_value 1/0/T/F/TRUE/FALSE    11  'inst_extdata_walleye_detections.csv'

#lets join them!
all_dets <- rbind(lamprey_dets, walleye_dets)


# lets import GLATOS receiver station data for the whole network
glatos_receivers <- read_csv("inst_extdata_sample_receivers.csv")

View(glatos_receivers)

#Lets import our workbook now!

library(readxl)

walleye_deploy <- read_excel('inst_extdata_walleye_workbook.xlsm', sheet = 'Deployment') #pull in deploy
View(walleye_deploy)

walleye_recovery <- read_excel('inst_extdata_walleye_workbook.xlsm', sheet = 'Recovery') #pull in recovery
View(walleye_recovery)

#join them together

walleye_recovery <- walleye_recovery %>% rename(INS_SERIAL_NO = INS_SERIAL_NUMBER) #first, rename INS_SERIAL_NUMBER

walleye_recievers = merge(walleye_deploy, walleye_recovery,
                          by.x = c("GLATOS_PROJECT", "GLATOS_ARRAY", "STATION_NO",
                                    "CONSECUTIVE_DEPLOY_NO", "INS_SERIAL_NO"), 
                          by.y = c("GLATOS_PROJECT", "GLATOS_ARRAY", "STATION_NO", 
                                    "CONSECUTIVE_DEPLOY_NO", "INS_SERIAL_NO"), 
                          all.x=TRUE, all.y=TRUE) #keep all the info from each, merged using the above columns

View(walleye_recievers)

#need Tagging metadata too!

walleye_tag <- read_excel('inst_extdata_walleye_workbook.xlsm', sheet = 'Tagging')
View(walleye_tag)

#remember: we learned how to switch timezone of datetime columns above, 
# if that is something you need to do with your dataset!! 
  #hint: check GLATOS_TIMEZONE column to see if its what you want!

#the glatos R package (will be reviewed in the workshop tomorrow) can import your workbook in one step
#will format all datetimes to UTC, check for conflicts, join the deploy/recovery tabs etc.

library(glatos) #wont work unless you happen to have this installed - just an teaser today, will be covered tomorrow
data <- read_glatos_workbook('inst_extdata_walleye_workbook.xlsm')
receivers <- data$receivers
animals <-  data$animals


## Section 1: for Array Operators --------------------
#1. map GLATOS locations

library(ggmap)

#make a basemap for all of the stations, using the min/max deploy lat and longs as bounding box
#what are our columns called?
names(glatos_receivers)


base <- get_stamenmap(
  bbox = c(left = min(glatos_receivers$deploy_long), 
           bottom = min(glatos_receivers$deploy_lat), 
           right = max(glatos_receivers$deploy_long), 
           top = max(glatos_receivers$deploy_lat)),
  maptype = "terrain-background", 
  crop = FALSE,
  zoom = 8)

#filter for stations you want to plot - this is very customizable
glatos_deploy_plot <- glatos_receivers %>% 
  mutate(deploy_date=ymd_hms(deploy_date_time)) %>% #make a datetime
  mutate(recover_date=ymd_hms(recover_date_time)) %>% #make a datetime
  filter(!is.na(deploy_date)) %>% #no null deploys
  filter(deploy_date > '2011-07-03' & recover_date < '2018-12-11') %>% #only looking at certain deployments, can add start/end dates here
  group_by(station, glatos_array) %>% 
  summarise(MeanLat=mean(deploy_lat), MeanLong=mean(deploy_long)) #get the mean location per station, in case there is >1 deployment

# you could choose to plot stations which are within a certain bounding box!
#to do this you would add another filter to the above data, before passing to the map
# ex: add this line after the mutate() clauses:
# filter(latitude <= 0.5 & latitude >= 24.5 & longitude <= 0.6 & longitude >= 34.9)


#add your stations onto your basemap
glatos_map <- 
  ggmap(base, extent='panel') + 
  ylab("Latitude") +
  xlab("Longitude") +
  geom_point(data = glatos_deploy_plot, #filtering for recent deployments
             aes(x = MeanLong,y = MeanLat, colour = glatos_array), #specify the data
             shape = 19, size = 2) #lots of aesthetic options here!

#view your receiver map!
glatos_map

#save your receiver map into your working directory
ggsave(plot = glatos_map, filename = "glatos_map.tiff", units="in", width=15, height=8) 
#can specify location, file type and dimensions


#2. map array locations
# we can do the same exact thing with the deployment metadata from OUR project only!

base <- get_stamenmap(
  bbox = c(left = min(walleye_recievers$DEPLOY_LONG), 
           bottom = min(walleye_recievers$DEPLOY_LAT), 
           right = max(walleye_recievers$DEPLOY_LONG), 
           top = max(walleye_recievers$DEPLOY_LAT)),
  maptype = "terrain-background", 
  crop = FALSE,
  zoom = 8)

#filter for stations you want to plot - this is very customizable
walleye_deploy_plot <- walleye_recievers %>% 
  mutate(deploy_date=ymd_hms(GLATOS_DEPLOY_DATE_TIME)) %>% #make a datetime
  mutate(recover_date=ymd_hms(GLATOS_RECOVER_DATE_TIME)) %>% #make a datetime
  filter(!is.na(deploy_date)) %>% #no null deploys
  filter(deploy_date > '2011-07-03' & is.na(recover_date)) %>% #only looking at certain deployments, can add start/end dates here
  group_by(STATION_NO, GLATOS_ARRAY) %>% 
  summarise(MeanLat=mean(DEPLOY_LAT), MeanLong=mean(DEPLOY_LONG)) #get the mean location per station, in case there is >1 deployment

#add your stations onto your basemap
walleye_deploy_map <- 
  ggmap(base, extent='panel') +
  ylab("Latitude") +
  xlab("Longitude") +
  geom_point(data = walleye_deploy_plot, #filtering for recent deployments
             aes(x = MeanLong,y = MeanLat, colour = GLATOS_ARRAY), #specify the data
             shape = 19, size = 2) #lots of aesthetic options here!


#view your receiver map!
walleye_deploy_map

#save your receiver map into your working directory
ggsave(plot = walleye_deploy_map, filename = "walleye_deploy_map.tiff", units="in", width=15, height=8) 
#can specify location, file type and dimensions


#3. interactive map https://plotly.com/r/scatter-plots-on-maps/

library(plotly)

#set your basemap
geo_styling <- list(
  fitbounds = "locations", visible = TRUE, #fits the bounds to your data!
  showland = TRUE,
  showlakes = TRUE,
  lakecolor = toRGB("blue", alpha = 0.2), #make it transparent.
  showcountries = TRUE,
  landcolor = toRGB("gray95"),
  countrycolor = toRGB("gray85")
)

#decide what data you're going to use
glatos_map_plotly <- plot_geo(glatos_deploy_plot, lat = ~MeanLat, lon = ~MeanLong)  

#add your markers for the interactive map
glatos_map_plotly <- glatos_map_plotly %>% add_markers(
  text = ~paste(station, MeanLat, MeanLong, sep = "<br />"),
  symbol = I("square"), size = I(8), hoverinfo = "text" 
)

#Add layout (title + geo stying)
glatos_map_plotly <- glatos_map_plotly %>% layout(
  title = 'GLATOS Deployments<br />(> 2011-07-03)', geo = geo_styling
)

#View map
glatos_map_plotly

#4. How are my stations performing?

det_summary  <- all_dets  %>%
  filter(glatos_project_receiver == 'HECST') %>%  #choose to summarize by array, project etc!
  mutate(detection_timestamp_utc=ymd_hms(detection_timestamp_utc))  %>%
  group_by(station, year = year(detection_timestamp_utc), month = month(detection_timestamp_utc)) %>%
  summarize(count =n())

det_summary #number of dets per month/year per station

anim_summary  <- all_dets  %>%
  filter(glatos_project_receiver == 'HECST') %>%  #choose to summarize by array, project etc!
  mutate(detection_timestamp_utc=ymd_hms(detection_timestamp_utc))  %>%
  group_by(station, year = year(detection_timestamp_utc), month = month(detection_timestamp_utc), common_name_e) %>%
  summarize(count =n())

anim_summary #number of dets per month/year per station & species




       
## Section 2: for Taggers --------------------

#5. map detections and releases 

base <- get_stamenmap(
  bbox = c(left = min(all_dets$deploy_long),
           bottom = min(all_dets$deploy_lat), 
           right = max(all_dets$deploy_long), 
           top = max(all_dets$deploy_lat)),
  maptype = "terrain-background", 
  crop = FALSE,
  zoom = 8)


#add your detections onto your basemap
detections_map <- 
  ggmap(base, extent='panel') +
  ylab("Latitude") +
  xlab("Longitude") +
  geom_point(data = all_dets,
             aes(x = deploy_long,y = deploy_lat, colour = common_name_e), #specify the data
             shape = 19, size = 2) #lots of aesthetic options here!

#view your tagging map!
detections_map


#6. interactive map https://plotly.com/r/scatter-plots-on-maps/ 

#set your basemap
geo_styling <- list(
  fitbounds = "locations", visible = TRUE, #fits the bounds to your data!
  showland = TRUE,
  showlakes = TRUE,
  lakecolor = toRGB("blue", alpha = 0.2), #make it transparent
  showcountries = TRUE,
  landcolor = toRGB("gray95"),
  countrycolor = toRGB("gray85")
)

#decide what data you're going to use
detections_map_plotly <- plot_geo(all_dets, lat = ~deploy_lat, lon = ~deploy_long) 

#add your markers for the interactive map
detections_map_plotly <- detections_map_plotly %>% add_markers(
  text = ~paste(animal_id, common_name_e, paste("Date detected:", detection_timestamp_utc), 
                paste("Latitude:", deploy_lat), paste("Longitude",deploy_long), 
                paste("Detected by:", glatos_array), paste("Station:", station), 
                paste("Project:",glatos_project_receiver), sep = "<br />"),
  symbol = I("square"), size = I(8), hoverinfo = "text" 
)

#Add layout (title + geo stying)
detections_map_plotly <- detections_map_plotly %>% layout(
  title = 'Lamprey and Walleye Detections<br />(2012-2013)', geo = geo_styling
)

#View map
detections_map_plotly


#7. Summary of tagged animals

# summary of animals you've tagged
walleye_tag_summary <- walleye_tag %>% 
  mutate(GLATOS_RELEASE_DATE_TIME = ymd_hms(GLATOS_RELEASE_DATE_TIME)) %>% 
  #filter(GLATOS_RELEASE_DATE_TIME > '2012-06-01') %>% #select timeframe, specific animals etc.
  group_by(year = year(GLATOS_RELEASE_DATE_TIME), COMMON_NAME_E) %>% 
  summarize(count = n(), 
            Meanlength = mean(LENGTH, na.rm=TRUE), 
            minlength= min(LENGTH, na.rm=TRUE), 
            maxlength = max(LENGTH, na.rm=TRUE), 
            MeanWeight = mean(WEIGHT, na.rm = TRUE)) 

#view our summary table
walleye_tag_summary


#8. detection attributes by year/month, per collector array or species

#Average location of each animal!
all_dets %>% 
  group_by(animal_id) %>% 
  summarize(NumberOfStations = n_distinct(station),
            AvgLat = mean(deploy_lat),
            AvgLong =mean(deploy_long))


#Avg length per location
all_dets_summary <- all_dets %>% 
  mutate(detection_timestamp_utc = ymd_hms(detection_timestamp_utc)) %>% 
  group_by(glatos_array, station, deploy_lat, deploy_long, common_name_e)  %>%  
  summarise(AvgSize = mean(length, na.rm=TRUE))

all_dets_summary

#export our summary table as CSV
write_csv(all_dets_summary, "detections_summary.csv", col_names = TRUE)

# count detections per transmitter, per array

all_dets %>% 
  group_by(transmitter_id, glatos_array, common_name_e) %>% 
  summarize(count = n()) %>% 
  select(transmitter_id, common_name_e, glatos_array, count)


# list all glatos arrays each fish was seen on, and a number_of_arrays column too

all_dets %>% 
  group_by(animal_id) %>% 
  mutate(arrays =  (list(unique(glatos_array)))) %>% #create a column with a list of the arrays
  dplyr::select(animal_id, arrays)  %>% #remove excess columns
  distinct_all() %>% #keep only one record of each
  mutate(number_of_arrays = sapply(arrays,length)) %>% #sapply: applies a function across a List - in this case we are applying length()
  as.data.frame()

#9. total detection counts by year/month

all_dets  %>% 
  mutate(detection_timestamp_utc=ymd_hms(detection_timestamp_utc)) %>% #make datetime
  mutate(year_month = floor_date(detection_timestamp_utc, "months")) %>% #round to month
 filter(common_name_e == 'walleye') %>% #can filter for specific stations, dates etc. doesn't have to be species!
  group_by(year_month) %>% #can group by station, species et - doesn't have to be by date
  summarize(count =n()) %>% #how many dets per year_month
  ggplot(aes(x = (month(year_month) %>% as.factor()), 
             y = count, 
             fill = (year(year_month) %>% as.factor())
  )
  )+ 
  geom_bar(stat = "identity", position = "dodge2")+ 
  xlab("Month")+
  ylab("Total Detection Count")+
  ggtitle('Walleye Detections by Month (2012-2013)')+ #title
  labs(fill = "Year") #legend title





## Other Example Plots -----------

# lots of information on this cheatsheet here https://rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf

# an easy abacus plot!

#Use the color scales in this package to make plots that are pretty, 
#better represent your data, easier to read by those with colorblindness, and print well in grey scale.
library(viridis)

abacus_animals <- 
  ggplot(data = all_dets, aes(x = detection_timestamp_utc, y = animal_id, col = glatos_array)) +
  geom_point() +
  ggtitle("Detections by animal") +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  scale_color_viridis(discrete = TRUE)

abacus_animals

abacus_stations <- 
  ggplot(data = all_dets,  aes(x = detection_timestamp_utc, y = station, col = animal_id)) +
  geom_point() +
  ggtitle("Detections by station") +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  scale_color_viridis(discrete = TRUE)

abacus_stations #might be better with just a subet, huh??

#track movement using geom_path!!

movMap <- 
  ggmap(base, extent = 'panel') + #use the BASE we set up before
  ylab("Latitude") +
  xlab("Longitude") +
  geom_path(data = all_dets, aes(x = deploy_long, y = deploy_lat, col = common_name_e)) + #connect the dots with lines
  geom_point(data = all_dets, aes(x = deploy_long, y = deploy_lat, col = common_name_e)) + #layer the stations back on
  scale_colour_manual(values = c("red", "blue"), name = "Species")+ #
  facet_wrap(~animal_id, ncol = 6, nrow=1)+
  ggtitle("Inferred Animal Paths")

#to size the dots by number of detections you could do something like: size = (log(length(animal)id))?

movMap


# monthly latitudinal distribution of your animals (works best w >1 species)

all_dets %>%
  group_by(month=month(detection_timestamp_utc), animal_id, common_name_e) %>% #make our groups
  summarise(meanlat=mean(deploy_lat)) %>% #mean lat
  ggplot(aes(month %>% factor, meanlat, colour=common_name_e, fill=common_name_e))+ #the data is supplied, but no info on how to show it!
  geom_point(size=3, position="jitter")+   # draw data as points, and use jitter to help see all points instead of superimposition
  #coord_flip()+   #flip x y, not needed here
  scale_colour_manual(values = c("brown", "green"))+ #change the colour to represent the species better!
  scale_fill_manual(values = c("brown", "green"))+  #colour of the boxplot
  geom_boxplot()+ #another layer
  geom_violin(colour="black") #and one more layer


# per-individual contours - lots of plots: called facets!
all_dets %>%
  ggplot(aes(deploy_long, deploy_lat))+
  facet_wrap(~animal_id)+ #make one plot per individual
  geom_violin()


