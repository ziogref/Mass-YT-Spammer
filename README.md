# Ziogref's YT spammer automater for Thio Joe's YT Spammer Purge tool

So just to start, this is my first bash script and first github project.

So this tool is for my personal use to run Thio Joes YT Spammer Purge over all the people I subscribe too, however I have written it in a way that should work on any linux system. 

I have tested it on Ubuntu Server 22.04 LTS and Linux Mint 20.3

So, this  tool will allow you takes an input file, template, and Oauth tokens and automatically pass the info through to Thio Joe's YT spammer Purge application automatically with 0 input from you besides updating token.pickle once a week.

## How to install

(Note, this script requires jq to be installed as it parses the results from the Youtube API. to install it on a debian/ubuntu run

sudo apt install jq

Accept and install)

If you want to run this 99% hands free here is what you need to do. (This is the way I found out hwo to make it work, there may be another way thats less....yucky, but I havent found that)

1. Download [Thio Joe's YT Spammer Purge tool](https://github.com/ThioJoe/YT-Spammer-Purge/wiki/Linux-Installation-Instructions) and install it.
2. The install will create a directory with all the files, Move them to the root of your home directory. (You dont need to do this if you plan on running my script manually)
3. Download YTSpammerAutomater.sh and place it in root of your home directory (the same location as YTSpammerPurge.py from Thio Joes application) If you plan on manually running this, you just need to place the script in the install directory of YT-Spammer-Purge
4. Make the script executable with chmod +x ./YTSpammerAutomater.sh
5. Run ./YTSpammerAutomater.sh from the terminal, This will create some required folders for the script to run, this script will "fail" and give instructions on why it failed. you can ignore these for now
6. Place your SpamPurgeConfig.ini template file in ZiogrefSpammer folder. You can use my template provided here in the repo, but you will need to confirm the some lines (The following information is based on config_version = 31 of Thio's config file, which up to date as of Version 2.16.9 of YT-Spammer-Purge (I will list the changes required further down)
7. Head to takeout.google.com and we are going to export the creators you are subscribed to. My script was built around this file, as it contains important information. 
* Deslected all" Products.
* Scroll down to the bottom and select "Youtube and Youtube Music"
* Select "All Youtube data included" and deselect everything except subscriptions. 
* click "Next Step" Leave everything as default and click "Create Export"
* Download the exported data. This file is a zip file
* extract the file "subscriptions.csv" which is located in /Takeout/YouTube and YouTube Music/subscriptions/ within the zip file. Place this file in ZiogrefSpammer. This is the file my script will run through. Do not change the name. If you wish to remove creators (to save API credits) you can remove those lines from the script. Make sure there is no blank spaces in the file.

8. Follow [Thio Joes instructions](https://github.com/ThioJoe/YT-Spammer-Purge/wiki/Instructions:-Obtaining-an-API-Key) to create upto 5 projects for the script to use. This will give you 50,000 api calls instead of 10,000.
* Name each client_secrets.json as client_secrets.json1, client_secrets.json2, client_secrets.json3 etc and place them in "APIProjectFiles"
9. Create an 1 more aditional project the same way BUT wil will need an API key. So on the last project Project 6, go to "API's and services" --> "Credentials" then up the top click "+ CREATE CREDENTIALS" and create an API key.
10. Edit YTSpammerAutomater.sh, pay attention to 
* Line 9, this is for your API key
* Line 17, API Limit, adjust this accordingly to the comments
* Line 25, Spam Percentage, adjust this accordingly to the comment

11. One at a time, place each client_secrets.json into YT-Spammer-Purge folder and run YTSpammerPurge.py manually. This will open up a web-browser to authenticate. Once you authenticate a file called token.pickle is created. You can close the YT spammer, no need to run it further. you will need to match the token.pickle to each client_secrets.json. so client_secrets.json1 MUST have the matching token.pickle named token.pickle1. Repeat the steps for each client_secrets.json and get the matching token.pickle to all be placed into the "APIProjectFiles" folder in "ZiogrefSpammer"

12. Assuming you have adjusted the ini Template (instructions below) you can now run the script manually. If you wish to automate it, keep following
13. Open Terminal and type 
 
crontab -e

from here add the following line

0 0 * * *  /home/(YourUserNameHere)/YTSpammerAutomater.sh

then save and exit the file (assuming you are using nano) with CTRL+o, enter, CTRL+x
This cron will run the YTSpammerAutomater.sh at midnight (of you machine time) if you wish to change it, the first 0 is the minute the second 0 is the hour

so 15 7 * * * will be 7.15am

## ini Template adjustments
If you are using my template, you will only need to edit line 51. See below what line 51 should be.
* Line 31 | use_this_config = True
* line 37 | this_config_description = ChannelNameVariable
* Line 51 | your_channel_id = (Your Channel ID)
You can find you channel ID by going to https://studio.youtube.com/ the look at the URL, it will change to https://studio.youtube.com/channel/(YourChannelID)
* Line 57 | auto_check_update = False
* Line 67 | skip_confirm_video = True
* Line 77 | auto_close = True
* Line 89 | scan_mode = RecentVideos
* Line 102 | channel_to_scan = ChannelIDVariable
* Line 107 | recent_videos_amount = 1 
Line 107 can be changed, but please pay attention to Line 15 in YTSpammerAutomater.sh
* Line 114 | filter_mode = AutoSmart
* Line 224 | delete_without_reviewing = True
* Line 244 | removal_type = reportSpam

Note: Im currently on some medication so my mental capacity is, well, reduced. Im mentally exhausted after work. So if you leave comments or request help or anything else that requires my response I may not be able to fix it or provide advice many days until end of the month.
