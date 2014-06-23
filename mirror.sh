#!/bin/bash 
DOWNDIR=''	# Where we save all downloaded files (dont save directly to Apache folder since we need to edit the files first)
NEWHOST=''	# The new domain name to edit files to
OLDHST=''	# old domain name co wget from
PUBLISHDIR=""	# The folder we publish the web content to (dont forget trailing slash)


function MIRROR()
{
	mkdir -p "$DOWNDIR" &&\
	pwd &&\
	cd "$DOWNDIR" &&\
	[ -f ./COOKIEFILE ] && rm -f ./COOKIEFILE	# Remove any old cookie file
	wget --retry-connrefused --mirror -N --no-use-server-timestamps --limit-rate=60k -m -np -w 1 -a $OLDHST_phpBB3_$(date +%Y%m%d).log -e robots=off -nv --adjust-extension --convert-links --page-requisites  --reject-regex='(\?p=|&p=|mode=reply|view=|search.php)' --warc-file=$OLDHST_phpBB3 --warc-cdx --keep-session-cookies --load-cookies=COOKIEFILE http://$OLDHST &&\
	return 0
}

function EDITFILES()
{
	ESCNEW=$(echo $NEWHOST | sed "s%\.%\\\.%g")			# Escape dots so sed can handle it
	ESCOLD=$(echo $OLDHST | sed "s%\.%\\\.%g")			# Escape dots so sed can handle it
	cd "$DOWNDIR" &&\
	find "$DOWNDIR/$OLDHST/" -type f -exec sed -i "s/$ESCOLD/$ESCNEW/g" {} \; &&\
	return 0 || echo "Failed to edit files!"
	
}

function PUBLISHFORUM()
{
	rsync --delete --checksum -nav "$DOWNDIR/$OLDHST/" "$PUBLISHDIR"
}

MIRROR &&\
EDITFILES &&\
PUBLISHFORUM
