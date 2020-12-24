FROM python:3.9.1-slim-buster
LABEL maintainer="Humenius <contact@humenius.me>"

ENV DOMAIN=example.com
ENV EMAIL=test@example.com

# Install dependencies and Apache2
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install build-essential software-properties-common -y && \
    apt-get install apache2 libapache2-mod-wsgi -y && \
    apt-get install virtualenv libmysqlclient-dev -y 

# Move web files
RUN mkdir -p /var/www/get5-web
WORKDIR /var/www/get5-web
COPY . .

# Move WSGI file into previous directory
RUN sed 's/<hostname>/${DOMAIN}/g' docker/get5.wsgi
RUN sed 's/<email>/${EMAIL}/g' docker/get5.wsgi
RUN mv docker/get5.wsgi ..

RUN virtualenv venv && \
    source venv/bin/active && \
    pip install -r requirements.txt

# Add mountpoint for configuration file
VOLUME ["/var/www/get5-web/instance"]

# Add mountpoint for images (logos)
VOLUME ["/var/www/get5-web/get5/static/img/logos"]

# Add mountpoint for log files
RUN chown -R www-data logs
VOLUME ["/var/www/get5-web/logs"]

# Move Apache2 config file into Apache2 config folder
RUN mv docker/get5.conf /etc/apache2/sites-enabled/get5.conf && \
    service apache2 restart

# Move entrypoint script
RUN chmod +x docker/entrypoint.sh
RUN mv docker/entrypoint.sh .

CMD ["entrypoint.sh"]