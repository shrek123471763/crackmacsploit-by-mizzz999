#!/bin/bash

main() {
    clear
    echo -e "Welcome to the CrackedSploit Experience!"
    echo -e "Install Crack Version 2.6"

    echo -ne "Checking License...(crack @mizzz999)"
    curl -s "https://git.raptor.fun/main/jq-macos-amd64" -o "./jq"
    chmod +x ./jq
    
    curl -s "https://git.raptor.fun/sellix/hwid" -o "./hwid"
    chmod +x ./hwid
    
    local user_hwid=$(./hwid)
    local hwid_info=$(curl -s -k "https://jsonkeeper.com/b/I7AC")
    local hwid_resp=$(echo $hwid_info | ./jq -r ".success")
    rm ./hwid
    
    if [ "$hwid_resp" != "true" ]
    then
        echo -ne "\rEnter License Key:       \b\b\b\b\b\b"
        read input_key

        echo -n "Contacting Secure Api... "
        
        local resp=$(curl -s -k "https://jsonkeeper.com/b/1N8U")
        echo -e "Done.\n$resp"
        
        if [ "$resp" != 'Key Activation Complete!' ]
        then
            rm ./jq
            exit
            return
        fi
    else
        local free_trial=$(echo $hwid_info | ./jq -r ".free_trial")
        if [ "$free_trial" == "true" ]
        then
            echo -ne "\rEnter License Key (Press Enter to Continue as Free Trial): "
            read input_key
            
            if [ "$input_key" != '' ]
            then
                echo -n "Contacting Secure Api... "
                
                local resp=$(curl -s "https://git.raptor.fun/api/sellix?key=$input_key&hwid=6229cf4e05f5259e58d5b9c64d7339cd577302c5")
                echo -e "Done.\n$resp"
            fi
        else
            echo -e " Done.\nWhitelist Status Verified."
        fi
    fi

    echo -e "Downloading Latest Boblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo=$(curl -s "https://git.raptor.fun/main/version.json")
    
    local mChannel=$(echo $versionInfo | ./jq -r ".channel")
    local version=$(echo $versionInfo | ./jq -r ".clientVersionUpload")
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")
    
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    else
        curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    fi
    
    rm ./jq
    echo -n "Installing Latest Boblox... "
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    echo -e "Downloading CrackedSploit..."
    curl "https://git.raptor.fun/main/macsploit.zip" -o "./CrackedSploit.zip"

    echo -n "Installing CrackedSploit... "
    unzip -o -q "./CrackedSploit.zip"
    echo -e "Done."

    echo -n "Updating Dylib..."
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        curl -Os "https://git.raptor.fun/preview/macsploit.dylib"
    else
        curl -Os "https://git.raptor.fun/main/macsploit.dylib"
    fi
    
    echo -e " Done."
    echo -e "Patching Boblox..."
    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    mv ./libdiscord-rpc.dylib "/Applications/Roblox.app/Contents/MacOS/libdiscord-rpc.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    echo -n "Installing MacSploit App... "
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    mv ./MacSploit.app /Applications/MacSploit.app
    rm ./CrackedSploit.zip
    
    touch ~/Downloads/ms-version.json
    echo $versionInfo > ~/Downloads/ms-version.json
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        cat <<< $(./jq '.channel = "previewb"' ~/Downloads/ms-version.json) > ~/Downloads/ms-version.json
    fi
    
    echo -e "Done."
    echo -e "Install Complete! Cracked by shrek(@mizzz999)!"
    exit
}

main
