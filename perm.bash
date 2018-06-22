#!/bin/bash
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

# Date : 31/03/2018
# Author : Leegin Bernads T.S

#Use this script only if the PHP handlers in the server are suphp or Fcgi. 
#Do not runon any other servers. 
#Also highly recommended to take full server backup before executing the script.

#The help page for the script
helpline() 
{
echo "Help menu for the fixperms script:"
echo "USAGE : fixperms [options]"
echo "============="
echo "options:"
echo "-h or --help : Print this screen & exit"
echo "-v: verbose"
echo "-all: run on all the cPanel accounts"
echo "-a or--account : run only for a specific cPanel account"
exit 0
}

#The main script for correcting the permission and ownership of the cPanel account.
fixperms()
{
user=$1

#check whether the account is a valid account
if [[! grep $user /var/cpanel/users/*]]
then
echo "Invalid cPanel account : No such account exists!"
exit 0
fi

#Confirm the account section is not left empty

if [[-z $user]]
then
echo " Account empty! An account name should be specified"
helpline
else
echo "Fixing the permission and ownership for $account"
echo "Correcting the permission of the files and folders....."

#Fixing the permission of folders
find /home/$user/public_html -type d -exec chmod 755 {} \:

#Fixing the permission of files
find /home/$user/public_html -type f -exec chmod 644 {} \;

#Fixing the permission of the public_html folder
chmod 750 /home/$user/public_html

#Fixing the permission for perl and cgi scripts
find /home/$user/public_html -iname '*.pl' -o -iname '*.cgi' -exec chmod 755 {} \: 

#Fixing the ownership for the account
chown -R $user. /home/$user/

#Fixing the ownership of public_html
chown $user:nobody /home/$user/public_html

#Fixing the permission of the mail folder 
/scripts/mailperm  $user

echo " Finished!!!!!"
exit 0
fi

#For all the accounts in cpanel/users/*
all()
{
for account in $(cat /etc/userdatadomains | awk '{print $2}'| cut -d"=" -f1)
do
fixperms $account
done
}

#Options passed along with fixperms

case "$1" in

-h)
helpline
;;
--help)
helpline
;;

-v)
verbose="-v"
;;

case "$2" in 

--all)
all
;;

-a)
fixperms $3
;;
--account)
fixperms $3
;;

*)
echo " OOps! Invalid option"
helpline
;;
esac
;;

--all)
all
;;

-a)
fixperms $2
;;
--account)
fixperms $2
;;

*)
echo " OOps! Invalid option"
helpline
;;
esac
}