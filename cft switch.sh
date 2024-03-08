#!/bin/bash

# Function to send email
send_email() {
    local recipient="$1"
    local subject="$2"
    local body="$3"

    # Your email sending command here, such as 'mail', 'sendmail', 'mutt', etc.
    # Example using mail command:
    echo "$body" | mail -s "$subject" "$recipient"
}

# Function to drop IP forwarding and set forwarding rule
drop_and_set_forwarding() {
    local from_host="$1"
    local from_port="$2"
    local to_host="$3"
    local to_port="$4"

    # Drop IP forwarding to the specified host and port
    iptables -A FORWARD -p tcp -d "$from_host" --dport "$from_port" -j DROP

    # Set forwarding rule to forward requests to the new host and port
    iptables -t nat -A PREROUTING -p tcp --dport "$from_port" -j DNAT --to-destination "$to_host":"$to_port"
}

# Check connectivity for example.com:80
check1_output=$(nc -zv -w2 example.com 80 2>&1)
check1_result=$?

# Check connectivity for example1.com:81
check2_output=$(nc -zv -w2 example1.com 81 2>&1)
check2_result=$?

# If check1 fails and check2 is successful
if [ $check1_result -ne 0 ] && [ $check2_result -eq 0 ]; then
    drop_and_set_forwarding "example.com" "80" "example1.com" "81"

    # Send email notification
    email_subject="IP Forwarding Changed"
    email_body="Forwarding from example.com:80 has been dropped, requests are now forwarded to example1.com:81."
    send_email "your@email.com" "$email_subject" "$email_body"
fi
