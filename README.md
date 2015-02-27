# silkindex
Silk IPset Indexing

Uses ipsets to maintain indexes for sip and dip on silk repositories.

Add index2.sh as a POST_COMMAND in rwflowappend.conf.  This maintains corresponding sip.set and dip.sets for each file in your Silk respository.  Change ARCHIVE_PREFIX and INDEX_PREFIX to match your Silk configuration.  INDEX_PREFIX must be writable by whichever user the rwflowappend process runs as.
index2.sh uses some basic locking to prevent the same hour file being modified concurrently. It should pick up the unmerged sip.set and dip.set on subsequent runs.

Add rwsearch to your path.  Modify index_prefix and data_prefix to match your Silk installation.
rwsearch should be a drop in replacement for rwfilter.  It uses the selection flags *and* saddress/daddress to filter the flows.  Only Silk data containing the specified IP address will be read.

NOTE: rwsearch uses IPset.intersection to handle saddress/daddress in CIDR format.  For simple IPv4 IP addresse this seems slightly slower than "if saddress in sipset".  If your queries are only for single IP addresses you may benefit from replacing the "if sipset.intersection(saddress)" with this.

Additional argument --verbose added to rwsearch prints the files it will query to stderr.  This is useful if you want a rough idea how many files are being read in.  All other arguments passed to rwfilter.
