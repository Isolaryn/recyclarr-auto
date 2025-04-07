FROM recyclarr/recyclarr:latest

USER root
RUN apk add --no-cache yq git

COPY auto-entrypoint.sh /auto-entrypoint.sh
RUN chmod +x /auto-entrypoint.sh

USER 1000:1000
# ENTRYPOINT ["/sbin/tini" "--" "/entrypoint.sh"]
ENTRYPOINT ["/sbin/tini", "--", "/auto-entrypoint.sh"]