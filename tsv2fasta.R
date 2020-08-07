library(data.table)

args <- commandArgs(TRUE)
require(data.table, lib.loc = "~/R")

tsv <- args[1]
nms <- args[2]
fasta <- args[3]

if( grepl("\\.gz$" , tsv) )
  tsv <- paste0( "zcat " , tsv , collapse = "")

#  Read in data and names
dt <- fread( tsv , stringsAsFactors = FALSE )
nms <- scan( nms , what = character() )
setnames(dt , c("CHROM","POS",nms))

#  Get rid of N|N that appeared after using vcfallelicprimitives
for (col in 3:ncol(dt)){
  set(dt, j=col, value=gsub('N|N' , fixed = TRUE , replace = "?" , dt[[col]]))
  set(dt, j=col, value=gsub('.' , fixed = TRUE , replace = "?" , dt[[col]]))
}

#  Collapse sequence to characters
ll <- lapply( dt[,3:ncol(dt),with=FALSE] , paste0 , collapse = "" )
cat( paste0( paste0( ">" , names(ll) , "\n" ) , ll , sep = "\n" , collapse = "" ) , file = fasta )
