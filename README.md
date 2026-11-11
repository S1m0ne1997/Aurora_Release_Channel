# Aurora – pacchetti di aggiornamento

Qui ci sono solo i pacchetti `.aurora` firmati che i server Aurora scaricano per aggiornarsi. Nessun sorgente.

- **Release**: versioni stabili.
- **Pre-release**: build di sviluppo, installabili solo dai server in modalità sviluppatore.

I pacchetti sono firmati: un server installa solo quelli con la firma del titolare. Tutti i diritti riservati, vedi `LICENSE`.

## Installare un server (Linux, Docker)

```bash
curl -fsSL https://raw.githubusercontent.com/S1m0ne1997/Aurora_Release_Channel/main/installa.sh | sudo sh
```

Installa Docker se manca, chiede dominio, IP e porta, avvia il server in `/opt/aurora`. Il server poi si aggiorna da solo dalle release stabili di questo repository.
