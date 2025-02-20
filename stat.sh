#!/bin/bash

                                #VERSI ZERGPOOL

#==========================================================================#
           # G A N T I - D E N G A N - M I L I K - K A L I A N #           #
coin=DOGE                                            #Coin                 #
Wallet=D8iuMPrKfSFGPyHSpqhEen4jWMp8mcipxe            #walletaddress        #
TOKEN=2105826072:AAH2ULLlIXsVxWdHP8p7VqjRVMmc7hIGXE8 #ChannelToken         #
CHAT_ID=(306773502)                                  #ID UserTelegram      #
miner=14                                             #jumlah Miner kalian  #
#==========================================================================#



g='\e[1;32m'
r="tput sgr0"

echo -e "${g} ███╗░░██╗░██████╗░░█████╗░░██████╗░██████╗░██╗░░░██╗░██████╗  ██████╗░░█████╗░████████╗ "; $r
echo -e "${g} ████╗░██║██╔════╝░██╔══██╗██╔════╝██╔═══██╗██║░░░██║██╔════╝  ██╔══██╗██╔══██╗╚══██╔══╝ "; $r
echo -e "${g} ██╔██╗██║██║░░██╗░███████║╚█████╗░██║██╗██║██║░░░██║╚█████╗░  ██████╦╝██║░░██║░░░██║░░░ "; $r
echo -e "${g} ██║╚████║██║░░╚██╗██╔══██║░╚═══██╗╚██████╔╝██║░░░██║░╚═══██╗  ██╔══██╗██║░░██║░░░██║░░░ "; $r
echo -e "${g} ██║░╚███║╚██████╔╝██║░░██║██████╔╝░╚═██╔═╝░╚██████╔╝██████╔╝  ██████╦╝╚█████╔╝░░░██║░░░ "; $r
echo -e "${g} ╚═╝░░╚══╝░╚═════╝░╚═╝░░╚═╝╚═════╝░░░░╚═╝░░░░╚═════╝░╚═════╝░  ╚═════╝░░╚════╝░░░░╚═╝░░░ "; $r

MSG_FILE="ngasqus.msg"
JSON_FILE="ngasqus.json"
khs=0
mhs=0
DATE=$(date +"%d-%m-%Y %H:%M:%S")
WEB="http://api.zergpool.com:8080/api/walletEx?address=$Wallet"

loop=0

while [ $loop = 0 ]

do


#=============json init================================#
echo -e "${g}Json initialization"; $r
json_init=$(curl -s "$WEB" | jq -r '.')
echo -e "$json_init" > $JSON_FILE
echo -e "${g}===================="; $r


#==============wrapp====================================#
unsold=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"unsold": ')
balance=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"balance": ')
unpaid=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"unpaid": ')
paid24h=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"paid24h": ')
minpay=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"minpay": ')
minpay_sunday=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"minpay_sunday":')
total=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"total": ')
eimi=$(cat "$JSON_FILE" | jq -r ' .miners[] | "ID: " + (.ID + " | Hashrate: " + .hashrate)')

count=$(cat "$JSON_FILE" | jq -r '.miners | length')

#total
cat "$JSON_FILE" | jq -r '[ .miners[] | select(.hashrate | contains(" Mh/s") ) ]' >> mhs.json
mhs=$(cat "mhs.json" | jq -r '[.[].hashrate | gsub("Mh/s";"") | tonumber] | add')

cat "$JSON_FILE" | jq -r '[ .miners[] | select(.hashrate | contains(" kh/s") ) ]' >> khs.json
khs=$(cat "khs.json" | jq -r '[.[].hashrate | gsub("kh/s";"") | tonumber] | add | floor/1000')


if [ $khs<=0 ]
�������� then
��������    hstot=$mhs
 ��������else
    ��������hstot=$(echo "$mhs + $khs" | bc )
 fi

#================CHECK===================================#

if [ -z "$total" ]
then
    #fail
          sudo find khs.json -delete
          sudo find mhs.json -delete
          sudo find ngasqus.json -delete
          sudo find ngasqus.msg -delete

    echo -e "${g}FAIL Connection Problem.. try again"; $r

else
    #send tele
    loop=1
#==================PRINT==================================#

echo -e "${g}Sending report.."; $r
echo -e "Wallet Monitoring~ \nCurrency\t: $coin" > $MSG_FILE
echo -e "Date : " $DATE"\n" >> $MSG_FILE
echo -e "${g}Generate report.."; $r
echo -e "Immature\t: "$unsold $coin >> $MSG_FILE
echo -e "Balance\t\t: "$balance $coin >> $MSG_FILE
echo -e "Unpaid\t\t: "$unpaid $coin >> $MSG_FILE
echo -e "Paid 24 Hours\t: "$paid24h $coin >> $MSG_FILE
echo -e "Paid/4jam\t: "$minpay $coin>> $MSG_FILE
echo -e "Sunday\t\t: "$minpay_sunday $coin>> $MSG_FILE
echo -e "Total\t\t: "$total $coin >> $MSG_FILE
echo -e "Accepted\t: "$eimi >> $MSG_FILE
sed -i "s/ID: /\n\t\tID: /g" $MSG_FILE
echo -e "Total Online\t: "$count" / "$miner" Miners" >> $MSG_FILE
echo -e "Hashrate Total\t: "$hstot " Mh/s" >> $MSG_FILE
echo -e "${g}===================="; $r
    MESSAGE=`cat $MSG_FILE`
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    for ID in "${CHAT_ID[@]}"
    do
        curl -X POST -so /dev/null $URL -d chat_id=$ID -d text="$MESSAGE";
        echo -e "${g}===================="; $r
        echo -e "${g}SUCCESS.. DONE."; $r

        sudo find khs.json -delete
        sudo find mhs.json -delete
        sudo find ngasqus.json -delete
        sudo find ngasqus.msg -delete
    done
fi
done
