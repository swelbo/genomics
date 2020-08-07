#  This script splits the below genomes into chunks of a pre-determined size (edit in script below)
options(warn=-1)
args <- commandArgs(TRUE)
options(scipen=40)
#  Reference genome for drawing supercontig breaks
ref <- structure(list(V1 = c("Supercontig_1.1", "Supercontig_1.2", "Supercontig_1.3",
                             "Supercontig_1.4", "Supercontig_1.5", "Supercontig_1.6", "Supercontig_1.7",
                             "Supercontig_1.8", "Supercontig_1.9", "Supercontig_1.10", "Supercontig_1.11",
                             "Supercontig_1.12", "Supercontig_1.13", "Supercontig_1.14", "Supercontig_1.15",
                             "Supercontig_1.16", "Supercontig_1.17", "Supercontig_1.18", "Supercontig_1.19",
                             "Supercontig_1.20", "Supercontig_1.21", "Supercontig_1.22", "Supercontig_1.23",
                             "Supercontig_1.24", "Supercontig_1.25", "Supercontig_1.26", "Supercontig_1.27",
                             "Supercontig_1.28", "Supercontig_1.29", "Supercontig_1.30", "Supercontig_1.31",
                             "Supercontig_1.32", "Supercontig_1.33", "Supercontig_1.34", "Supercontig_1.35",
                             "Supercontig_1.36", "Supercontig_1.37", "Supercontig_1.38", "Supercontig_1.39",
                             "Supercontig_1.40", "Supercontig_1.41", "Supercontig_1.42", "Supercontig_1.43",
                             "Supercontig_1.44", "Supercontig_1.45", "Supercontig_1.46", "Supercontig_1.47",
                             "Supercontig_1.48", "Supercontig_1.49", "Supercontig_1.50", "Supercontig_1.51",
                             "Supercontig_1.52", "Supercontig_1.53", "Supercontig_1.54", "Supercontig_1.55",
                             "Supercontig_1.56", "Supercontig_1.57", "Supercontig_1.58", "Supercontig_1.59",
                             "Supercontig_1.60", "Supercontig_1.61", "Supercontig_1.62", "Supercontig_1.63",
                             "Supercontig_1.64", "Supercontig_1.65", "Supercontig_1.66", "Supercontig_1.67",
                             "Supercontig_1.68", "Supercontig_1.69"),
                      V2 = c(4440149L, 2313122L,
                             1829408L, 1803316L, 1707251L, 1545501L, 1398854L, 1069847L, 1057463L,
                             1012305L, 979369L, 937107L, 898261L, 857155L, 557602L, 498254L,
                             243426L, 48566L, 69118L, 45066L, 28371L, 17531L, 15724L, 15635L,
                             13302L, 12287L, 11745L, 11715L, 10519L, 9825L, 9499L, 9394L,
                             8891L, 8868L, 14477L, 8411L, 8246L, 7919L, 7486L, 7373L, 7250L,
                             7213L, 7203L, 7151L, 7120L, 7014L, 6856L, 6834L, 6519L, 6174L,
                             6095L, 6071L, 6016L, 5992L, 5977L, 5808L, 5752L, 8484L, 5694L,
                             5543L, 5512L, 5380L, 5288L, 5189L, 5077L, 4922L, 4755L, 4529L,
                             2608L)),
                 .Names = c("V1", "V2"),
                 row.names = c(NA, -69L),
                 class = c("data.frame")
                 )

#  x = chromosome size
#  y = chunk size
gsplit <- function(x,y,chrom){
  if( x > y ){
    srt <- seq( from = 1 , to = x , by = y )
    end <- seq( from = y , to = x , by = y )
    if( end[length(end)] < x )
      end <- c( end , x )
  } else {
    srt <- 1
    end <- x
  }
  cbind(chrom,srt,end)
}

df <- data.frame()
for( chrom in 1:69 ){
  res <- gsplit( ref[ chrom , "V2" ] , 1e5 , chrom )
  df <- rbind( df , res )
}
chunk <- unlist(df[args[1],])
out <- paste0( "Supercontig_1." , chunk[1] , ":" , chunk[2] , "-" , chunk[3] , collapse = "" )

#  Output the chunk to process and the chunk number (for easy ordering of files to recombine later)
cat(  c( out , sprintf( "%03i" , as.integer(args[1]) ) , "\n" ) , sep = "\t" )
