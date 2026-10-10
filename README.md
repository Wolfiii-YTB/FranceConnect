# FranceConnect par Horizon — ENT scolaire fictif

FranceConnect est un espace numérique de travail fictif, construit avec Next.js, TypeScript, Tailwind CSS, Prisma et PostgreSQL. Il propose une base fonctionnelle pour l’authentification, les comptes, les classes, l’organisation des cours, les notes, les appels, les devoirs et leur suivi. Les données sont fictives et conçues pour un établissement de jeu de rôle.

## Prérequis

- Node.js 22 ou plus récent et npm
- Docker Desktop (ou Docker Engine) pour PostgreSQL local, ou une base PostgreSQL distante

## Installation locale sous Windows (PowerShell)

Pour démarrer l’application en un clic, double-cliquez sur `Lancer-FranceConnect.bat`. Il prépare `.env` et les dépendances au premier lancement, démarre PostgreSQL, applique la migration, crée les rôles, puis ouvre l’espace de connexion dans le navigateur. Docker Desktop doit être installé ; s’il est fermé, le lanceur essaie de l’ouvrir.

Lors du tout premier lancement, le lanceur affiche dans sa fenêtre le mot de passe de l’administrateur local qu’il vient de générer. Conservez-le. Ce mot de passe et les autres valeurs sensibles sont uniquement dans `.env`, ignoré par Git. Le dossier de données PostgreSQL est conservé entre les lancements.

Le lancement manuel reste disponible :

```powershell
Copy-Item .env.example .env
# Remplacez les deux valeurs « replace-with… » par le même mot de passe local unique.
docker compose up -d db
npm install
npm run db:generate
npm run db:migrate -- --name init
npm run db:seed
npm run dev
```

Ouvrez ensuite [http://localhost:3000](http://localhost:3000). L’inscription crée un compte Élève et ouvre une session. Les identifiants de rôle ne peuvent pas être choisis depuis le formulaire public.

Pour une base distante, remplacez `DATABASE_URL` dans `.env` par l’URL PostgreSQL fournie par votre hébergeur. Le compte utilisé doit pouvoir créer les tables lors de la migration.

En production, définissez également `IP_HASH_SECRET` avec une valeur aléatoire unique d’au moins 32 octets (par exemple `node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"`). Cette clé sert à pseudonymiser les adresses IP utilisées pour la limitation des tentatives.

## Compte administrateur local facultatif

Le seed crée les rôles, permissions et référentiels fictifs du Collège Horizon. Il crée aussi un compte administrateur si `ADMIN_EMAIL` et `ADMIN_PASSWORD` sont définis dans `.env`. Les comptes de démonstration ne sont plus créés par défaut. Pour les activer volontairement, définissez `SEED_DEMO_DATA=true`, puis lancez `npm run db:seed`. Les comptes fictifs sont `eleve.6a@horizon.test` à `eleve.3b@horizon.test`, `parent.1@horizon.test` à `parent.4@horizon.test`, les quatre comptes `prof.*@horizon.test`, `cpe@horizon.test`, `surveillant@horizon.test` et `direction@horizon.test`. Leur mot de passe est `DEMO_PASSWORD` si renseigné, sinon `ADMIN_PASSWORD`.

Pour retirer uniquement les comptes connus créés par l’installation (démonstration et administrateur local par défaut), lancez `npm run db:cleanup-demo` pour un aperçu, puis `npm run db:cleanup-demo -- --apply` pour confirmer la suppression définitive. Le script protège un compte administrateur explicitement configuré dans `ADMIN_EMAIL` (sauf l’adresse de démonstration par défaut `admin@horizon.test`) et ne touche pas aux comptes en dehors de sa liste fixe.

Les valeurs de `.env` sont locales et ignorées par Git. Aucun compte préconfiguré ni mot de passe de démonstration n’est livré dans le dépôt.

## Base de données

```powershell
npm run db:generate
npm run db:migrate -- --name nom-de-migration
npm run db:migrate:deploy
npm run db:seed
npm run db:studio
```

Le schéma comprend les comptes, rôles, permissions, sessions, journal d’activité, années scolaires, périodes, classes, groupes, élèves, responsables, professeurs, matières, salles, cours, contenus de séances, évaluations, notes, absences, devoirs, rendus, dossiers de vie scolaire, conversations, notifications, documents, événements, menus et réservations de cantine, compétences, conseils de classe, bulletins et rendez-vous.

## Vérifications

```powershell
npm run lint
npm run typecheck
npm test
npm run build
```

La CI GitHub exécute ces contrôles à chaque push et pull request. Les tests actuels couvrent le hash des mots de passe ; les scénarios d’API nécessitent une base PostgreSQL.

## Publier le code et héberger gratuitement

GitHub héberge le code et exécute la CI ; GitHub Pages ne peut pas héberger cette application complète, car elle a besoin du serveur Next.js et d’une base PostgreSQL. Consultez [docs/DEPLOIEMENT_GRATUIT.md](docs/DEPLOIEMENT_GRATUIT.md) pour les étapes de déploiement et les limites des offres gratuites. Dans l’espace de travail local, `MIGRATION GITHUB` est une copie nettoyée pour l’envoi et n’est pas incluse dans le dépôt normal.

## Authentification mise en place

- Les mots de passe sont dérivés avec `scrypt` et un sel aléatoire.
- Les sessions utilisent des jetons aléatoires opaques ; seul leur condensat SHA-256 est conservé en base.
- Le cookie de session est `HttpOnly`, `SameSite=Lax`, et `Secure` en production.
- Les tentatives de connexion sont limitées en base ; les adresses IP ne sont conservées que sous forme de condensat.
- Les sessions actives sont consultables via `GET /api/auth/sessions`, révocables une par une avec `DELETE /api/auth/sessions` (corps JSON `{ "id": "…" }`), ou toutes à la fois avec `POST /api/auth/logout-all`.
- Les autres sessions sont révoquées au changement de mot de passe via `POST /api/auth/change-password`.
- La page `/mon-compte` permet de changer son mot de passe, consulter les appareils connectés et fermer une session ou toutes les sessions. Les préférences d’alertes sont accessibles depuis cette page.
- La réinitialisation par jeton à usage unique expire après une heure. En développement, le lien est affiché dans l’interface. En production, configurez un fournisseur d’e-mail avant d’activer cette fonction.
- Les vérifications de permissions sont disponibles côté serveur avec `hasPermission()` et `requirePermission()` dans `src/lib/auth.ts`.

## Personnalisation et icônes

- Depuis `/mon-compte`, chaque personne peut choisir une couleur d’accent, un espacement compact ou confortable, un affichage agrandi et un contraste renforcé.
- Ces préférences sont séparées par compte et enregistrées dans le stockage local du navigateur. Elles ne contiennent aucune donnée sensible et ne sont pas synchronisées entre appareils.
- Les pictogrammes de l’interface sont des SVG locaux réutilisables (`src/components/icon.tsx`). Aucune police d’icônes, ressource distante ou dépendance supplémentaire n’est nécessaire.
- Le thème par défaut reste identique lorsque les préférences sont réinitialisées ou que le stockage du navigateur est désactivé.

Le suivi de vie scolaire calcule aussi les heures d’absence, demi-journées, retards et justificatifs pour l’année scolaire active. L’emploi du temps propose les vues jour, semaine et mois, avec filtres sur les cours visibles par classe, professeur et salle ; la création peut produire jusqu’à 52 séances hebdomadaires ou aux deux semaines (cycles A/B), avec vérification des conflits sur toute la récurrence.

## Administration disponible

La connexion redirige vers l’espace associé au rôle : `/espace/eleve`, `/espace/parent`, `/espace/vie-scolaire` (CPE, secrétariat, infirmerie), `/espace/surveillant` (AED) ou `/espace/direction` (direction et administration). Ces pages sont protégées par rôle et affichent les données autorisées à partir du profil. La page `/eleves` fournit un dossier centralisé avec choix d’élève limité aux permissions et liens scolaires autorisés. Les principales pages métiers sont `/admin` (utilisateurs, rôles, permissions, journal d’activité), `/admin/eleves` (dossiers élèves), `/admin/personnes` (professeurs et responsables), `/admin/etablissement` (années et classes), `/admin/referentiel` (matières et salles), `/emploi-du-temps`, `/notes`, `/vie-scolaire`, `/discipline`, `/devoirs`, `/messagerie`, `/documents`, `/agenda`, `/cantine`, `/competences`, `/conseils-de-classe`, `/bulletins` et `/rendez-vous`.

Les routes HTTP et leurs permissions sont décrites dans [docs/API.md](docs/API.md).

Les API vérifient les permissions côté serveur et les opérations importantes alimentent le journal d’activité. Les professeurs peuvent publier des évaluations pour leurs cours et saisir l’appel ; les moyennes sont pondérées par coefficient et ramenées sur 20. Les élèves et parents ne voient que les résultats et suivis associés à leurs profils. Les professeurs créent les devoirs de leurs cours, les élèves peuvent transmettre une réponse et le professeur peut la corriger. L’agenda permet de publier des événements par classe ou établissement ; la cantine gère les menus et réservations liées au régime de l’élève. Le référentiel de compétences permet les évaluations ; les conseils de classe enregistrent les moyennes, appréciations et décisions par période. Les bulletins figent les notes, compétences, absences et décisions de conseil avant de produire un PDF. Les rendez-vous parent-professeur empêchent les réservations doubles. Le module disciplinaire gère les observations et mesures éducatives, la messagerie privée crée des alertes, et le centre de notifications est lié aux notes, absences, devoirs, événements, bulletins et messages. L’administration des documents accepte des PDF, images PNG/JPEG et textes de 8 Mo maximum ; les fichiers sont conservés dans PostgreSQL et restent soumis aux permissions de partage. Le seed ajoute une année 2026–2027, trois trimestres, des salles, matières et classes fictives de la 6e à la 3e.

Après mise à jour du dépôt, relancez `Lancer-FranceConnect.bat` afin que les migrations Prisma soient appliquées avant l’ouverture de l’application.

## Docker

`docker-compose.yml` démarre PostgreSQL 16 avec un volume persistant. Le fichier `.env.example` ne contient que des valeurs de remplacement. N’exposez jamais cette base sur un réseau public.

```powershell
docker compose up -d db
docker compose down
```

## Sécurité et données

N’inscrivez jamais de vrais élèves ou de données personnelles dans ce projet. Le dépôt n’inclut pas de secrets. `.env` est ignoré par Git ; `.env.example` ne contient que des valeurs locales d’exemple. Les comptes ouverts par inscription reçoivent exclusivement le rôle Élève. Créez les autres comptes depuis l’administration ; leurs accès sont définis par les permissions de leur rôle.

## Licence

MIT. Voir [LICENSE](LICENSE).

## Collaboration, appels et vie scolaire

- `/cloud` donne accès aux documents autorisés du compte, de sa classe ou de son dossier. Les fichiers sont stockés en base PostgreSQL et limités aux PDF, PNG, JPEG et texte (8 Mo).
- `/espaces-travail` permet de créer un espace personnel ou de classe. Les membres d’une classe et leurs responsables liés sont ajoutés automatiquement ; les publications restent réservées aux membres.
- `/discipline` permet aux professeurs d’envoyer une demande de mesure à la vie scolaire. Les demandes ne deviennent pas des sanctions avant décision d’un personnel habilité. Le permis à points est facultatif, désactivé par défaut, et son solde initial est configurable dans cette page.
- `/appels` planifie des visioconférences Jitsi. Configurez `JITSI_BASE_URL` dans `.env` pour utiliser une instance auto-hébergée ; la valeur de démonstration est `https://meet.jit.si`.
- Dans `/admin`, la suppression définitive retire aussi les cours créés par le professeur supprimé, ses événements et documents déposés. Une entrée d’audit est conservée sans rattachement à ce compte.

Après récupération d’une mise à jour, le lanceur applique les migrations Prisma avant d’ouvrir l’application.

Pour supprimer en un clic la liste fixe des comptes fictifs du seed, lancez d’abord l’application puis double-cliquez sur `Supprimer-comptes-demo.bat`. Le compte `ADMIN_EMAIL` configuré (sauf l’adresse fictive `admin@horizon.test`) et les comptes hors liste sont protégés.
