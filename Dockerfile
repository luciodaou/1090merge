# Use a base image with necessary tools
FROM alpine:latest

# Install dependencies
RUN apk add --no-cache netcat-openbsd coreutils logrotate

# Create necessary directories
RUN mkdir -p /scripts /etc/logrotate.d
# Copy the scripts into the container
COPY scripts/capture.sh /capture.sh

# Make the scripts executable
RUN chmod +x /capture.sh
# Create logrotate configuration file for adsb.csv
RUN echo '/data/adsb.csv {\
create 0644 root root\
daily\
rotate 7\
olddir /data\
missingok\
notifempty\
compress\
delaycompress\
postrotate\
pkill -HUP -f "sh /capture.sh"\
endscript\
}' > /etc/logrotate.d/adsb
# Create a crontab file
RUN echo '0 0 * * * /usr/sbin/logrotate /etc/logrotate.d/adsb' > /etc/crontabs/root
# Set the default command to run on container startup
CMD crond -l 2 -f & sh /capture.sh
