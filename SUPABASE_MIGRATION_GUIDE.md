# Migration Laravel vers Supabase

Cette application mobile ne dépend plus du backend Laravel pour l'authentification, les produits, les catégories, les transactions et le dashboard.

## Ce qui a changé

- La couche réseau Flutter utilise maintenant `supabase_flutter`.
- L'auth Laravel/Sanctum est remplacée par Supabase Auth.
- Les images produit passent par Supabase Storage.
- La logique critique de stock et les agrégats du dashboard sont déplacés dans des fonctions SQL Supabase.

## Mise en place Supabase

1. Crée un projet Supabase.
2. Dans `Authentication > Providers > Email`, active l'auth email/mot de passe.
3. Désactive `Confirm email` si tu veux garder le même flux que Laravel, c'est-à-dire connexion immédiate juste après inscription.
4. Ouvre le SQL Editor et exécute [backend-supabase/migrations/001_initial_schema.sql](/Applications/MAMP/htdocs/gestcave_mobile/backend-supabase/migrations/001_initial_schema.sql:1).
5. Copie [gestcave_mobile/.env.example](/Applications/MAMP/htdocs/gestcave_mobile/.env.example:1) vers `.env` et renseigne:
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY`
   - `SUPABASE_STORAGE_BUCKET`
6. Si tu utilises Codex avec MCP, le projet contient déjà [.mcp.json](/Applications/MAMP/htdocs/gestcave_mobile/.mcp.json:1) pointant vers le serveur MCP Supabase du projet.

## Migration des données existantes

Si tu veux conserver les données Laravel existantes:

1. Exporte les tables `categories`, `products`, `users`, `transactions`.
2. Insère d'abord les utilisateurs dans `auth.users` via Supabase Auth ou un script admin.
3. Renseigne ensuite `public.users.auth_user_id` avec l'UUID Supabase correspondant.
4. Importe ensuite `categories`, puis `products`, puis `transactions`.

## Remarques importantes

- La table `public.users` garde un identifiant numérique pour rester compatible avec les modèles Flutter actuels.
- L'utilisateur authentifié Supabase est relié à `public.users` par `auth_user_id`.
- La création de transaction utilise la fonction `create_transaction_with_stock` pour conserver la logique Laravel:
  - contrôle du stock en sortie
  - mise à jour atomique du stock
  - mémorisation des prix d'achat et de vente
- Le dashboard mobile s'appuie sur `get_dashboard_data`, qui reproduit les calculs Laravel.
- Le dossier [backend-supabase](/Applications/MAMP/htdocs/gestcave_mobile/backend-supabase/README.md:1) devient le point d'entrée recommandé pour tout ce qui concerne la migration backend.

## Vérification rapide

Après configuration:

1. Lance `flutter pub get`
2. Lance `flutter run`
3. Crée un compte
4. Crée une catégorie
5. Crée un produit avec ou sans image
6. Crée une transaction d'entrée puis une sortie
7. Vérifie le dashboard et les alertes de stock
