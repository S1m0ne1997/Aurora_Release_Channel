#!/bin/sh
# Avvio del server Aurora nel contenitore (docker-compose.yml).
# Il programma vive in /data/bin: così si sostituisce da solo agli
# aggiornamenti e sopravvive alla ricreazione del contenitore.
set -eu
REPO=${AURORA_UPDATE_REPO:-S1m0ne1997/Aurora_Release_Channel}
[ "$REPO" = off ] && REPO=S1m0ne1997/Aurora_Release_Channel
mkdir -p /data/bin /data/state /data/certs
BIN=/data/bin/aurora

if [ ! -x "$BIN" ]; then
	case $(uname -m) in
	x86_64) ARCH=amd64 ;;
	aarch64 | arm64) ARCH=arm64 ;;
	*) echo "processore non supportato: $(uname -m)"; exit 1 ;;
	esac
	echo "primo avvio: scarico l'ultima versione stabile da $REPO"
	wget -q -O "$BIN.dl" "https://github.com/$REPO/releases/latest/download/aurora-linux-$ARCH"
	chmod 755 "$BIN.dl"
	mv "$BIN.dl" "$BIN"
fi

: "${PUBLIC_IP:?imposta PUBLIC_IP in .env}"
set -- -ip "$PUBLIC_IP" -rooms "${ROOMS:-Generale,Gaming,Musica,AFK}" -max "${MAX_PER_ROOM:-0}" \
	-udp "${UDP_PORT:-7882}" -certs /data/certs -state /data/state
if [ -n "${DOMAIN:-}" ]; then
	set -- -domain "$DOMAIN" "$@"
else
	set -- -addr ":${PORT:-8080}" "$@"
fi
cd /data
exec "$BIN" "$@"
