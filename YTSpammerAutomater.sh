#!/bin/bash
#Created on 29/04/2022 by Ziogref
#Last modified 18/05/2022

#Please create up to 6 projects in Google Cloud Console, 5 for YT spammer and 1 for the API key in this tool
#If you use the Same Google account for all projects, you can use the same token.pickle file, but make 5 copies of it following the required naming this script calls for.
#APIkey is needed to scan videos and do some math to break up into groups of (roughly) 10,000 api calls.
#This is to ensure ThioJoes tool does not fail to scan from not enough API calls. 
APIkey1=""

#Please set ThioJoe's YT spammer location here.
#WARNING!! due to a limitation of thioJoes script you are unable to call "python3 /path/to/program/YTSpammerPurge.py" YOU HAVE to call "python3 YTSpammerPurge.py" because of this limitation this script must be placed into YT spammer program folder.
YTSpammerLocation=$(pwd)

#Please set an API Limit, by default the Youtube API allows 10,000 API calls HOWEVER if you wish to scan more than 1 video per channel, you will need to divide 10,000 by the amount of videos set in the template. for Example for 2 videos it would be 10000/2 = 5000 or 3 videos would be 10000/3 = 3333 etc.
#If you wish to run the multiple times per day then you need to divide 10,000 by the amount of videos you want to scan divided by the amount of times you want to scan per day. e.g 2 videos, 4 times per day would be 10000/2/4 = 1250
APILimit=10000

#For the API guessing of this script to split the groups into groups. Please enter a number for the script to use. The value you enter is calculated as such
#100/7 = 14% (bash doesnt work with decimal values)
#So in this case setting a value of 7 assumes that 14% of all comments are spam. Here are some pre-calculated figures for you to pick from. Its is better to over guess spam percentage than under guess. If you under guess, you will hit your API limit sooner than calculated.
#| 1 = 100% | 2 = 50% | 3 = 33% | 4 = 25% | 5 = 20% | 6 = 16% | 7 = 14% | 8 = 12% | 9 = 11% | 10 = 10% | 11 = 9% | 12 = 8% | 13 = 7% | 15 = 6% | 20 = 5% | 25 = 4% | 33 = 3% | 50 = 2% | 100 = 1%
# Default is 10 (10%)
#Value must be a whole number. Again, this is nothing to do with removing/reporting comments, its just for a rough calculation to split into groups.
SpamPercentage=10

##########################################################################
#Checks prerequisites and creates required directories
##########################################################################

#Checks if project directory exists
ProjectDir=$(pwd)/ZiogrefSpammer
if [ -d "$ProjectDir" ]
	then
    	echo "$ProjectDir exists"
	else
		mkdir $ProjectDir
		echo "$ProjectDir has been created"
fi

#Check if temp directory exists
TempDir=$(pwd)/ZiogrefSpammer/temp
if [ -d "$TempDir" ]
	then
    	echo "$TempDir exists"
	else
		mkdir $TempDir
		echo "$TempDir has been created"
fi

#Checks and removes remove old temp files that could cause issues if the script failed to complete last run

if [ -z "$(ls -A $TempDir/)" ]
	then
   		echo "$TempDir is empty"
else
   rm $TempDir/*
	echo "$TempDir has been emptied"
fi

#Check if output directory exists
OutputDir=$(pwd)/ZiogrefSpammer/outputDir
if [ -d "$OutputDir" ]
	then
    	echo "$OutputDir exists"

		if [ -d "$OutputDir/Group1" ]
			then
				rm -r $OutputDir/Group1
		fi

		if [ -d "$OutputDir/Group2" ]
			then
				rm -r $OutputDir/Group2
		fi

		if [ -d "$OutputDir/Group3" ]
			then
				rm -r $OutputDir/Group3
		fi

		if [ -d "$OutputDir/Group4" ]
			then
				rm -r $OutputDir/Group4
		fi

		if [ -d "$OutputDir/Group5" ]
			then
				rm -r $OutputDir/Group5
		fi
 
	else
		mkdir $OutputDir
		echo "$OutputDir has been created"
fi

#Checks for project files, token.pickle x5 and client_secrets.json exist x5, if it does continue the script, if doesn't jump to end and throw error
#If this passes, the entire script will run, if it fails it will jump to the end of the script
APIProjectFiles=$(pwd)/ZiogrefSpammer/APIProjectFiles
if [ -d "$APIProjectFiles" ]
	then
		tokenpickle1=$APIProjectFiles/token.pickle1
		tokenpickle2=$APIProjectFiles/token.pickle2
		tokenpickle3=$APIProjectFiles/token.pickle3
		tokenpickle4=$APIProjectFiles/token.pickle4
		tokenpickle5=$APIProjectFiles/token.pickle5
		clientsecretsjson1=$APIProjectFiles/client_secrets.json1
		clientsecretsjson2=$APIProjectFiles/client_secrets.json2
		clientsecretsjson3=$APIProjectFiles/client_secrets.json3
		clientsecretsjson4=$APIProjectFiles/client_secrets.json4
		clientsecretsjson5=$APIProjectFiles/client_secrets.json5

		if [[ ! -f $tokenpickle1 && ! -f $tokenpickle2 && ! -f $tokenpickle3 && ! -f $tokenpickle4 && ! -f $tokenpickle5 && ! -f $clientsecretsjson1 && ! -f $clientsecretsjson2 && ! -f $clientsecretsjson3 && ! -f $clientsecretsjson4 && ! -f $clientsecretsjson5 ]]
		then

		echo "token.pickle and/or client_secrets.json files are missing. Please ensure the files are located in $APIProjectFiles"
		echo "they are to be named token.pickle1 token.pickle2 etc and client_secrets.json1 client_secrets.json2 etc"
		echo "each are to be their own project in Google cloud"
		echo "If you think you wont need more than say 1 or 2 projects you can create blank files but be warned if this script calculates than what you have allocated projects for ThioJoes program will fail to run those files"
		exit 1
	fi
	else
		mkdir $APIProjectFiles
		echo "$APIProjectFiles" created
		echo "please place token.pikle and client_secrets.json files in here named token.pickle1 token.pickle2 etc and client_secrets.json1 client_secrets.json2 etc"
		echo "each are to be their own project in Google cloud"
		echo "If you think you wont need more than say 1 or 2 projects you can create blank files but be warned if this script calculates than what you have allocated projects for ThioJoes program will fail to run those files"
		exit 1
fi
#checks if subscriptions.csv exists, if it does continue the script, if doesn't jump to end and throw error
#If this passes, the entire script will run, if it fails it will jump to the end of the script
YTsubfile=$ProjectDir/subscriptions.csv
if test ! -f "$YTsubfile"
	then
		echo "$YTsubfile not found. Please ensure it is named subscriptions.csv and is located in $ProjectDir"
		echo 'You can obtain this file from takeout.google.com. De-select all item then select "YouTube and YouTube Music" followed by "All YouTube data included, de-select all then select "subscription" this will export the file this script uses'
		exit 1
fi

#Check for template
Template=$ProjectDir/SpamPurgeConfig.ini
if test ! -f "$Template"
	then
		echo "Template ini file not found, please place template ini file in $ProjectDir called SpamPurgeConfig.ini"
		exit 1
fi

##########################################################################
#Removes special characters from Channel Title
##########################################################################

echo "Now removing special character from Channel Title"

#Sets CSV file as comma delimited
OLDIFS=$IFS
IFS=","

#Runs loop to removes special characters
while read ChannelID ChannelURL Channeltitle

    do

            #Removes Spaces from Channel URL
            if [[ $ChannelURL = *[[:space:]]* ]]
                then
                    ChannelURL=`echo $ChannelURL | sed 's/ //g'`
            fi
            
            #Removes Spaces from Channel ID
            if [[ $ChannelID = *[[:space:]]* ]]
                then
                    ChannelID=`echo $ChannelID | sed 's/ //g'`
            fi
			
			#Removes Spaces
            if [[ $Channeltitle = *[[:space:]]* ]]
                then
                    Channeltitle=`echo $Channeltitle | sed 's/ //g'`
            fi

            #Removes full stops/periods
            if [[ $Channeltitle = *.* ]]
                then
                    Channeltitle=`echo $Channeltitle | sed 's/[.]//g'`
            fi

            #Removes commas
            if [[ $Channeltitle = *,* ]]
                then
                    Channeltitle=`echo $Channeltitle | sed 's/[,]//g'`
            fi

            #Removes apostrophes
            if [[ $Channeltitle = *"'"* ]]
                then
                    #\x27 is an Apostrophe
                    Channeltitle=`echo $Channeltitle | sed 's/[\x27]//g'`
            fi

            #Removes ampersands
            if [[ $Channeltitle = *\&* ]]
                then
                    Channeltitle=`echo $Channeltitle | sed 's/[&]//g'`
            fi

            #Removes open brackets
            if [[ $Channeltitle = *\(* ]]
                then
                    Channeltitle=`echo $Channeltitle | sed 's/[(]//g'`
            fi

            #Removes closed brackets
            if [[ $Channeltitle = *\)* ]]
                then
                    Channeltitle=`echo $Channeltitle | sed 's/[)]//g'`
            fi

#Outputs results to new CSV file
echo $ChannelID,$ChannelURL,$Channeltitle >> $TempDir/subscriptionsNameCorrected.csv

#This closes "while read" loop and specifies the file that the "while read" loop us using
done < $ProjectDir/subscriptions.csv

#cleanup
IFS=$OLDIFS

echo "removed all spaces, periods, commas, apostrophes, ampersands, open and closed brackets"

##########################################################################
#Get Latest video ID
##########################################################################

echo "adding headers to temporary files"

#Add comment count header
sed -i 's/Channeltitle/Channeltitle,LatestVideoID,CommentCount,APIGuess/g' $TempDir/subscriptionsNameCorrected.csv

OLDIFS=$IFS
IFS=","

echo "Getting latest video ID for each channel"

while read ChannelID ChannelURL Channeltitle LatestVideoID CommentCount APIGuess

    do
        if [[ $LatestVideoID = LatestVideoID ]]
            then
                #Outputs headers to temp file
                echo $ChannelID,$ChannelURL,$Channeltitle,$LatestVideoID,$CommentCount,$APIGuess >> $TempDir/subscriptionsVidId.csv
            			
			else
                #Sets variable LatestVideoID to the Latest Video ID of each Youtube Channels. the first 3 lines is the contacts the Youtube/Google API to pull the value
                #After the first pipe, the jq command filters the result to just the Latest video ID
                #After the seconds pipe, the sed command removes the "" from the result, leaving a clean number for the variable

				#The playlist that contains all uploaded video is one character different from the channel. This gets the Uploads Playlist ID from the ChannelID
				PlaylistID=`echo $ChannelID | sed "s/./U/2"`
				
				#This gets the latest Video from the Uploads Playlist
				LatestVideoID=$(curl -s \
					"https://youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=1&playlistId=$PlaylistID&maxResults=1&order=date&type=video&key=$APIkey1" \
					--header 'Accept: application/json' \
					--compressed | jq '.items[0].contentDetails.videoId' | sed 's/\"//g')			
		
				#echo "$Channeltitle latest video ID is $LatestVideoID"

				#Output values to CSV
				echo $ChannelID,$ChannelURL,$Channeltitle,$LatestVideoID,$CommentCount,$APIGuess >> $TempDir/subscriptionsVidId.csv			

        fi

done < $TempDir/subscriptionsNameCorrected.csv

#cleanup
IFS=$OLDIFS

echo "All video ID's collected"

##########################################################################
#Get Comment count on Latest videos
##########################################################################

echo "Getting comment count for each video"

OLDIFS=$IFS
IFS=","

while read ChannelID ChannelURL Channeltitle LatestVideoID CommentCount APIGuess

    do
        if [[ $CommentCount = CommentCount ]]      
        then
            #Output values to CSV
            echo $ChannelID,$ChannelURL,$Channeltitle,$LatestVideoID,$CommentCount,$APIGuess >> $TempDir/subscriptionsCommentsCounted.csv        
        else
            #Sets variable CommentCount to the value of the comments. the first 3 lines is the contacts the Youtube/Google API to pull the figures
            #After the first pipe, the jq command filters the result to just the comment count
            #After the seconds pipe, the sed command removes the "" from the result, leaving a clean number for the variable
            CommentCount=$(curl -s \
            "https://youtube.googleapis.com/youtube/v3/videos?part=statistics&id=$LatestVideoID&key=$APIkey1" \
              --header 'Accept: application/json' \
              --compressed | jq '.items[0].statistics.commentCount' | sed 's/\"//g')

			#echo "$Channeltitle has $CommentCount comments"

            #Output values to CSV
            echo $ChannelID,$ChannelURL,$Channeltitle,$LatestVideoID,$CommentCount,$APIGuess >> $TempDir/subscriptionsCommentsCounted.csv
        fi

done < $TempDir/subscriptionsVidId.csv

echo "comment count values collected"

#cleanup
IFS=$OLDIFS

##########################################################################
#Calculate API quota use per video
##########################################################################

#Function to round up comment count to nearest 100

roundup100() {
    echo $(( ((${1%.*}+99)/100)*100 ))
}

##################
#end of function
##################

echo "Calculating API quota use per video"

OLDIFS=$IFS
IFS=","

while read ChannelID ChannelURL Channeltitle LatestVideoID CommentCount APIGuess

    do
         if [[ $LatestVideoID = LatestVideoID ]]
            then
                #exports headers to new CSV and not to run math on headers   
                echo $ChannelID,$ChannelURL,$Channeltitle,$LatestVideoID,$CommentCount,$APIGuess >> $TempDir/subscriptionsAPICalc.csv
            else
                #Rounds up comments to nearest 100 as thats how the API works 
                CommentCountRounded=$(roundup100 $CommentCount)
                
                #Scanning 1-5 videos uses 1 API credits
                ScanVidAPIUse=1
                
                #100 comments scanned uses 1 API credits
                CommentCountAPIUse=$(($CommentCountRounded/100))

                #Assuming ~14% comments reported as spam
                CommentRemoveAPIUse=$(($CommentCount/$SpamPercentage))

                #Adding up all api credits per video
                APIGuess=$(($ScanVidAPIUse+$CommentCountAPIUse+$CommentRemoveAPIUse))
                
                #Export results to csv
                echo $ChannelID,$ChannelURL,$Channeltitle,$LatestVideoID,$CommentCount,$APIGuess >> $TempDir/subscriptionsAPICalc.csv
        fi

done < $TempDir/subscriptionsCommentsCounted.csv

#cleanup
IFS=$OLDIFS

#Sorts Videos by largest API use to smallest API use. Later in the script this will allow better use of the amount of projects needed

APISort=$TempDir/subscriptionsAPICalc.csv
(head -n1 $APISort; tail -n+2 $APISort | sort -t, -k6 -n -r) > $TempDir/subscriptionsAPISorted.csv

##########################################################################
#Remove old ini files and create new ones
##########################################################################

echo "Deleting all ini files"
rm -r $OutputDir/*

echo "Making ini files"

OLDIFS=$IFS
IFS=","

#Sets Group API Calc to 0, as each video is added to a group it adds to expected API count to that groups counter
#Each Video will attempt to be added to a group before moving to the next group.
#For example if Video 1 fits into group 1, Video 2 does not fit into group 1 so it moves to group 2, if group 2
#does not exist it creates it. If video 3 fits into group 1 it will go in that, if not, moves to group 2 etc. This
#is becuase some video have a much lower comment cound and there for can squeeze more videos into less groups.
#Videos are sorted by expected api use, so as the lower api videos come in they can squeeze into the gaps left by
#the bigger api use videos

Group1APICalc=0
Group2APICalc=0
Group3APICalc=0
Group4APICalc=0
Group5APICalc=0
while read ChannelID ChannelURL Channeltitle LatestVideoID CommentCount APIGuess
	
	do            
		if [[ $Channeltitle != Channeltitle ]]
			then
				Group1=$OutputDir/Group1
			if [ ! -d "$Group1" ]
				then
					mkdir $Group1
					echo "$Group1 has been created"
				fi

				if [[ $(($Group1APICalc + $APIGuess)) -le $APILimit ]]
					then
						Group1APICalc=$(($Group1APICalc + $APIGuess))
						#creates group 1 ini files  
						sed "s/ChannelNameVariable/$Channeltitle/g ; s/ChannelIDVariable/$ChannelID/g" $Template > $Group1/$Channeltitle.ini
						echo $Channeltitle.ini >> $TempDir/Group1listing.csv
					else
						Group2=$OutputDir/Group2
						if [ ! -d "$Group2" ]
							then
								mkdir $Group2
								echo "$Group2 has been created"
							fi

							if [[ $(($Group2APICalc+$APIGuess)) -le $APILimit ]]
								then
									Group2APICalc=$(($Group2APICalc + $APIGuess))
									#creates group 2 ini files  
									sed "s/ChannelNameVariable/$Channeltitle/g ; s/ChannelIDVariable/$ChannelID/g" $Template > $Group2/$Channeltitle.ini
									echo $Channeltitle.ini >> $TempDir/Group2listing.csv
								else
									Group3=$OutputDir/Group3
									if [ ! -d "$Group3" ]
										then
											mkdir $Group3
											echo "$Group3 has been created"
										fi

										if [[ $(($Group3APICalc+$APIGuess)) -le $APILimit ]]
											then
												Group3APICalc=$(($Group3APICalc + $APIGuess))
												#creates group 3 ini files  
												sed "s/ChannelNameVariable/$Channeltitle/g ; s/ChannelIDVariable/$ChannelID/g" $Template > $Group3/$Channeltitle.ini
												echo $Channeltitle.ini >> $TempDir/Group3listing.csv
											else
												Group4=$OutputDir/Group4
												if [ ! -d "$Group4" ]
													then
														mkdir $Group4
														echo "$Group4 has been created"
												fi

												if [[ $(($Group4APICalc+$APIGuess)) -le $APILimit ]]
													then
														Group4APICalc=$(($Group4APICalc + $APIGuess))
														#creates group 4 ini files  
														sed "s/ChannelNameVariable/$Channeltitle/g ; s/ChannelIDVariable/$ChannelID/g" $Template > $Group4/$Channeltitle.ini
														echo $Channeltitle.ini >> $TempDir/Group4listing.csv
												else
													Group5=$OutputDir/Group5
													if [ ! -d "$Group5" ]
														then
															mkdir $Group5
															echo "$Group5 has been created"
													fi

													if [[ $(($Group5APICalc+$APIGuess)) -le $APILimit ]]
														then
															Group5APICalc=$(($Group5APICalc + $APIGuess))
															#creates group 5 ini files  
															sed "s/ChannelNameVariable/$Channeltitle/g ; s/ChannelIDVariable/$ChannelID/g" $Template > $Group5/$Channeltitle.ini
															echo $Channeltitle.ini >> $TempDir/Group5listing.csv
														else
															echo "$Channeltitle has too many estimated API calls to fit in a group. This script in its current form can only hold 5 groups of $APILimit api calls. Feel free to modify it to include more groups"

													fi
												fi
										fi
									fi
							fi
					fi
			
		
done < $TempDir/subscriptionsAPISorted.csv

#cleanup
IFS=$OLDIFS

echo "ini files created"

if [[ $Group1APICalc -gt 0 ]]
then
	echo "Group 1 API use estimate = $Group1APICalc"
fi

if [[ $Group2APICalc -gt 0 ]]
then
	echo "Group 2 API use estimate = $Group2APICalc"
fi

if [[ $Group3APICalc -gt 0 ]]
then
	echo "Group 3 API use estimate = $Group3APICalc"
fi

if [[ $Group4APICalc -gt 0 ]]
then
	echo "Group 4 API use estimate = $Group4APICalc"
fi

if [[ $Group5APICalc -gt 0 ]]
then
	echo "Group 5 API use estimate = $Group5APICalc"
fi

##########################################################################
#Run YT spammer for each group
##########################################################################

#Group 1 runs if it has channels in that groups

#Checks if Group 1 has channels by seeing if that groups api count is above 0
if [[ $Group1APICalc -gt 0 ]]
	then
		
		#Checks if token.pickle exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/token.pickle ]]
			then
				rm $YTSpammerLocation/token.pickle
		fi

		#Checks if client_secrets exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/client_secrets.json ]]
			then
				rm $YTSpammerLocation/client_secrets.json
		fi

		#Copies token.pickle and client_secrets to YT spammer
		cp $tokenpickle1 $YTSpammerLocation/token.pickle
		cp $clientsecretsjson1 $YTSpammerLocation/client_secrets.json

	OLDIFS=$IFS
	IFS=","

	#reads file lists of group 1 and copies the ini files and runs yt spammer against it
	while read ini
		do
		
		#if an existing config file exists, delete it
		if [[ -f $YTSpammerLocation/SpamPurgeConfig.ini ]]
			then
				rm $YTSpammerLocation/SpamPurgeConfig.ini
		fi
	
		#Copy each ini one at a time and runs YT spammer against it
		cp $Group1/$ini $YTSpammerLocation/SpamPurgeConfig.ini
		python3 $YTSpammerLocation/YTSpammerPurge.py

	done < $TempDir/Group1listing.csv

	#cleanup
	IFS=$OLDIFS
		
fi

#Group 2 runs if it has channels in that groups

#Checks if Group 2 has channels by seeing if that groups api count is above 0
if [[ $Group2APICalc -gt 0 ]]
	then
		
		#Checks if token.pickle exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/token.pickle ]]
			then
				rm $YTSpammerLocation/token.pickle
		fi

		#Checks if client_secrets exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/client_secrets.json ]]
			then
				rm $YTSpammerLocation/client_secrets.json
		fi

		#Copies token.pickle and client_secrets to YT spammer
		cp $tokenpickle2 $YTSpammerLocation/token.pickle
		cp $clientsecretsjson2 $YTSpammerLocation/client_secrets.json

	OLDIFS=$IFS
	IFS=","

	#reads file lists of group 2 and copies the ini files and runs yt spammer against it
	while read ini
		do
		
		#if an existing config file exists, delete it
		if [[ -f $YTSpammerLocation/SpamPurgeConfig.ini ]]
			then
				rm $YTSpammerLocation/SpamPurgeConfig.ini
		fi
	
		#Copy each ini one at a time and runs YT spammer against it
		cp $Group2/$ini $YTSpammerLocation/SpamPurgeConfig.ini
		python3 $YTSpammerLocation/YTSpammerPurge.py

	done < $TempDir/Group2listing.csv

	#cleanup
	IFS=$OLDIFS
		
fi

#Group 3 runs if it has channels in that groups

#Checks if Group 3 has channels by seeing if that groups api count is above 0
if [[ $Group3APICalc -gt 0 ]]
	then
		
		#Checks if token.pickle exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/token.pickle ]]
			then
				rm $YTSpammerLocation/token.pickle
		fi

		#Checks if client_secrets exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/client_secrets.json ]]
			then
				rm $YTSpammerLocation/client_secrets.json
		fi

		#Copies token.pickle and client_secrets to YT spammer
		cp $tokenpickle3 $YTSpammerLocation/token.pickle
		cp $clientsecretsjson3 $YTSpammerLocation/client_secrets.json

	OLDIFS=$IFS
	IFS=","

	#reads file lists of group 3 and copies the ini files and runs yt spammer against it
	while read ini
		do
		
		#if an existing config file exists, delete it
		if [[ -f $YTSpammerLocation/SpamPurgeConfig.ini ]]
			then
				rm $YTSpammerLocation/SpamPurgeConfig.ini
		fi
	
		#Copy each ini one at a time and runs YT spammer against it
		cp $Group3/$ini $YTSpammerLocation/SpamPurgeConfig.ini
		python3 $YTSpammerLocation/YTSpammerPurge.py

	done < $TempDir/Group3listing.csv

	#cleanup
	IFS=$OLDIFS
		
fi

#Group 4 runs if it has channels in that groups

#Checks if Group 4 has channels by seeing if that groups api count is above 0
if [[ $Group4APICalc -gt 0 ]]
	then
		
		#Checks if token.pickle exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/token.pickle ]]
			then
				rm $YTSpammerLocation/token.pickle
		fi

		#Checks if client_secrets exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/client_secrets.json ]]
			then
				rm $YTSpammerLocation/client_secrets.json
		fi

		#Copies token.pickle and client_secrets to YT spammer
		cp $tokenpickle4 $YTSpammerLocation/token.pickle
		cp $clientsecretsjson4 $YTSpammerLocation/client_secrets.json

	OLDIFS=$IFS
	IFS=","

	#reads file lists of group 4 and copies the ini files and runs yt spammer against it
	while read ini
		do
		
		#if an existing config file exists, delete it
		if [[ -f $YTSpammerLocation/SpamPurgeConfig.ini ]]
			then
				rm $YTSpammerLocation/SpamPurgeConfig.ini
		fi
	
		#Copy each ini one at a time and runs YT spammer against it
		cp $Group4/$ini $YTSpammerLocation/SpamPurgeConfig.ini
		python3 $YTSpammerLocation/YTSpammerPurge.py

	done < $TempDir/Group4listing.csv

	#cleanup
	IFS=$OLDIFS
		
fi

#Group 5 runs if it has channels in that groups

#Checks if Group 5 has channels by seeing if that groups api count is above 0
if [[ $Group5APICalc -gt 0 ]]
	then
		
		#Checks if token.pickle exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/token.pickle ]]
			then
				rm $YTSpammerLocation/token.pickle
		fi

		#Checks if client_secrets exists in YT Spammer and deletes it if it does
		if [[ -f $YTSpammerLocation/client_secrets.json ]]
			then
				rm $YTSpammerLocation/client_secrets.json
		fi

		#Copies token.pickle and client_secrets to YT spammer
		cp $tokenpickle5 $YTSpammerLocation/token.pickle
		cp $clientsecretsjson5 $YTSpammerLocation/client_secrets.json

	OLDIFS=$IFS
	IFS=","

	#reads file lists of group 5 and copies the ini files and runs yt spammer against it
	while read ini
		do
		
		#if an existing config file exists, delete it
		if [[ -f $YTSpammerLocation/SpamPurgeConfig.ini ]]
			then
				rm $YTSpammerLocation/SpamPurgeConfig.ini
		fi
	
		#Copy each ini one at a time and runs YT spammer against it
		cp $Group5/$ini $YTSpammerLocation/SpamPurgeConfig.ini
		python3 $YTSpammerLocation/YTSpammerPurge.py

	done < $TempDir/Group5listing.csv

	#cleanup
	IFS=$OLDIFS
		
fi

##########################################################################
#Remove old files
##########################################################################

rm $TempDir/*

##########################################################################
#Ending of script
##########################################################################

#End message
echo "Script has finished, thankyou for using ziogref's script that runs ThioJoes YT Spammer program that assists with the removal of spam on Youtube"
echo "Please remember to update your token.pickle files every week."
