#!/bin/bash

# This is variable declaration
TEMP_URL='https://www.tooplate.com/zip-templates/2135_mini_finance.zip'
TEMP_NAME='2135_mini_finance'

# System update and Package installation

apt --help > /dev/null

if [ $? -eq 0 ]
then

        # Setting Variable for Ubuntu Linux OS

        PACKAGES="apache2 wget unzip"
        SVC="apache2"


        echo "##################################"
        echo "Installing the Required Packages"
        echo "##################################"
        sudo apt update > /dev/null
        sudo apt install $PACKAGES -y > /dev/null

        # Download and Copy the template
        echo "##################################"
        echo "Download & Copy Template"
        echo "##################################"

        mkdir -p /tmp/webfiles
        cd /tmp/webfiles
        sudo wget $TEMP_URL > /dev/null
        sudo unzip $TEMP_NAME.zip > /dev/null

        sudo cp -r $TEMP_NAME/* /var/www/html/

        # Restart Apache2 Service & Remove Webfiles
        echo "##################################"
        echo "Restart & Remove Webfiles"
        echo "##################################"

        sudo systemctl reload $SVC
        cd ~
        sudo rm -rf /tmp/webfiles

else

        # Setting Variable for CentOS Linux

        PACKAGES="httpd wget unzip"
        SVC="httpd"


        echo "##################################"
        echo "Installing the Required Packages"
        echo "##################################"
        sudo yum update -y > /dev/null
        sudo yum install $PACKAGES -y > /dev/null

        # Download and Copy the template
        echo "##################################"
        echo "Download & Copy Template"
        echo "##################################"

        mkdir -p /tmp/webfiles
        cd /tmp/webfiles
        sudo wget $TEMP_URL > /dev/null
        sudo unzip $TEMP_NAME.zip > /dev/null

        sudo cp -r $TEMP_NAME/* /var/www/html/

        # Restart Apache2 Service & Remove Webfiles
        echo "##################################"
        echo "Restart & Remove Webfiles"
        echo "##################################"
        sudo systemctl enable $SVC
        sudo systemctl start $SVC
        cd ~
        sudo rm -rf /tmp/webfiles
fi