# 📚 BiblioGaz – Version simplifiée de Koha

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![Perl](https://img.shields.io/badge/Perl-5.34-yellow?logo=perl)](https://www.perl.org/)
[![MySQL](https://img.shields.io/badge/MySQL-5.7-orange?logo=mysql)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-GPL%20v3-green)](https://www.gnu.org/licenses/gpl-3.0)

**BiblioGaz** est une version allégée et personnalisée du système de gestion de bibliothèque open source **Koha**, développée pour répondre aux besoins spécifiques de la **DCPTGZ (Direction Centrale du Pilotage du Transport du Gaz)**.

Ce projet a été réalisé dans le cadre d'un stage encadré par la cellule informatique et a pour objectif de conserver uniquement les fonctionnalités essentielles de Koha : **la gestion des livres** et **la gestion des utilisateurs**, avec un module de prêt manuel.

---

## 🎯 Objectifs du projet

- 🎯 Déployer une solution simple et intuitive de gestion de bibliothèque interne
- 🧹 Supprimer tous les modules Koha inutilisés par la DCPTGZ
- 🌐 Fournir une interface web propre, en français, orientée vers un usage local
- 🚀 Installation rapide via Docker pour les stagiaires

---

## ✅ Fonctionnalités conservées

- 📚 **Catalogue des livres**
  - Ajouter, modifier, supprimer un ouvrage
  - Recherche simple et avancée
  - Import/Export de notices
- 👥 **Gestion des utilisateurs**
  - Ajouter, modifier, supprimer un lecteur
  - Gestion des catégories d'utilisateurs
- 🔄 **Emprunt et retour manuel**
  - Enregistrement direct d'un prêt ou d'un retour
  - Historique des emprunts
- ⚙️ **Administration simplifiée**
  - Configuration de base
  - Gestion des paramètres système essentiels

---

## ❌ Modules supprimés ou désactivés

- 🛒 Acquisitions
- 📰 Périodiques
- 💡 Suggestions d'achat
- 📋 Réservations
- 📊 Statistiques avancées
- 🌍 OPAC (interface publique)
- 📖 Catalogage UNIMARC avancé
- 🔗 Intégrations externes

---

## 🧱 Technologies utilisées

- **Backend** : Perl 5.34, Plack/PSGI, Starman
- **Frontend** : Template Toolkit (.tt), HTML5, CSS3, JavaScript
- **Base de données** : MySQL 5.7 / MariaDB
- **Conteneurisation** : Docker & Docker Compose
- **OS recommandé** : Ubuntu 22.04 LTS
- **Interface** : Koha Intranet (fr-FR)

---

## 🚀 Installation rapide avec Docker

### Prérequis

- 🐳 **Docker** (version 20.10+)
- 🐙 **Docker Compose** (version 2.0+)
- 💾 **4 GB RAM minimum** (8 GB recommandé)
- 💿 **10 GB d'espace disque libre**

### Installation automatique (Windows)

1. **Cloner le projet**
   ```bash
   git clone https://github.com/votre-repo/bibliogaz.git
   cd bibliogaz
   ```

2. **Lancer le script d'installation**
   ```powershell
   .\start_koha_docker.ps1
   ```

3. **Suivre le menu interactif**
   - Choisir l'option `1` pour démarrer Koha
   - Ou l'option `6` pour une installation from scratch

### Installation manuelle (Linux/macOS)

1. **Cloner le projet**
   ```bash
   git clone https://github.com/votre-repo/bibliogaz.git
   cd bibliogaz
   ```

2. **Démarrer les services**
   ```bash
   docker-compose up --build -d
   ```

3. **Vérifier l'installation**
   ```bash
   docker-compose ps
   docker-compose logs app
   ```

### Accès à l'application

- 🌐 **URL** : http://localhost:5000
- 👤 **Utilisateur par défaut** : `admin`
- 🔑 **Mot de passe par défaut** : `admin`

---

## 🛠️ Guide d'utilisation du script PowerShell

Le script `start_koha_docker.ps1` offre un menu interactif coloré pour gérer facilement BiblioGaz :

### Options disponibles

| Option | Description | Utilisation |
|--------|-------------|-------------|
| 🚀 **1** | Démarrer Koha | Installation automatique + démarrage |
| 🛑 **2** | Arrêter Koha | Arrêt propre des conteneurs |
| 📋 **3** | Voir les logs | Diagnostic et débogage |
| 📊 **4** | État des conteneurs | Vérification du statut |
| 🧹 **5** | Nettoyer | Suppression conteneurs + volumes |
| 🔄 **6** | Réinstaller from scratch | Installation complète propre |
| 👋 **7** | Quitter | Fermeture du script |

### Temps d'installation estimés

- ⚡ **Premier build** : 10-15 minutes
- 🔄 **Rebuild avec cache** : 2-5 minutes
- 📝 **Modification code** : 30 secondes - 2 minutes

---

## 🧪 Tests et validation

### Tests automatiques

1. **Test de connectivité**
   ```bash
   curl -I http://localhost:5000
   ```

2. **Test de la base de données**
   ```bash
   docker-compose exec db mysql -u koha -pkoha -e "SHOW DATABASES;"
   ```

3. **Test des logs d'application**
   ```bash
   docker-compose logs app | grep -i "error\|warning"
   ```

### Tests manuels

#### ✅ Test de connexion
1. Ouvrir http://localhost:5000
2. Se connecter avec `admin` / `admin`
3. Vérifier l'affichage du tableau de bord

#### ✅ Test de gestion des livres
1. Aller dans **Catalogue** → **Nouveau livre**
2. Ajouter un livre de test
3. Rechercher le livre ajouté
4. Modifier les informations
5. Supprimer le livre

#### ✅ Test de gestion des utilisateurs
1. Aller dans **Lecteurs** → **Nouveau lecteur**
2. Créer un utilisateur de test
3. Modifier les informations
4. Rechercher l'utilisateur

#### ✅ Test de circulation
1. Créer un livre et un lecteur
2. Effectuer un prêt
3. Effectuer un retour
4. Vérifier l'historique

### Résolution des problèmes courants

#### 🔧 L'application ne démarre pas
```bash
# Vérifier les logs
docker-compose logs app

# Redémarrer les services
docker-compose restart

# Reconstruction complète
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

#### 🔧 Erreur de base de données
```bash
# Vérifier la connexion MySQL
docker-compose exec db mysql -u root -pkoha_root -e "SHOW DATABASES;"

# Recréer la base de données
docker-compose down -v
docker-compose up -d
```

#### 🔧 Port déjà utilisé
```bash
# Changer le port dans docker-compose.yml
ports:
  - "5001:5000"  # Au lieu de 5000:5000
```

---

## 📂 Structure du projet

```
bibliogaz/
├── 🐳 docker-compose.yml          # Configuration Docker Compose
├── 🐳 Dockerfile                  # Image Docker optimisée
├── 📦 cpanfile                    # Dépendances Perl
├── 🚀 start_koha_docker.ps1       # Script de gestion Windows
├── 🚀 start_koha_app.sh           # Script de gestion Linux
├── ⚙️ app.psgi                    # Point d'entrée PSGI
├── 📁 koha-tmpl/                  # Templates modifiés
│   └── intranet-tmpl/prog/fr-FR/  # Interface française
├── 📁 C4/                         # Modules Koha backend
├── 📁 Koha/                       # Classes Koha modernes
├── 📁 etc/                        # Configuration
├── 📁 installer/                  # Scripts d'installation
└── 📁 misc/                       # Scripts utilitaires
```

---

## 🔧 Configuration avancée

### Variables d'environnement

Modifiez le fichier `docker-compose.yml` pour personnaliser :

```yaml
environment:
  - DB_HOST=db
  - DB_PORT=3306
  - DB_NAME=koha
  - DB_USER=koha
  - DB_PASS=koha
  - KOHA_CONF=/app/etc/koha-conf.xml
```

### Personnalisation de l'interface

Les templates sont dans `koha-tmpl/intranet-tmpl/prog/fr-FR/modules/` :

- `catalogue/` : Gestion du catalogue
- `members/` : Gestion des lecteurs
- `circ/` : Circulation (prêts/retours)
- `admin/` : Administration

### Sauvegarde des données

```bash
# Sauvegarde de la base de données
docker-compose exec db mysqldump -u koha -pkoha koha > backup_koha.sql

# Restauration
docker-compose exec -T db mysql -u koha -pkoha koha < backup_koha.sql
```

---

## 🚀 Déploiement en production

### Prérequis production

- 🖥️ **Serveur** : Ubuntu 22.04 LTS
- 💾 **RAM** : 8 GB minimum
- 💿 **Stockage** : 50 GB SSD
- 🌐 **Réseau** : Accès HTTP/HTTPS

### Configuration sécurisée

1. **Changer les mots de passe par défaut**
2. **Configurer HTTPS avec un reverse proxy**
3. **Mettre en place des sauvegardes automatiques**
4. **Configurer la surveillance des logs**

---

## 🧑‍💻 Développement

### Environnement de développement

1. **Cloner le projet**
   ```bash
   git clone https://github.com/votre-repo/bibliogaz.git
   cd bibliogaz
   ```

2. **Installer les dépendances locales**
   ```bash
   cpanm --installdeps .
   ```

3. **Lancer en mode développement**
   ```bash
   plackup -R . app.psgi
   ```

### Contribution

1. 🍴 Fork le projet
2. 🌿 Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. 💾 Commit les changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. 📤 Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. 🔄 Créer une Pull Request

---

## 📊 Monitoring et logs

### Surveillance des performances

```bash
# Utilisation des ressources
docker stats

# Logs en temps réel
docker-compose logs -f app

# Espace disque
docker system df
```

### Métriques importantes

- 📈 **Temps de réponse** : < 2 secondes
- 💾 **Utilisation RAM** : < 2 GB
- 💿 **Espace disque** : Surveillance des logs
- 🔄 **Uptime** : > 99.5%

---

## 🆘 Support et dépannage

### Ressources utiles

- 📖 [Documentation Koha officielle](https://koha-community.org/documentation/)
- 🐳 [Documentation Docker](https://docs.docker.com/)
- 🐛 [Issues GitHub](https://github.com/votre-repo/bibliogaz/issues)

### Commandes de diagnostic

```bash
# Vérifier l'état des services
docker-compose ps

# Logs détaillés
docker-compose logs --tail=100 app

# Accès au conteneur
docker-compose exec app bash

# Test de connectivité réseau
docker-compose exec app ping db
```

---

## 🧑‍💻 Équipe de développement

Ce projet a été réalisé par deux stagiaires sous l'encadrement de la cellule informatique dans le cadre d'un stage au sein de la **DCPTGZ**.

### Contributeurs

- 👨‍💻 **Stagiaire 1** : Développement backend et configuration Docker
- 👩‍💻 **Stagiaire 2** : Interface utilisateur et tests
- 👨‍🏫 **Encadrant** : Architecture et supervision technique

---

## 📦 Livrables

- ✅ **Version Koha allégée** : Container Docker prêt à l'emploi
- ✅ **Documentation technique** : Guide complet d'installation et configuration
- ✅ **Guide utilisateur** : Manuel d'utilisation simplifié (PDF)
- ✅ **Scripts d'automatisation** : Déploiement et maintenance
- ✅ **Rapport de stage** : Documentation du projet complet

---

## 📝 Licence

Koha est un logiciel libre sous licence **GPL v3**. Cette version modifiée reste sous la même licence.

- 📄 [Licence GPL v3](https://www.gnu.org/licenses/gpl-3.0)
- 🌐 [Site officiel Koha](https://koha-community.org)

---

## 📬 Contact

Pour toute question ou support technique :

- 🏢 **DCPTGZ** – Cellule Informatique
- 📧 **Email** : hlaadhari@steg.com.tn
- 🐛 **Issues** : [GitHub Issues](https://github.com/votre-repo/bibliogaz/issues)

---

## 🔄 Changelog

### Version 1.0.0 (2024)
- ✨ Version initiale de BiblioGaz
- 🐳 Conteneurisation Docker complète
- 🎨 Interface française simplifiée
- 📚 Modules essentiels : Catalogue, Lecteurs, Circulation
- 🚀 Script d'installation automatique

---

<div align="center">

**⭐ Si ce projet vous aide, n'hésitez pas à lui donner une étoile ! ⭐**

Made with ❤️ by DCPTGZ Team

</div>