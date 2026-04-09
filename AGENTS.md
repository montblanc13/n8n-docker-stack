# N8N Docker Stack

Il s'agit ici de construire un Stack DOcker pour exploiter une instance de N8N community.

## Stack docker

La stack docker doit contenir 3 containers :

- N8N Dernière version
- Redis dernière version
- PGVector dernière version
- Utiliser un network `n8n_bnetwork`
- Utiliser un volume dédié pour chaque container


### Instance N8N

Voici les exigences de configuration de N8N. 
Consulter la documentation pour ajuster la  la configuration.

- Prendre toujours la dernière version. 
- Assurer une rétention des exceceution de 3 jours seulement. 
- Assurer la sortie des logs dans un dossier avec un montage spéciale
- Autoriser l'import et l'exécution de Community Nodes
- activer l'API N8N et son swagger

### Redis

- Utiliser mll'image docker de la `redis-stack`
- Protéger l'intance Redis d'un mot de passe
- Assurer un healthcheck


### PGVector
Pour l'instance de PostGreSQL/PGVector prévoir : 
- Un mot de passe admin (root) général
- Prévoir un user dédié pour N8N et un schéma dédié pour N8N
- Assurer un healthcheck

IL faut peut-^tre prévoir un script d'initialisatrion de POstgres pour préparer la copnfuguration pour N8N.

## Gestion des variables et secrets

Les variables et secret utilisé dans lastacke doivent gérés dans un fichier `.env`. 
Proposes moi une version par défaut à surcharger éventuellement. 


