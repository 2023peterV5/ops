#!/bin/bash
# Retrieve current IP address

ip=$(curl -s https://api.ipify.org);
old_ip=$(head -1 $HOME/ActualIp.txt)

profile="default"
ports=(22 3306);
group_ids=(sg-087891bcfb9caea8d sg-013e1366ba61b6548);
fixed_ips=();


if [ "$ip" == "$old_ip" ]; then

        echo "nothing to do"

else
        for port in ${ports[@]}
        do
                for group_id in ${group_ids[@]}
                do

                        # Display security group name
                        echo -e "\033[34m\nModifying Group: ${group_id}\033[0m and port number: ${port}";

                        # Get existing IP rules for group
                        ips=$(aws ec2 --profile=$profile describe-security-groups --filters Name=ip-permission.to-port,Values=$port Name=ip-permission.from-port,Values=$port Name=ip-permission.protocol,Values=tcp --group-ids $group_id --output text --query 'SecurityGroups[*].{IP:IpPermissions[?ToPort==`'$port'`].IpRanges}')
                        ips=$(sed 's/IP//g' <<< $ips)

                        for ip in $ips
                        do
                                echo -e "\033[31mRemoving IP: $ip\033[0m"
                                # Delete IP rules matching port
                                aws ec2 revoke-security-group-ingress --profile=$profile --group-id $group_id --protocol tcp --port $port --cidr $ip 
                        done
        # Get current public IP address
        myip=$(curl -s https://api.ipify.org);
        echo -e "\033[32mSetting Current IP: ${myip}\033[0m"

        # Add current IP as new rule
        aws ec2 authorize-security-group-ingress --profile=$profile --protocol tcp --port $port --cidr ${myip}/32 --group-id $group_id
        #Print curret IP to a file for the next cron
        curl -s https://api.ipify.org > $HOME/ActualIp.txt

        # Loop through fixed IPs
        #for ip in $fixed_ips
        #do
        #echo -e "\033[32mSetting Fixed IP: ${ip}\033[0m"

        # Add fixed IP rules
        #/home/pi/.local/bin/aws ec2 authorize-security-group-ingress --profile=$profile --protocol tcp --port $port --cidr ${ip} --group-id $group_id
        #done

                done
        done
fi