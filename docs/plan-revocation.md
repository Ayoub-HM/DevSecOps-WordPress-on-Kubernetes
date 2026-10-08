# Plan de révocation

Les valeurs ci-dessous sont caviardées. Gitleaks a relevé 20 findings historiques dans le commit `897f51d` ; aucun finding n’a été détecté dans le contenu courant du dépôt.

| Secret (caviardé) | Type et emplacement | Qui doit le révoquer | Comment révoquer | Comment remplacer | Priorité |
| --- | --- | --- | --- | --- | --- |
| `<CLÉ_PRIVÉE_CAVIARDÉE>` | `private-key` (12 findings) : `liqo/config_dev-poc`, `liqo/config_dev-poc2`, `liqo/quick-start/liqo_kubeconf_dev-poc`, `liqo/quick-start/liqo_kubeconf_dev-poc2`, commit `897f51d` | Propriétaire du cluster et équipe d’origine Liqo | Invalider le certificat ou l’identité associée auprès de l’autorité qui l’a émise ; vérifier les journaux d’accès | Générer une nouvelle identité à privilèges minimaux et distribuer un kubeconfig neuf aux seuls consommateurs autorisés | Critique |
| `<JETON_API_CAVIARDÉ>` | `generic-api-key` (8 findings) dans les mêmes fichiers Liqo, commit `897f51d` | Administrateur du service ou tenant concerné, avec l’équipe d’origine Liqo | Révoquer l’ancienne clé ou le jeton dans la console du fournisseur et contrôler son utilisation récente | Créer un nouveau jeton à portée minimale, le placer dans le gestionnaire de secrets prévu et mettre à jour les seuls consommateurs concernés | Critique |
| `<MOTS_DE_PASSE_DE_LABO_CAVIARDÉS>` | Anciens mots de passe de laboratoire présents dans `db_values.yaml` et `wp_values.yaml` avant leur migration vers des Secrets Kubernetes | Administrateurs MariaDB et WordPress du laboratoire | À changer plus tard, après sauvegarde et validation du plan de rotation ; aucune rotation n’est faite dans cette étape | Générer de nouveaux mots de passe, mettre à jour les Secrets Kubernetes correspondants puis vérifier les applications avant de retirer les anciens | À planifier |

## Pourquoi révoquer un secret commité

Supprimer une valeur du dernier fichier ne la supprime pas des anciens commits. Elle peut toujours être récupérée depuis l’historique Git, les clones, les caches ou les archives du dépôt. Il faut donc révoquer ou renouveler le secret exposé, même si le fichier a depuis été corrigé.