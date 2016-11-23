# Notify Tacacs++ users on expiring passwords

## SCRIPT NAME: 
- tac_plus_notify_users.sh

## AUTHOR:
- Marin Nedea	

## CREATED: 
- 23-11-2016										

## DESCRIPTION:
- Script to notify tacacss users via e-mail when their password is about to expire or to notify the admins team via e-mail/ticket.

## SAMPLES: 
- Along with this script I added samples for the following files: 
    - users_list.csv 
    - tac_plus.conf

# HOW TO

## Prerequisites
- A debian Server (7.x or 8.x)
- tac_plus server installed directly from the debian repo (apt-get install tac_plus )
- an e-mail address (working one) to use as a service mail. Preferably, a ticketing system should fetch the e-mails sent to that address.
- a separate file ( csv ) containing the same usernames in tac_plus conf with corresponding e-mail addresses. You could write the e-mail address in the tac_plus.conf file itself, for each account, and with some small modifications to retrieve the e-mail address needed by the script from there.
- some (not much) Linux CLI knowledge.

## Make it work
- Copy the tac_plus_expiring_passwords.sh script on your tacacs linux server on a location of your choice.
- Modify the script according to your needs.
- Make it executable ( sudo chmod +x tac_plus_notify_users.sh )
- Test it.

## Automate it
- Open the cron config with the following command
    $ crontab -e
- Add a new entry at the end of the file, e.g.:
    10  0   *   *   * /my_path_to_file/tac_plus_notify_users.sh
    
    The above line will run the script once a day, at 10 minutes after 00:00
    
## There's a lot to do.. 
- the code needs a major revision, maybe it could be simplified.

## feel free to contribute


