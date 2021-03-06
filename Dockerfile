
FROM alpine:3.5
MAINTAINER Bryan Karaffa <bryankaraffa@gmail.com>

ENTRYPOINT ["/start.sh"]
VOLUME /data

ADD addons/nginx-server.conf /etc/nginx/conf.d/default.conf
ADD addons/start.sh /start.sh

# useable for any git references
ENV HUBZILLAVERSION 3.8.7

ENV HUBZILLAINTERVAL 10
ENV SERVERNAME 127.0.0.1
ENV SMTP_HOST smtp.mailgun.org
ENV SMTP_PORT 587
ENV SMTP_USER postmaster@domain.com
ENV SMTP_PASS password
ENV SMTP_USE_STARTTLS YES

RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add \
        bash \
        curl \
        dcron \
        gd \
        nginx \
        openssl \
        php5 \
        php5-curl \
        php5-fpm \
        php5-gd \
        php5-json \
        php5-pdo_mysql \
        php5-pdo_pgsql \
        php5-openssl \
        php5-xml \
        php5-zip \
        ssmtp \
    && echo '' > /etc/ssmtp/ssmtp.conf \
    && echo "mailhub=${SMTP_HOST}:${SMTP_PORT}" >> /etc/ssmtp/ssmtp.conf \
    && echo "AuthUser=${SMTP_USER}" >> /etc/ssmtp/ssmtp.conf \
    && echo "AuthPass=${SMTP_PASS}" >> /etc/ssmtp/ssmtp.conf \
    && echo "UseSTARTTLS=${SMTP_USE_STARTTLS}" >> /etc/ssmtp/ssmtp.conf \
    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
    && mkdir -p /run/nginx /hubzilla \
    && curl https://framagit.org/hubzilla/core/-/archive/${HUBZILLAVERSION}/core-${HUBZILLAVERSION}.tar.gz | tar -xz --strip-components=1 -C /hubzilla -f - \
    && chown nginx:nginx -R /hubzilla \
    && chmod 0777 /hubzilla \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php5/php.ini \
    && echo 'sendmail_path = "/usr/sbin/ssmtp -t -i"' > /etc/php5/conf.d/mail.ini \
    && chmod u+x /start.sh \
    && echo "*/###HUBZILLAINTERVAL###    *       *       *       *       cd /hubzilla; /usr/bin/php Zotlabs/Daemon/Master.php Cron" > /hubzilla-cron.txt
