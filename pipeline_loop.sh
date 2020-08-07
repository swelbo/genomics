# Run script for each

#!/bin/sh

qsub -lmem=16gb -lwalltime=10:00:00 -- /work/tsewell/Aspergillus/Scripts/pipeline.sh /work/tsewell/Aspergillus/fastqs/Af293/170309_K00166_0192_BHHMH3BBXX_6_TP-D7-012_TP-D5-006_1.fastq.gz /work/tsewell/Aspergillus/fastqs/Af293/170309_K00166_0192_BHHMH3BBXX_6_TP-D7-012_TP-D5-006_2.fastq.gz Af293

for f; do
  tempdir=$(mktemp -t -d gifdir.XXXXXX)
  ffmpeg -i "$f" "$tempdir/out%04d.gif"
  gifsicle --delay=10 --loop "$tempdir"/*.gif >"${f%.*}.gif"
  rm -rf "$tempdir"
done
