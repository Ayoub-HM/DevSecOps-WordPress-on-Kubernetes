# Inventaire des clés sensibles

Cet inventaire indique uniquement les chemins de fichiers et les noms de clés. Aucune valeur n’est reproduite.

| Fichier | Clés |
| --- | --- |
| `db_values.yaml` | `auth.rootPassword`, `auth.password` |
| `wp_values.yaml` | `externalDatabase.password`, `wordpressDatabasePassword`, `wordpressPassword` |

Les fichiers d’infrastructure et `liqo/` ne sont pas présents dans l’arborescence actuelle. Gitleaks a cependant trouvé des secrets dans leur historique Git.

## Résultats Gitleaks sur l’historique

Les valeurs sont volontairement remplacées par `<CAVIARDÉ>`.

| Fichier | Ligne | Type | Commit (court) | Valeur |
| --- | ---: | --- | --- | --- |
| `liqo/config_dev-poc` | 19 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/config_dev-poc` | 20 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/config_dev-poc2` | 19 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/config_dev-poc2` | 20 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 72 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 73 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 77 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 85 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 86 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 90 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 94 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc` | 95 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 72 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 73 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 77 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 78 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 82 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 90 | `private-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 91 | `generic-api-key` | `897f51d` | `<CAVIARDÉ>` |
| `liqo/quick-start/liqo_kubeconf_dev-poc2` | 95 | `private-key` | `897f51d` | `<CAVIARDÉ>` |