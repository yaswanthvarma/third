#!/bin/bash

EMAIL_RECEPIENTS= "yaswanth"

# Initialize variables
App1_failed_test=0
App1_success_test=0
App2_success_test=0

# Main loop
while true; do
    # Check if check1 fails 3 consecutive times and check2 is successful
    if ! nc -zv -w2 example.com 80 >/dev/null 2>&1; then
        ((App1_failed_test++))
        if [ $App1_failed_test -eq 3 ] && nc -zv -w2 example1.com 81 >/dev/null 2>&1; then
            # Drop IP forwarding to example.com 80 and forward requests to example1.com 81
            iptables -A FORWARD -d example.com -p tcp --dport 80 -j DROP
            iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination example1.com:81
            # Send email notification
            email_subject="IP Forwarding Changed"
            email_body="IP forwarding from example.com 80 to example1.com 81 has been set."
            echo "$email_body" | mailx -s "$email_subject" "$EMAIL_RECEPIENTS"
        fi
    else
        App1_failed_test=0
    fi
    
    # Check if check2 is successful
    if nc -zv -w2 example1.com 81 >/dev/null 2>&1; then
        App2_success_test=1
    else
        App2_success_test=0
    fi

    # Send email notification if both check1 and check2 fail
    if [ $App1_failed_test -eq 3 ] && [ $App2_success_test -eq 0 ]; then
        # Send email notification
            email_subject="Both CFT agents down"
            email_body="DIMS cannot forward your requests to APP1 and App2 as they are unreachable "
            echo "$email_body" | mailx -s "$email_subject" "$EMAIL_RECEPIENTS"
    fi

    sleep 4
done
