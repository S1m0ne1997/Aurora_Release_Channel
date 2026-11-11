# Immagine del server Aurora: Alpine con lo script di avvio. Il programma del
# server lo scarica aurora.sh al primo avvio nel volume /data e poi si aggiorna
# da solo, quindi l'immagine si ricostruisce solo se cambia lo script.
FROM alpine:3.22
LABEL org.opencontainers.image.title="Aurora" \
      org.opencontainers.image.description="Server della chat vocale Aurora" \
      org.opencontainers.image.source="https://github.com/S1m0ne1997/Aurora_Release_Channel"
COPY aurora.sh /aurora.sh
VOLUME /data
WORKDIR /data
ENTRYPOINT ["sh", "/aurora.sh"]
