#!/bin/bash
function cleanup_resources() {
    launch_city="$1"
    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                 Cleaning up Resources...                                     #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    terraform -chdir=terraform destroy -auto-approve \
        --var "launch-region=${launch_city}" \
        --var "vpn-admin-username=$VPN_ADMIN_USERNAME" \
        --var "vpn-admin-password=$VPN_ADMIN_PASSWORD" \
        --var "public-key-file-path=${PUBLIC_KEY_FILEPATH}"
}

# Assume the first script argument is the city name
launch_city="$1"

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
    cleanup_resources "$launch_city"
    exit 1
fi

export DEFAULT_DOWNLOAD_PATH="$(pwd)/ovpn_config"

# Install dependencies
if [ ! -e "automation/.requirement.lock" ]; then
    echo "################################################################################################"
    echo "#                                                                                              #"    
    echo "#                         Installing Dependencies...                                          #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    pip install -r automation/requirements.txt
    
    # Create the lock file to indicate that the dependencies have been installed
    touch automation/.requirement.lock
fi

echo "################################################################################################"
echo "#                                                                                              #"
echo "#                         Provisioning Architecture in AWS...                                  #"
echo "#                                                                                              #"
echo "################################################################################################"

# Initialise the terraform architecture if not previously done
if ! terraform -chdir=terraform init; then
    echo "Terraform init failed"
    cleanup_resources "$launch_city"
    exit 1
fi


# Translate the city name to a workspace name directly
workspace_name=${launch_city}

# Check if the workspace exists, and create it or switch to it as necessary
if terraform -chdir=terraform workspace list | grep -qw "${workspace_name}"; then
    echo "################################################################################################"
    echo "                      Switching to workspace ${workspace_name}."
    echo "################################################################################################"
    terraform -chdir=terraform workspace select "${workspace_name}"
else
    echo "################################################################################################"
    echo "              Workspace ${workspace_name} does not exist. Creating it now."
    echo "################################################################################################"
    terraform -chdir=terraform workspace new "${workspace_name}"
fi


# Then apply the terraform changes
if ! terraform -chdir=terraform apply -auto-approve \
    --var "launch-region=$launch_city" \
    --var "vpn-admin-username=$VPN_ADMIN_USERNAME" \
    --var "vpn-admin-password=$VPN_ADMIN_PASSWORD" \
    --var "public-key-file-path=${PUBLIC_KEY_FILEPATH}"; then

    echo "Terraform apply failed"
    cleanup_resources "$launch_city"
    exit 1
fi

# Store the ip address
ip=$(terraform -chdir=terraform output -raw public_ip)
if [ -z "$ip" ]; then
    echo "Failed to obtain public IP"
    cleanup_resources "$launch_city"
    exit 1
fi

echo "################################################################################################"
echo "                                          Public IP: $ip"                                  
echo "################################################################################################"

# Use curl to test the website
url="https://$ip"

# The number of seconds to wait between checks
wait_seconds=5
max_attempt=20
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
    if curl -k --output /dev/null --silent --fail "$url"; then
        echo "      Webserver is online.        "
        success_connect=1
        break
    fi
    attempt=$((attempt + 1))
    sleep "$wait_seconds"
done

if [ "$success_connect" -eq 1 ]; then
    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                 Downloading .ovpn config...                                  #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    
    if ! python3 automation/fetch_config.py "$url"; then
        echo "Failed to download .ovpn config"
        cleanup_resources "$launch_city"
        exit 1
    fi

    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                 Finalising configuration...                                  #"
    echo "#                                                                                              #"
    echo "################################################################################################"
    # Get the name of the downloaded file
    ovpn_file=$(ls -Art "$DEFAULT_DOWNLOAD_PATH" | grep ovpn | tail -n 1)
    ovpn_file_path="$DEFAULT_DOWNLOAD_PATH/$ovpn_file"
    echo $ovpn_file_path


    # Retrieve password from the local credentails file
    echo $VPN_ADMIN_PASSWORD | pbcopy
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
    cleanup_resources "$launch_city"
    rm "$ovpn_file_path"
        
else
    echo "The website is not online."
    cleanup_resources "$launch_city"
    exit 1
fi
