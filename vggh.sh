#!/bin/bash

#source ~/.bashacker

#color

red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'
magenta='\e[1;35m%s\e[0m\n'
cyan='\e[1;36m%s\e[0m\n'

##################################################################
clear

: '
echo "For amass intel normal scan enter 1A"
echo "For amass asn scan enter 2A"
echo "For amass intel org normal scan enter 3A"
echo "For amass intel combined scan enter 4A"
echo "For amass enum passive scan enter 5A"
echo "For amass enum active scan enter 1A"
'

#dir setup
#read -p  "Enter the company name: " cm
mkdir /app/$2
cd /app/$2
#read -p "Enter the root Domain: " dm
clear
apt-get install eyewitness
apt-get install jq
apt-get install whois
#usage
#echo "amass enum -passive -d doamin -src
#amass intel -org 'Example Ltd
#amass intel -active -asn 222222 -ip
#amass intel -d owasp.org -whois
#amass intel -active -cidr 1.1.1.1
#amass intel -asn 11111 -whois -d doamin.com
#amass enum -d example.com -active -cidr 1.2.3.4/24,4.3.2.1/24 -asn 12345
#amass enum -brute -active -d domain.com -o amass-output.txt"

#read -p "Enter the amass cmd " AO
clear
#################################################################

# Amass
printf "$green"   "...amass started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

/app/binaries/amass enum -passive -norecursive -nolocaldb -noalts -d $1 -o /app/$2/amass.txt
#cat /app/$2/amass.txt >> /app/$2/all.txt

#/app/binaries/amass enum -brute -active -d $1 -o /app/$2/amass-enum.txt
echo -e "\e[36mAmaas count: \e[32m$(cat /app/$2/amass.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | wc -l)\e[0m"
python3 /app/p.py --type hi --path /app/$2/amass.txt --caption normal-amass 
python3 /app/p.py --type hi --path /app/$2/amass-enum.txt --caption amass-enum 

#################################################################

# CERTIFICATE ENUMERATION
printf "$green"   "...CERTIFICATE ENUMERATION started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

registrant=$(whois $1 | grep "Registrant Organization" | cut -d ":" -f2 | xargs| sed 's/,/%2C/g' | sed 's/ /+/g'| egrep -v '(*Whois*|*whois*|*WHOIS*|*domains*|*DOMAINS*|*Domains*|*domain*|*DOMAIN*|*Domain*|*proxy*|*Proxy*|*PROXY*|*PRIVACY*|*privacy*|*Privacy*|*REDACTED*|*redacted*|*Redacted*|*DNStination*|*WhoisGuard*|*Protected*|*protected*|*PROTECTED*)')
if [ -z "$registrant" ]
then
        curl -s "https://crt.sh/?q="$1"&output=json" | jq -r ".[].name_value" | sed 's/*.//g' | /app/binaries/anew >> /app/$2/whois.txt
else
	curl -sk "https://crt.sh/?O=$registrant&output=json" | tr ',' '\n' | awk -F'"' '/common_name/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' |sort -u |/app/binaries/anew >> /app/$2/whois.txt
        curl -s "https://crt.sh/?q=$registrant" | grep -P -i '<TD>([a-zA-Z]+(\.[a-zA-Z]+)+)</TD>' | sed -e 's/^[ \t]*//' | cut -d ">" -f2 | cut -d "<" -f1 | /app/binaries/anew >> /app/$2/whois.txt
        curl -s "https://crt.sh/?q=$1&output=json" | jq -r ".[].name_value" | sed 's/*.//g' | /app/binaries/anew >> /app/$2/whois.txt
fi

registrant2=$(whois $1 | grep "Registrant Organisation" | cut -d ":" -f2 | xargs| sed 's/,/%2C/g' | sed 's/ /+/g'| egrep -v '(*Whois*|*whois*|*WHOIS*|*domains*|*DOMAINS*|*Domains*|*domain*|*DOMAIN*|*Domain*|*proxy*|*Proxy*|*PROXY*|*PRIVACY*|*privacy*|*Privacy*|*REDACTED*|*redacted*|*Redacted*|*DNStination*|*WhoisGuard*|*Protected*|*protected*|*PROTECTED*)')
if [ -z "$registrant2" ]
then
        curl -s "https://crt.sh/?q="$1"&output=json" | jq -r ".[].name_value" | sed 's/*.//g' | /app/binaries/anew >> /app/$2/whois.txt
else
        curl -s "https://crt.sh/?q="$registrant2"" | grep -a -P -i '<TD>([a-zA-Z]+(\.[a-zA-Z]+)+)</TD>' | sed -e 's/^[ \t]*//' | cut -d ">" -f2 | cut -d "<" -f1 | /app/binaries/anew >> /app/$2/whois.txt
        curl -s "https://crt.sh/?q="$1"&output=json" | jq -r ".[].name_value" | sed 's/*.//g' | /app/binaries/anew >> /app/$2/whois.txt
fi
#cat /app/$2/whois.txt|/app/binaries/anew|grep -v " "|grep -v "@" | grep "\." >> /app/$2/all.txt
echo -e "\e[36mCertificate search count: \e[32m$(cat /app/$2/whois.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v " "|grep -v "@" | grep "\." | wc -l)\e[0m"
python3 /app/p.py --type hi --path /app/$2/whois.txt --caption whois.txt 

#################################################################

# DNSCAN ENUMERATION
printf "$green"   "...DNSCAN ENUMERATION started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

python3 /app/tools/frogy-main/dnscan/dnscan.py -d %%.$1 -w /app/tools/frogy-main/wordlist/subdomains-top1million-5000.txt -D -o /app/$2/dnstemp.txtls &> /dev/null
cat /app/$2/dnstemp.txtls | grep $1 | egrep -iv ".(DMARC|spf|=|[*])" | cut -d " " -f1 | /app/binaries/anew | sort -u | grep -v " "|grep -v "@" | grep "\." >>  /app/$2/dnscan.txt
#rm /app/$2/dnstemp.txt
echo -e "\e[36mDnscan: \e[32m$(cat /app/$2/dnscan.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v " "|grep -v "@" | grep "\." | wc -l)\e[0m"
python3 /app/p.py --type hi --path /app/$2/dnscan.txt --caption dnscan.txt 

#################################################################

# assetfinder
printf "$green"   "...assetfinder started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

/app/binaries/assetfinder --subs-only $1 >> /app/$2/assetfinder.txt
python3 /app/p.py --type hi --path /app/$2/assetfinder.txt --caption assetfinder.txt 

##################################################################

#finddomain
sleep 1
printf "$green"   "...findomain started..."
printf "$cyan"    "...Domain = $1..."
echo ""

/app/binaries/findomain-linux -t $1 >> /app/$2/findomain.txt
#cat /app/$2/findomain.txt|/app/binaries/anew|grep -v " "|grep -v "@" | grep "\." >> /app/$2/all.txt
echo -e "\e[36mFindomain count: \e[32m$(cat /app/$2/findomain.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew |grep -v " "|grep -v "@" | grep "\."| wc -l)\e[0m"
python3 /app/p.py --type hi --path /app/$2/findomain.txt --caption findomain.txt 

##################################################################

#sublist3r
sleep 1
printf "$green"   "...sublist3r started..."
printf "$cyan"    "...Domain = $1..."
echo ""

python /app/tools/sublist3r/sublist3r.py -d $1 -no /app/$2/sublister.txtls
if [ -f "sublister.txtls" ]; then
        cat sublister_output.txt|/app/binaries/anew|grep -v " "|grep -v "@" | grep "\." >> /app/$2/sublister.txt
        #rm sublister_output.txt
	#cat /app/$2/sublister.txt|/app/binaries/anew|grep -v " "|grep -v "@" | grep "\." >> /app/$2/all.txt
	echo -e "\e[36mSublister count: \e[32m$(cat /app/$2/sublister.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | wc -l)\e[0m"
else
        echo -e "\e[36mSublister count: \e[32m0\e[0m"
fi
python3 /app/p.py --type hi --path /app/$2/sublister.txtls --caption sublister.txtls 
python3 /app/p.py --type hi --path /app/$2/sublister.txt --caption sublister.txt 

##################################################################

#subfinder
echo ""
sleep 1
printf "$green"   "...subfinder started..."
printf "$cyan"    "...Domain = $1..."
echo ""

/app/binaries/subfinder -d $1 -o /app/$2/subfinder.txt
echo -e "\e[36mSubfinder count: \e[32m$(cat /app/$2/subfinder.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v " "|grep -v "@" | grep "\."  | wc -l)\e[0m"
#cat /app/$2/subfinder2.txt | grep "/" | cut -d "/" -f3 | grep -v " "|grep -v "@" | grep "\." >> /app/$2/all.txt
#cat /app/$2/subfinder2.txt | grep -v "/" | grep -v " "|grep -v "@" | grep "\."  >> /app/$2/all.txt
python3 /app/p.py --type hi --path /app/$2/subfinder.txt --caption subfinder.txt 

##################################################################

#git-search
sleep 1
echo ""
printf "$green"   "...github recon started..."
printf "$cyan"    "...Domain = $1..."
echo ""

python /app/tools/github-search/github-subdomains.py -t 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 -d $1 | tee /app/$2/subfinder.txt
python3 /app/p.py --type hi --path /app/$2/subfinder.txt --caption subfinder.txt 

##################################################################

#subbrute 
sleep 1
echo ""
printf "$green"   "...subbrute started..."
printf "$cyan"    "...Domain = $1..."
echo ""

python3 /app/tools/subbrute/subbrute.py $1 -o /app/$2/subrute.txt
python3 /app/p.py --type hi --path /app/$2/subrute.txt --caption subrute.txt 

##################################################################
#################################################################
#/app/binaries/anew
printf "$green"   ".../app/binaries/anew..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

# short all domains into one
echo ""
printf "$yellow"  "removing duplicates"
cat /app/$2/*.txt | grep "/" | cut -d "/" -f3 | grep -v " "|grep -v "@" | grep "\." >> /app/$2/old_output.txt
cat /app/$2/*.txt | grep -v "/" | grep -v " "|grep -v "@" | grep "\."  >> /app/$2/old_output.txt
cat /app/$2/old_output.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v "*." | grep -v " "|grep -v "@" | grep "\." >> /app/$2/$2.master
python3 /app/p.py --type hi --path /app/$2/old_output.txt --caption old_output.txt 

#################################################################

# GATHERING ROOT DOMAINS
printf "$green"   "...GATHERING ROOT DOMAINS started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

python3 /app/tools/frogy-main/rootdomain.py | cut -d " " -f7 | tr '[:upper:]' '[:lower:]' | /app/binaries/anew | sed '/^$/d' | grep -v " "|grep -v "@" | grep "\." >> /app/$2/rootdomain.txt
cat /app/$2/rootdomain.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v "*." | grep -v " "|grep -v "@" | grep "\." >> /app/$2/$2.master
echo -e "\e[36mRootDomains Count: \e[32m$(cat /app/$2/rootdomain.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | wc -l)\e[0m"
python3 /app/p.py --type hi --path /app/$2/rootdomain.txt --caption rootdomain.txt 

##################################################################

#SUBDOMAIN RESOLVER
printf "$green"   "dnsgen"

while read d || [[ -n $d ]]; do
  ip=$(dig +short $d|grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"|head -1)
  if [ -n "$ip" ]; then
    echo "$d,$ip" >>/app/$2/resolved.txtls
  else
    echo "$d,Can't Resolve" >>/app/$2/resolved.txtls
  fi
done </app/$2/$2.master
sort /app/$2/resolved.txtls | uniq > /app/$2/resolved.txt
cat /app/$2/resolved.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v "*." | grep -v " "|grep -v "@" | grep "\." >> /app/$2/$2.master
#mv /app/$2/resolved.new /app/$2/resolved.txt
python3 /app/p.py --type hi --path /app/$2/resolved.txt --caption resolved.txt 

##################################################################

#dnsgen
printf "$green"   "dnsgen"

cat /app/$2/old_output.txt | dnsgen - > /app/$2/dnsgen-https.txt
cat /app/$2/dnsgen-https.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v "*." | grep -v " "|grep -v "@" | grep "\." >> /app/$2/$2.master
python3 /app/p.py --type hi --path /app/$2/dnsgen-https.txt --caption dnsgen-https.txt 


##################################################################

#FINDING LOGIN PORTALS

portlst=`/app/binaries/naabu -l /app/$2/$2.master -pf ports -silent | cut -d ":" -f2 | /app/binaries/anew | tr "\n" "," | sed 's/.$//'` &> /dev/null

/app/binaries/httpx -silent -l /app/$2/$2.master -p $portlst -fr -include-chain -store-chain -sc -tech-detect -server -title -cdn -cname -probe -srd /app/$2/aw_http_responses/ -o /app/$2/temp_live.txt &> /dev/null

cat /app/$2/temp_live.txt | grep SUCCESS | cut -d "[" -f1 >> /app/$2/livesites.txt
python3 /app/p.py --type hi --path /app/$2/livesites.txt --caption livesites.txt 

cat /app/$2/temp_live.txt | grep SUCCESS >> /app/$2/technology.txt
python3 /app/p.py --type hi --path /app/$2/technology.txt --caption technology.txt 

#rm -f output/$cdir/temp_live.txtls

while read lf; do
        loginfound=`curl -s -L $lf | grep 'type="password"'`
        if [ -z "$loginfound" ]
                then
                :
        else
                echo "$lf" >> /app/$2/loginfound.txtls
        fi

done </app/$2/livesites.txtls
python3 /app/p.py --type hi --path /app/$2/loginfound.txtls --caption loginfound.txtls 


echo -e "\e[93mTotal live websites (on all available ports) found: \e[32m$(cat /app/$2/livesites.txtls | tr '[:upper:]' '[:lower:]' | anew | wc -l)\e[0m"

if [[ -f "output/$cdir/loginfound.txtls" ]]
	then
		echo -e "\e[93mTotal login portals found: \e[32m$(cat /app/$2/loginfound.txtls | tr '[:upper:]' '[:lower:]' | anew| wc -l)\e[0m"
	else
		echo -e "\e[93mTotal login portals found: \e[32m0\e[0m"
fi

echo -e "\e[36mFinal output has been generated in the output/$cdir/ folder: \e[32moutput.csv\e[0m"

cat /app/$2/resolved.txt | cut -d ',' -f1 >> temp1.txt
cat /app/$2/resolved.txt | cut -d ',' -f2 >> temp2.txt
#python3 /app/p.py --type hi --path /app/$2/temp1.txt --caption bufferover.txt 
#python3 /app/p.py --type hi --path /app/$2/bufferover.txt --caption bufferover.txt 

if [ -f /app/$2/loginfound.txt ]; then
	paste -d ','  /app/$2/rootdomain.txt temp1.txt temp2.txt /app/$2/livesites.txt /app/$2/loginfound.txt | sed '1 i \Root Domain,Subdomain,IP Address,Live Website,Login Portals' > /app/$2/output.csv

else
	paste -d ','  /app/$2/rootdomain.txt temp1.txt temp2.txt /app/$2/livesites.txt | sed '1 i \Root Domain,Subdomain,IP Address,Live Website' > /app/$2/output.csv
fi
#rm temp1.txt temp2.txt
python3 /app/p.py --type hi --path /app/$2/output.csv --caption output.csv 

##################################################################

#RELATIONSHIP
printf "$green"   "...RELATIONSHIP started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

echo $2 | python3 /app/tools/getrelationship.py >> /app/$2/relationship.txt
cat /app/$2/relationship.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v "*." | grep -v " "|grep -v "@" | grep "\." >> /app/$2/$2.master
python3 /app/p.py --type hi --path /app/$2/relationship.txt --caption relationship.txt 

##################################################################

#SubDomainizer
printf "$green"   "...SubDomainizer started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

python3 /app/tools/SubDomainizer.py -d $2 -o /app/$2/SubDomainizer.txt
cat /app/$2/SubDomainizer.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v "*." | grep -v " "|grep -v "@" | grep "\." >> /app/$2/$2.master
python3 /app/p.py --type hi --path /app/$2/SubDomainizer.txt --caption SubDomainizer.txt 

##################################################################

#GO-SPIDER
printf "$green"   "...GO-SPIDER started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

mkdir /app/$2/paths
/app/binaries/gospider -s "https://$2/" -c 10 -d 1 --other-source --include-subs --js --sitemap -a -r -o /app/$2/paths/gospider.txt  
python3 /app/p.py --type hi --path /app/$2/paths/gospider.txt  --caption gospider.txt  

##################################################################

#hakrawler
printf "$green"   "...hakrawler started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

echo $2 | /app/binaries/haktrails subdomains | /app/binaries/httpx | /app/binaries/hakrawler -depth 10 >> /app/$2/paths/hakrawler.txt
python3 /app/p.py --type hi --path /app/$2/paths/hakrawler.txt --caption hakrawler.txt 

##################################################################

# finding live domains
printf "$green"   "Scanning for live domain"

cat /app/$2/$2.master | /app/binaries/httprobe -c 50 -t 3000 -p 443 | tee -a /app/$2/live.txt
cat /app/$2/live.txt | wc -l

cat /app/$2/$2.master | /app/binaries/httprobe -p http:81 -p http:3000 -p https:3000 -p http:3001 -p https:3001 -p http:8000 -p http:8080 -p https:8443 -c 50 | tee -a /app/$2/otherport-domains.txt
python3 /app/p.py --type hi --path /app/$2/live.txt --caption live.txt 
python3 /app/p.py --type hi --path /app/$2/otherport-domains.txt --caption otherport-domains.txt 
python3 /app/p.py --type hi --path /app/$2/$2.master --caption $2.master 

#################################################################

# grep https domains
printf "$green"   "grep only https"

cat /app/$2/live.txt | grep "https" | cut -d"/" -f3 > /app/$2/live-https.txt
cat /app/$2/live-https.txt | wc -l
python3 /app/p.py --type hi --path /app/$2/live-https.txt --caption live-https.txt 

##################################################################

#favfreak
printf "$green"   "...favfreak started..."
printf "$cyan"    "...Domain = $1..."
printf ""
sleep 1

cat /app/$2/live.txt  | python3 /app/tools/FavFreak-master/favfreak.py -o output /app/$2/favfreak.txt
cat /app/$2/favfreak.txt | tr '[:upper:]' '[:lower:]'| /app/binaries/anew | grep -v "*." | grep -v " "|grep -v "@" | grep "\." >> /app/$2/$2.master
python3 /app/p.py --type hi --path /app/$2/favfreak.txt --caption favfreak.txt 

#################################################################

