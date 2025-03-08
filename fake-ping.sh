#!/bin/sh

# Variables
host=$1
count=4
timeout=1
success=0
total_time=0

# Resolve the host to an IP address
ip=$(getent ahosts "$host" | awk '{print $1; exit}')
if [ -z "$ip" ]; then
  echo "ping: $host: Name or service not known"
  exit 1
fi

echo "PING $host ($ip): 56 data bytes"

# Simulate ping responses
for i in $(seq 1 $count); do
  start_time=$(date +%s%3N) # Get current time in milliseconds
  if nc -z -w $timeout "$host" 80 2>/dev/null; then
    end_time=$(date +%s%3N)
    latency=$((end_time - start_time))
    total_time=$((total_time + latency))
    success=$((success + 1))
    echo "64 bytes from $ip: icmp_seq=$i ttl=64 time=${latency}ms"
  else
    echo "Request timeout for icmp_seq=$i"
  fi
  sleep 1
done

# Calculate statistics
loss=$((100 - (success * 100 / count)))
avg_time=$((total_time / success))

echo ""
echo "--- $host ping statistics ---"
echo "$count packets transmitted, $success received, $loss% packet loss, time ${total_time}ms"
if [ $success -gt 0 ]; then
  echo "rtt min/avg/max/mdev = ${avg_time}.0/${avg_time}.0/${avg_time}.0/0.0 ms"
fi
