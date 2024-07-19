#!/bin/bash

getent passwd
cat /etc/group
groupdel Administracio
groupdel Disseny
groupdel Raspberry
groupdel Marqueting
cat /etc/group
userdel -r JoanJosepLA
userdel -r AnnaGS
userdel -r MariaPG
userdel -r DanielSR
getent passwd
rm -r /home/empresa/
groupdel JoanJosepLA
groupdel AnnaGS
groupdel MariaPG
groupdel DanielSR
groupdel Administracio
groupdel Disseny
groupdel Raspberry
groupdel Marqueting