# db2csv - rewrite a .db output file to a .csv file
# initial commit to git

#load RSQLite package
library("DBI")
library("RSQLite")
library("tcltk")
library("tcltk2")
library("timeDate")

#connect to the database
sqlite    <- dbDriver("SQLite")

#select a file
# windows version
#fname <- tk_choose.files(multi=FALSE, filters = Filters[c ("db")])

# Mac version
wdir <- tk_choose.dir(default = " ", caption = "here")

setwd(wdir)
# mac version
Filters <- matrix(c(".db", ".db"), 1, 2)
Filters[]
fname <- tk_choose.files(filter=Filters)


#verify name
fname

db <- dbConnect(sqlite,fname)

#list all the tables
dbListTables(db)

#list all the fields in SensorEvents table
dbListFields(db, "SensorEvents")

#get all the fields from this table
data = dbGetQuery(db,"select * from SensorEvents")

#get the timestamps
timestamp = data$Timestamp
magtimestamp = data$MAG_TS
gpstimestamp = data$LOC_TS

#compute the difference between the timestamp
ColLen = length(timestamp)
t_diff = diff(timestamp,1)
t_diff[ColLen] = t_diff[ColLen-1]

g_diff = diff(gpstimestamp,1)
g_diff[ColLen] = g_diff[ColLen-1]
data <- cbind(GPS_Delta = g_diff, data)

m_diff = diff(magtimestamp,1)
m_diff[ColLen] = m_diff[ColLen-1]
MDColLen = length(m_diff)

idN = grep ("_ID", colnames(data))
idN
data$"_id"[1:MDColLen] <- m_diff[1:MDColLen]
names(data)[idN] = paste("MagTS_Delta")

new_Df <- cbind(DeltaTime = t_diff, data)
new_Df[,1:10]

#get the basic statistic summary
summary(t_diff)

#substitute csv for db
fname=gsub(".db",".csv",fname)

#output to csv file
write.csv(new_Df, file = fname)

#####################################################################################
#####################################################################################
#if you want to output all the db files in one folder, use the following

#get all the db files in this current folder
#files = list.files(pattern="*.db")
#loop through all the files
#for (file in files){
#  db <- dbConnect(sqlite,file)
#  data = dbGetQuery(db,"select * from SensorEvents")
#  get the output file name
#  outfile=gsub(".db",".csv",file)
#  outfile = paste(substr(basename(file), 1, nchar(basename(file)) - 3),"csv",sep=".")
#  timestamp = data$Timestamp
#  
# output the csv files in the current folder
# write.csv(, file = outfile)
# }



