# Haute disponibilité WordPress et MariaDB

## Architecture

```text
VM active ── binlogs MariaDB via relais-mariadb ──> VM copie
VM active ── uploads WordPress via cron ──────────> VM copie
```

## Règle d’exploitation

Le relais `relais-mariadb` et le cron de copie des uploads tournent uniquement sur la VM active. Ne configurez jamais le cron sur la copie : il pourrait écraser les images de l’actif avec les fichiers de la copie.

Lors d’une bascule, `CIBLE` doit pointer vers la nouvelle VM copie.

WordPress sur la copie peut écrire dans la base de lui-même, notamment avec `wp-cron` et les contrôles de santé. Ces écritures sur le réplica entrent en conflit avec la réplication et peuvent provoquer une erreur 1062 (clé dupliquée).

## Vérifier la réplication

Sur la copie, dans MariaDB :

```sql
SHOW SLAVE STATUS\G
```

Vérifier que `Slave_IO_Running` et `Slave_SQL_Running` valent tous deux `Yes`. Le marqueur documentaire pour le mot de passe de réplication est `<REPL_PASSWORD>` ; ne jamais inscrire le mot de passe réel dans ces fichiers.

## Procédure de bascule

1. Promouvoir la copie : sur la copie, exécuter `SET GLOBAL read_only=0;`, puis retirer `--read-only=1` de son fichier de valeurs DB.
2. Couper le cron sur l’ancien actif pour empêcher toute copie inverse des uploads.
3. Transformer l’ancien actif en copie : ajouter `--read-only=1` à son fichier de valeurs DB, puis exécuter `SET GLOBAL read_only=1;` sur cette instance.
4. Reconfigurer les services de relais et le cron pour qu’ils tournent uniquement sur le nouvel actif. Si la configuration de réplication doit être documentée, remplacer le mot de passe par `<REPL_PASSWORD>`.