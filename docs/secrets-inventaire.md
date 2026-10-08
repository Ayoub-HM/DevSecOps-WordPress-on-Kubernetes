# Inventaire des clés sensibles

Cet inventaire indique uniquement les chemins de fichiers et les noms de clés. Aucune valeur n’est reproduite.

| Fichier | Clés |
| --- | --- |
| `db_values.yaml` | `auth.rootPassword`, `auth.password` |
| `wp_values.yaml` | `externalDatabase.password`, `wordpressDatabasePassword`, `wordpressPassword` |

Les fichiers d’infrastructure et `liqo/` ne sont pas présents dans l’arborescence actuelle. Leur historique sera examiné séparément pendant la phase 2 avec Gitleaks.