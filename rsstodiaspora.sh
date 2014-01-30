#!/bin/bash
# Shell script for automated posting from rss feeds into Diaspora
# Author hanuman 			http://ablog.gratun.am
# Githab 				https://github.com/hanumanum/RSS-To-Diaspora
# Required:1 clispora 			http://freeshell.de/~mk/projects/cliaspora.html
# Required:2 xmlstarlet 		http://xmlstar.sourceforge.net/

#HOW TO USE

#STEP 0։ Install clispora and xmlstarlet before use this script    
#STEP 1։ Create session as it described in cliaspora manual
#STEP 2։ Replace rsslist file content with your rss list
#STEP 3։ Run this script from console
#STEP 4։ Enjoy :Ճ

HANCLTEMP=/tmp/han_cl_tmp

rssArray=($(< rsslist))
postedArray=($(< posted))


for rsss in "${rssArray[@]}"
{
	wget ${rsss} -O - 2>/dev/null | xmlstarlet sel -t -m "/rss/channel/item" -v "guid" -n -v "title" -n -v "category" -n >> $HANCLTEMP
}


cat $HANCLTEMP |  while read LINE
do

       #echo "$LINE"
       http="${LINE:0:4}"

       if [ "$http" == "http" ]; then
       	linenumber=1
       	url=$LINE;
       fi
       	
       if [ $linenumber == 2 ]; then
       	title=$LINE;
       fi

       if [ $linenumber -ne 2 ] && [ $linenumber -ne 1 ] && [ $linenumber -ne 0 ] && [ "$LINE" != "" ]; then
       	 tags="$tags #$LINE"
       fi
       
       linenumber=`expr $linenumber + 1`	
       
       if [ "$http" == "" ] && [ "$url" != "" ]; then
       	
       	isnew=1
       	
       	for link in "${postedArray[@]}"
			{
			 if [ "$link" == "$url" ]; then
				isnew=0
					
			 fi 		
			}

		if [ $isnew -eq 1 ]; then
       		poststring="$title <br> $url <br> $tags"
       		echo $poststring > /tmp/han_clias_post 
        	cliaspora post public < /tmp/han_clias_post
        	echo "Posting $title"
			echo "$url">> posted
		fi

       	tags=""
       	url=""
       	title=""
       	poststring=""
       	let linenumber=0
       fi
       
done

rm $HANCLTEMP
