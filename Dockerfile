# ---- Base Stage ----
# Utilisation de Bun pour installer les dépendances
FROM oven/bun:1.1.30 AS base

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y unzip

# Créer un répertoire pour l'application
WORKDIR /kanban_app
# Copier package.json et bun.lockb uniquement pour installer les dépendances
COPY package.json bun.lockb ./


# # ---- Development Stage ----
# # Expose le port et lance le serveur en mode dev
# FROM base AS dev
# # Installe toutes les dépendances (y compris devDependencies)
# RUN bun install
# # Copier le reste de l'application
# COPY . .
# # Expose le port sur lequel l'application fonctionne en dev (Bun + Vite)
# EXPOSE 5173
# # Lancer le serveur en mode développement
# CMD ["bun", "run", "dev"]


# --- Build Stage ---
# Construction de l'application pour la production
FROM base AS build
# Installation des dépendances de production uniquement
RUN bun install
# Copier le reste des fichiers de l'application après l'installation des dépendances
COPY . .
# Construire l'application Vue avec Vite
RUN bun run build-only


# --- Production Stage ---
# Utilisation de l'image Nginx pour servir les fichiers en production
FROM nginx:alpine AS prod
# Copier les fichiers build depuis l'étape précédente
COPY --from=build /kanban_app/dist /usr/share/nginx/html
# (Optionnel) Copier une configuration Nginx personnalisée
# COPY nginx.conf /etc/nginx/nginx.conf
# Expose le port sur lequel Nginx servira l'application
EXPOSE 80
# Commande par défaut pour lancer Nginx
CMD ["nginx", "-g", "daemon off;"]
