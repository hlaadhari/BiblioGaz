
# 📚 biblioGaz – Version simplifiée de Koha

**biblioGaz** est une version allégée et personnalisée du système de gestion de bibliothèque open source **Koha**, développée pour répondre aux besoins spécifiques de la **DCPTGZ (Direction Centrale du Pilotage du Transport du Gaz)**.

Ce projet a été réalisé dans le cadre d’un stage encadré par la cellule informatique et a pour objectif de conserver uniquement les fonctionnalités essentielles de Koha : **la gestion des livres** et **la gestion des utilisateurs**, avec un module de prêt manuel.

---

## 🎯 Objectifs du projet

- Déployer une solution simple et intuitive de gestion de bibliothèque interne.
- Supprimer tous les modules Koha inutilisés par la DCPTGZ.
- Fournir une interface web propre, en français, orientée vers un usage local.

---

## ✅ Fonctionnalités conservées

- 📚 **Catalogue des livres**
  - Ajouter, modifier, supprimer un ouvrage
  - Recherche simple
- 👥 **Gestion des utilisateurs**
  - Ajouter, modifier, supprimer un lecteur
- 🔄 **Emprunt et retour manuel**
  - Enregistrement direct d’un prêt ou d’un retour

---

## ❌ Modules supprimés ou désactivés

- Acquisitions
- Périodiques
- Suggestions d’achat
- Réservations
- Statistiques avancées
- OPAC (interface publique)
- Catalogage UNIMARC avancé

---

## 🧱 Technologies utilisées

- Backend : **Perl**
- Frontend : **Template Toolkit (.tt)**, HTML, CSS
- Base de données : **MariaDB/MySQL**
- OS recommandé : **Debian 11/12**
- Interface web admin : **Koha Intranet (fr-FR)**

---

## 🚀 Installation rapide (version locale)

> Pour test ou développement

```bash
git clone https://github.com/votre-repo/bibliogaz.git
cd bibliogaz
# Lancer le conteneur docker ou suivre le script d'installation Debian
📂 Arborescence modifiée
Les principaux répertoires Koha personnalisés :

swift
Copy
Edit
/koha-tmpl/intranet-tmpl/prog/fr-FR/modules/
├── catalogue/      → conservé (simplifié)
├── members/        → conservé
├── circulation/    → conservé
├── acqui/          → supprimé
├── serials/        → supprimé
├── opac/           → supprimé
🧑‍💻 Réalisateurs
Ce projet a été réalisé par deux stagiaires sous l’encadrement de [Nom du responsable] dans le cadre d’un stage au sein de la DCPTGZ.

📦 Livrables
Version Koha allégée : VM ou Docker

Documentation technique

Guide utilisateur simple (PDF)

Rapport de stage

📝 Licence
Koha est un logiciel libre sous licence GPL v3. Cette version modifiée reste sous la même licence.
Pour plus d'infos : https://koha-community.org

📬 Contact
Pour toute question :
DCPTGZ – Cellule Informatique
hlaadhari@steg.com.tn
