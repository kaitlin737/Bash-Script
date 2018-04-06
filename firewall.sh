#!/bin/bash
#Bash wrapper script program to make iptables easier to use. Run from terminal by typing
#./firewall.sh. Also creates an html file named systemreport.html which exports existing
# firewall rules.
#Used some code from https://www.howtoforge.com/bash-script-for-configuring-iptables-firewall#the-#bash-#script-to-configure-the-firewall-using-iptables to create firewall rules.
firewall(){
echo "Are you creating input,output or forward rule?
1.INPUT
2.OUTPUT
3.FORWARD"
selection=1
read selection
case $selection in
1) chain="INPUT";;
2) chain="OUTPUT";;
3) chain="FORWARD";;
*) echo "Not an option"
	main;;
esac
clear

echo "What is the source IP?
1. Firewall with single source IP
2. Firewall with Source subnet
3. Firewall for all source Networks"
selection=1
read selection
case $selection in
1)echo "Enter IP address of the source"
read source_ip;;
2) echo "Enter the source subnet"
read source_ip;;
3) source_ip="0/0";;
*)"Not an option";;
esac
clear

echo "Destination IP address
1. Firewall with single destination
2. Firewall with destination subnet
3. Firewall for all destination Networks"
selection=1
read selection
case $selection in
1) echo "Enter ip adress of the destination"
	read destination_ip;;
2) echo "Enter destination subset"
	read destination_ip;;
3) destination_ip="0/0";;
*) "Not an option";;
esac
clear

echo "What do you want to do?
1. Block all traffic of TCP
2. Block specific TCP service
3. Block specific port
4. No protocol"
read protocol_option
case $protocol_option in
1) proto=TCP;;
2)echo "Enter TCP service name with all capitals"
read proto;;
3) echo "Enter the port name with all captitals"
read proto;;
4)proto="NULL";;
*) echo
esac
clear

echo "What to do with Rule?
1. Accept the packet
2. Reject the packet
3. Drop the packet
4. Create Log"
read rule_choice
case $rule_choice in
1) rule="ACCEPT";;
2) rule="REJECT";;
3) rule="DROP";;
4) rule="LOG";;
esac
clear

echo "Press enter to generate rule"
read temp
clear
echo "The generated rule is"
if (($proto == "NULL")); then
	echo "iptables -A $chain -s $source_ip -d $destination_ip -j $rule"
	gen=1
else
	echo "iptables -A $chain -s $source_ip -d $destination_ip -p $proto -j $rule"
	gen=2
fi
echo "Do you want to apply the rule? Type yes or no."
read answer
if ((($answer ==yes||Yes) && ($gen ==1))); then
	iptables -A $chain -s $source_ip -d $destination_ip -j $rule
else if ((($answer ==yes||Yes) && ($gen ==2))); then
	iptables -A $chain -s $source_ip -d -p $proto -j $rule
else if (($answer == no||No)); then
	main
fi
fi
fi
clear
main

}

#creates html report and opens in firefox
systemreport(){
RIGHT_NOW=$(date '+%m/%d/%Y at %H:%M:%S')
TIME_STAMP="Created by $USER on $RIGHT_NOW"
TITLE="Iptables Information"

cat << _EOF_ > systemreport.html
	<!DOCTYPE html>
	<html>
	<head>
		<title> $TITLE </title>
	</head>
	<body>
		<h1> $TITLE </h1>
		<h3>$TIME_STAMP</h3>
		<h1> Iptables </h1>
		<h2> Iptables Rules </h2>
		<pre> $(iptables -L) </pre>
	</body>
	</html>
_EOF_

open firefox systemreport.html
}

#additional options for firewall and iptables
status(){
selection=1
while (($selection != 6))
do
clear
echo "Iptables Services
1. Check current firewall status
2. Reload iptables
3. Enable Firewall
4. Disable Firewall
5. Flush iptables
6. Return to main menu
"
read selection
clear
confirm=y
case $selection in
1) ufw status
	echo "Press enter to continue..."
	read temp;;
2) ufw reload
	echo "Press enter to continue..."
	read temp;;
3) ufw enable
	echo "Press enter to continue..."
	read temp;;
4) ufw disable
	echo "Press enter to continue..."
	read temp;;
5) clear
	echo "This will delete all iptables rules. Type y/n to confirm."
	read confirm
if [[$confirm=y || Y]];then
	clear
	iptables -flush
else
	clear
	status

fi;;
6) clear
	main;;
esac
done

}

#main menu for iptables program
main(){
clear
if (($(id -u) != 0));then
	echo  "Must be root user"
	exit 0
fi
selection=1
while (($selection != 5))
clear
do
echo "Welcome to Iptables"
echo "Main Menu
1. Check Iptables version
2. Iptables services
3. Firewall options
4. Help Menu
5. Create HTMl report
6. Save iptables
7. Exit"
read selection
clear
case $selection in
1)
	iptables --version
	echo "Press enter to continue..."
	read temp;;
2) status
	echo "Press enter to continue..."
	read temp;;
3) firewall
	echo "Press enter to continue..."
	read temp;;
4) iptables -h
	echo "Press enter to continue..."
	read temp;;
5) systemreport
	echo "Press enter to continue..."
	read temp;;
6) iptables-save
	echo "Press enter to continue..."
	read temp;;
7) exit 0;;
*) echo "Not an option"
esac
done
}

main
exit 0
