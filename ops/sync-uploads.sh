#!/bin/bash
export PATH=/usr/local/bin:/usr/bin:/bin:/snap/bin
CIBLE="${CIBLE:?adresse de la VM copie}"
kubectl exec deploy/wordpress-release -c wordpress -- tar czf - -C /bitnami/wordpress/wp-content uploads | ssh -o BatchMode=yes "ayoub@${CIBLE}" "PATH=/usr/local/bin:/usr/bin:/bin:/snap/bin kubectl exec -i deploy/wordpress-release -c wordpress -- tar xzf - -C /bitnami/wordpress/wp-content"
echo "$(date) copie OK"