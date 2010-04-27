#!/bin/bash

if [ -z "$REPERTOIRE" ]
then
	REPERTOIRE=~/.PlayOnLinux
fi

if [ ! -f $REPERTOIRE/wineprefix/Roblox/cookies ]
then
	curl -s -c $REPERTOIRE/wineprefix/Roblox/cookies -d username=`zenity --title='Roblox' --text='Username:' --entry` -d password=`zenity --title='Roblox' --text='Password:' --hide-text --entry` 'https://www.roblox.com/login/dologin.aspx'
	status=$?
	case $status in
		0);;
		*)
			echo "Error $status"
			exit
		;;
	esac
fi

if [ ! -z "$1" ]
then
	input="$1"
else
	input=`zenity --entry --title='Roblox' --text='Place ID:'`
fi

# see if it is a url or not
if echo "$input" | grep -q 'http://'
then
	id=$(echo "$input" | sed 's|.*?.*id=\([^&]*\).*|\1|')
elif [ ! -z "$input" ]
then
	id="$input"
else
	exit
fi

joinScriptUrl="$(curl -s -b $REPERTOIRE/wineprefix/Roblox/cookies -H 'Content-Type: text/xml; charset=utf-8' -d '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><RequestGame xmlns="http://roblox.com/"><placeId>'$id'</placeId></RequestGame></soap:Body></soap:Envelope>' 'http://www.roblox.com/Game/PlaceLauncher.asmx' | sed -n 's|.*<joinScriptUrl>\([^<]*\)</joinScriptUrl>.*|\1|p')"
if [ -z "$joinScriptUrl" ]
then
	echo 'Retrying...'
	bash $0 $id
	exit
fi

export WINEPREFIX="$REPERTOIRE/wineprefix/Roblox"
export WINEDEBUG="-all"
cd $WINEPREFIX/drive_c/Program\ Files/RobloxVersions/*

# I know the echo is ugly, but I'm pretty sure it's required
wine Roblox.exe -play $(echo "$joinScriptUrl")
