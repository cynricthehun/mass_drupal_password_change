#!/bin/bash
# Mass update all Drupal Website Passwords.

# Database Connection and Query Information.
user="root"
psw="..."
drupalAdmin="..."
# database="..." ${database}
query="show databases;"

# check if mysql is running and for how long.
mysql -u root -e STATUS | grep -i uptime

# Loop and collect the databases in an array from mysql.
while read line
do
  myarray+=($line)
done < <(mysql -u${user} -p${psw} -e "${query}" -B)

# prompt the user for the password.
read -p "what would you like the new drupal password to be?" selectedPassword

# repeat the password back to the user.
echo "you have choosen, $selectedPassword"

# run the drupal hash script.
pushd /var/www/drupal/scripts
p= ./password-hash.sh $selectedPassword
popd

for databaseArray in "myarray[@]"
do
  # inform admin which database we are looking at out of the array.
  echo "checking: " $databaseArray

  # Store returned value to be evaluated.
  usernameStatus = mysql -u${user} -p${psw} -D${databaseArray} -e "select name from users where name='${drupalAdmin}';"

  # Check if specific user exist on the table
  if [ $usernameStatus != null ]
  then
    # change the specific users password to the hashed password.
    mysql -u root -Bse "USE $databaseArray; UPDATE users SET pass = $p WHERE name='sds_admin'; SELECT pass FROM users WHERE name='${drupalAdmin}';"
  else
    # inform admin that the specific database does not
    echo $databaseArray " does not have a user named " $drupalAdmin
  fi
done
