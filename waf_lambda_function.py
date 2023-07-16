import json
import boto3


def lambda_handler(event, context):
    ip_set_id = "PLACEHOLDER_IP_SET_ID"

    # Extract the request object
    request = event['Records'][0]['cf']['request']

    # Extract the IP address of the viewer from the request
    viewer_ip = request['clientIp'] + "/32" # IPv4 CIDR notation

    # AWS WAF client
    waf_client = boto3.client('wafv2', region_name='us-east-1')

    try:
        # Get the IP set
        response = waf_client.get_ip_set(
            Name='honeypot_ip_blocklist',
            Scope='CLOUDFRONT',
            Id=ip_set_id
        )

        # Get the current IP set addresses and lock token
        ip_set_addresses = response['IPSet']['Addresses']
        lock_token = response['LockToken']

        # Add the new IP address if it's not already in the set
        if viewer_ip not in ip_set_addresses:
            ip_set_addresses.append(viewer_ip)

            # Update the IP set
            waf_client.update_ip_set(
                Name='honeypot_ip_blocklist',
                Scope='CLOUDFRONT',
                Id=ip_set_id,
                Addresses=ip_set_addresses,
                LockToken=lock_token
            )

            print('IP address added to the IP set:', viewer_ip)

    except Exception as e:
        print('Error updating WAF IP set:', e)

    # Continue with the request processing
    return request