#!/bin/bash
#
#SCRIPT  : tac_plus_notify_users.sh
#AUTHOR  : Marin Nedea															
#CREATED : 09-11-2016										
#COMMENT : Script to notify tacacss users via e-mail when 
#		   their password is about to expire or to 
#		   notify the admins team via e-mail/ticket.
#SAMPLES   Along with this script I added samples for the 
#		   users_list.csv and tac_plus.conf files.
#
#LICENSE : Copyright (C) 2016 - Marin Nedea @ http://sysadmins.tech
# 
#		   This program is free software: you can redistribute it and/or modify
#		   it under the terms of the GNU General Public License as published by
#		   the Free Software Foundation, either version 3 of the License, or
#		   at your option) any later version.
#
#  		   This program is distributed in the hope that it will be useful,
#		   but WITHOUT ANY WARRANTY; without even the implied warranty of
#		   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#		   GNU General Public License for more details.
#
#		   You should have received a copy of the GNU General Public License
#		   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#location of temporary file to store the results
temp_file=/tmp/temp_file_tacacs

#grep | cut | awk in the file /etc/tacacs+/tac_plus.conf and exporting resuts to temporary file
grep -e "user\|expires"  /etc/tacacs+/tac_plus.conf | cut -d '=' -f 2 | tr -d { | tr -d \" | awk 'NR%2{printf $0":";next;}1' > $temp_file

#Getting current system date
date_current=$(date "+%Y%m%d")

while IFS='' read -r line || [[ -n "$line" ]]; do

	#define service mail
	service_mail=service@domain.com

	#getting the username
    user=$(echo $line | awk '{print $1}')

	#get the e-mail address of the users from an external CSV file
	usermail=$(grep $user /mnt/chemnitz/users_list.csv | cut -d"," -f 3)  #replace 3  with column number in the csv file

	#getting the expire date coresponding to the user
    date_expire=$(echo $line | awk -F: '{print $2}' | xargs)

    #converting the date in the same format as $date_current
	date_converted=$(date -d"$date_expire" +"%Y%m%d")

	#calculating the difference between the 2 dates
	date_diff=$(echo "scale=0; ( `date -d $date_converted +%s` - `date -d $date_current +%s`) / (24*3600)" | bc -l)

	#checking if result is < 14 days
       if  [[ $date_diff -eq 14 || $date_diff -eq 7 || $date_diff -eq 3 ]]

 			then
				if [[ -z $usermail ]]  #if $usermail has no value 
					then

					#Sending the e-mail to the service mail 
					echo -e "Hello Admins,\\n\\n The following Tacacs++ Account Password will expire in $days_remain days:\\n\\n -account: $user\\n\\n -expiration date: $date_expire\\n\\nPlease take the necessary measures. This is an automated message!\\n\\nThe TACACS server" | /usr/bin/mail -u "service mail" -a "FROM: noreply@domain.com" -s "The Tacacs++ Account Password for $user is about to expire" "$service_mail"

					else 
					#Sending the e-mail to the user 
					echo -e "Hi,\\n\\n Your Tacacs++ Account Password will expire in $days_remain days and it will be disabled:\\n\\n -account: $user\\n\\nIf the account is still needed, a revalidation approval from your Project Manager is needed.\\n\\nPlease reply to $service_mail, with the approval attached, within $days_remain days.\\n\\nThank you, \\nThe Support Team" | /usr/bin/mail -u "service mail" -a "FROM: noreply@domain.com" -s "Your Tacacs++ Account Password is about to expire"  "$usermail"
       				fi
			#if password expired already
			elif [[ $date_diff -lt 0 || $date_diff -eq 0 ]]
				then
					
					#sending the e-mail to the service mail
					echo  -e "Hello Admins,\\n\\nThe following Tacacs++ Account Password expired:\\n\\n -account: $user\\n\\n -expiration date: $date_expire\\n\\nPlease notify his Team Leader/Project Manager and check if the account needs to be renewed.\\n\\nPlease DO NOT REPLY to this e-mail. This is an automated message!\\n\\nBest regards, \\nThe TACACS server" | /usr/bin/mail -u "service mail" -a "FROM: noreply@domain.com" -s "The Tacacs++ Account Password for $user is expired" "$service_mail"
				fi
			else
			
			  #do nothing
			  echo "" > /dev/null
			fi
#END of the while loop

done < "$temp_file"

#deleting the temporary file
rm -rf $temp_file
