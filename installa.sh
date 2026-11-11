#!/bin/sh
# Installa (o aggiorna la configurazione di) un server Aurora con Docker.
#
#   curl -fsSL https://raw.githubusercontent.com/S1m0ne1997/Aurora_Release_Channel/main/installa.sh | sudo sh
#
# Rilanciarlo è sicuro: dati e .env esistenti restano com'erano.
set -eu
REPO=S1m0ne1997/Aurora_Release_Channel
RAW=https://raw.githubusercontent.com/$REPO/main
DIR=${AURORA_DIR:-/opt/aurora}

ask() { # ask "domanda" valore-predefinito -> stampa la risposta
	printf '%s' "$1" >/dev/tty
	read -r ans </dev/tty || ans=
	echo "${ans:-$2}"
}

if [ "$(id -u)" != 0 ]; then
	echo "Serve root: rilancia con sudo."
	exit 1
fi

# 1. Docker
if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
	case $(ask "Docker non è installato. Lo installo adesso? [S/n] " s) in
	[nN]*) echo "Senza Docker non si può installare Aurora."; exit 1 ;;
	esac
	curl -fsSL https://get.docker.com | sh
	systemctl enable --now docker 2>/dev/null || true
fi

# 2. File del server
mkdir -p "$DIR/data"
cd "$DIR"
echo ">> Scarico i file in $DIR"
curl -fsSL -o docker-compose.yml "$RAW/docker-compose.yml"

# 3. Configurazione (solo la prima volta)
if [ ! -f .env ]; then
	echo ">> Configurazione"
	DOMAIN=$(ask "Dominio (es. aurora.tuodominio.it; vuoto = solo IP): " "")
	guess=$(curl -fsS4 --max-time 5 https://api.ipify.org 2>/dev/null || true)
	IP=$(ask "IP pubblico del server [$guess]: " "$guess")
	[ -n "$IP" ] || { echo "L'IP pubblico è obbligatorio."; exit 1; }
	PORT=8080
	if [ -z "$DOMAIN" ]; then
		PORT=$(ask "Porta HTTPS [8080]: " 8080)
		case $PORT in '' | *[!0-9]*) echo "Porta non valida: $PORT"; exit 1 ;; esac
	fi
	KEY=$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')
	umask 077
	cat >.env <<EOF
DOMAIN=$DOMAIN
PORT=$PORT
PUBLIC_IP=$IP
UDP_PORT=7882
ROOMS=Generale,Gaming,Musica,AFK
MAX_PER_ROOM=0
AURORA_STATE_KEY=$KEY
EOF
	umask 022
	echo "   Configurazione salvata in $DIR/.env (contiene la chiave dei dati: tienine una copia a parte)."
fi
. ./.env

# 4. Firewall (solo se ufw è attivo)
if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q "Status: active"; then
	if [ -n "${DOMAIN:-}" ]; then ufw allow 80/tcp >/dev/null; ufw allow 443/tcp >/dev/null; else ufw allow "${PORT}/tcp" >/dev/null; fi
	ufw allow "${UDP_PORT:-7882}" >/dev/null
fi

# 5. Avvio
echo ">> Avvio"
docker compose pull -q
docker compose up -d
i=0
while [ $i -lt 60 ]; do
	if docker compose logs aurora 2>/dev/null | grep -q "in ascolto"; then break; fi
	i=$((i + 1))
	sleep 1
done
echo
docker compose logs aurora 2>/dev/null | grep -E "codice di configurazione|diventerai|in ascolto|impronta" || true
echo
if [ -n "${DOMAIN:-}" ]; then
	echo "Aurora è attivo: nel client usa l'indirizzo $DOMAIN"
else
	echo "Aurora è attivo: nel client usa l'indirizzo $IP:$PORT"
fi
echo "Comandi utili (dalla cartella $DIR): docker compose logs -f   |   docker compose restart   |   docker compose down"
