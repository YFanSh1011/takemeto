#!/bin/bash

escape_path() {
    echo "$1" | sed 's_/_\\/_g'
}


echo "################################################################################################"
echo "#                                                                                              #"
echo "#                         Extracting Environment Variables...                                  #"
echo "#                                                                                              #"
echo "################################################################################################"
# Load the .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo ".env file not found"
    exit 1
fi

echo "################################################################################################"
echo "#                                                                                              #"
echo "#                         Provisioning Architecture in AWS...                                  #"
echo "#                                                                                              #"
echo "################################################################################################"

# First initialise the terraform architecture if not previously done
launch_city=$1
terraform -chdir=terraform init

# Then apply the terraform changes
terraform -chdir=terraform apply -auto-approve --var "launch-region=$launch_city" -refresh

# Store the ip address
ip=$(terraform -chdir=terraform output -raw public_ip)

echo "################################################################################################"
echo "                                          Public IP: $ip"                                  
echo "################################################################################################"

# Use curl to test the website
url="https://$ip"

# The number of seconds to wait between checks
wait_seconds=5
max_attempt=50
attempt=0
success_connect=0


echo "################################################################################################"
echo "#                                                                                              #"
echo "#                                 Connecting to Dashboard...                                   #"
echo "#                                                                                              #"
echo "################################################################################################"
# Test if the website is online
while [ $attempt -lt $max_attempt ]; do
    echo "Attempt $((attempt + 1)): Waiting for the webserver to come online."
    # Attempt to make a request to the webserver
    if curl -k --output /dev/null --silent --fail "$url"; then
        echo "      Webserver is online.        "
        success_connect=1
        break
    fi

    # Wait for a specified time before trying again
    attempt=$((attempt + 1))
    sleep "$wait_seconds"
done

if [ "$success_connect" -eq 1 ]; then
    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                 Downloading .ovpn config...                                  #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    
    # Download the config file from the website
    python fetch_config.py "$url"

    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                 Finalising configuration...                                  #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    # Get the name of the downloaded file
    ovpn_file=$(ls -Art "$DEFAULT_DOWNLOAD_PATH" | grep ovpn | tail -n 1)
    ovpn_file_path="$DEFAULT_DOWNLOAD_PATH/$ovpn_file"
    echo $ovpn_file_path
    
    # Escape the VPN_CREDENTIALS_PATH
    # escaped_credentials_path=$(escape_path "$VPN_CREDENTIALS_PATH")
    # echo $escaped_credentials_path

    # Use sed to replace "auth-user-pass" with "auth-user-pass /escaped/path"
    # sed -i "" "s/auth-user-pass/auth-user-pass $escaped_credentials_path/g" "$ovpn_file_path"

    # Retrieve password from the local credentails file
    sed -n "2p" "$VPN_CREDENTIALS_PATH" | pbcopy
    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                 Your password is already in clipboard                        #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    

    # Open the downloaded file using openvpn
    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                 Directing to VPN Client...                                   #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    open -a "OpenVPN Connect" "$ovpn_file_path"

    # Wait for the user to press enter before exiting
    echo "################################################################################################"
    read -p "Press enter to disconnect from VPN and destroy the infrastructure..."
    rm "$ovpn_file_path"

else
    echo "The website is not online."
fi


# Cleanup the resources
echo "################################################################################################"
echo "#                                                                                              #"
echo "#                                 Cleaning up Resources...                                     #"
echo "#                                                                                              #"
echo "################################################################################################"
terraform -chdir=terraform destroy -auto-approve

