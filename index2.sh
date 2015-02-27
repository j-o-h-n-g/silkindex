#!/usr/bin/bash

INCREMENTAL_FILE=$1
ARCHIVE_PREFIX="/netflow/rwflowappend/archive/"
INDEX_PREFIX="/netflow/index/"
export SILK_CLOBBER=1

# Incremental index prefix 
OUTPUT_FILE=${INDEX_PREFIX}${INCREMENTAL_FILE#$ARCHIVE_PREFIX}
# Hour index prefix
INDEX_FILE=${OUTPUT_FILE%%???????}

# Add sip/dip suffixes
INCREMENTAL_SIP=${OUTPUT_FILE}.sip.set
INCREMENTAL_DIP=${OUTPUT_FILE}.dip.set
INDEX_SIP=${INDEX_FILE}.sip.set
INDEX_DIP=${INDEX_FILE}.dip.set

# Make sure index directory exists
mkdir -p ${INDEX_FILE%/*}

# Create the sip/dip sets from the incremental file.  Move so only completed files are merged later on
rwset --sip-file=${INCREMENTAL_SIP}.tmp --dip-file=${INCREMENTAL_DIP}.tmp ${INCREMENTAL_FILE}
mv ${INCREMENTAL_SIP}.tmp ${INCREMENTAL_SIP}
mv ${INCREMENTAL_DIP}.tmp ${INCREMENTAL_DIP}

rm ${INCREMENTAL_FILE}

#echo "Created ${INCREMENTAL_SIP} and ${INCREMENTAL_DIP}"

(
 flock -n 99 || exit 1
if [ ! -f ${INDEX_SIP} ]
then
  mv ${INCREMENTAL_SIP} ${INDEX_SIP}
  #echo "Moving ${INCREMENTAL_SIP} to ${INDEX_SIP}"
else
  #echo "Merging into ${INDEX_SIP}"
  rwsettool --union ${INDEX_SIP} ${INDEX_FILE}.??????.sip.set > ${INDEX_SIP}.tmp
  mv ${INDEX_SIP}.tmp ${INDEX_SIP} 
  rm ${INDEX_FILE}.??????.sip.set
fi
) 99>${INDEX_SIP}.LOCK
rm ${INDEX_SIP}.LOCK

(
 flock -n 100 || exit 1
if [ ! -f ${INDEX_DIP} ]
then
  mv ${INCREMENTAL_DIP} ${INDEX_DIP}
  #echo "Moving ${INCREMENTAL_DIP}"
else
  #echo "Merging into ${INDEX_DIP}"
  rwsettool --union ${INDEX_DIP} ${INDEX_FILE}.??????.dip.set > ${INDEX_DIP}.tmp
  mv ${INDEX_DIP}.tmp ${INDEX_DIP} 
  rm ${INDEX_FILE}.??????.dip.set
fi

) 100>${INDEX_DIP}.LOCK
rm ${INDEX_DIP}.LOCK

