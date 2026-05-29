# SagaEat — Spécification Technique & Produit v1.0

> Application mobile de livraison de repas pour Haïti  
> Plateforme client (utilisateur final)  
> Stack: Flutter 3.x / Dart 3.11 · Android (iOS à venir)

---

## Table des Matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Stack Technologique](#2-stack-technologique)
3. [Architecture](#3-architecture)
4. [Écrans & Fonctionnalités](#4-écrans--fonctionnalités)
5. [Modèles de Données](#5-modèles-de-données)
6. [Services Internes](#6-services-internes)
7. [Règles Métier](#7-règles-métier)
8. [Contrat API (Backend Attendu)](#8-contrat-api-backend-attendu)
9. [Notifications](#9-notifications)
10. [Permissions Android](#10-permissions-android)
11. [État Actuel & Chemin vers Production](#11-état-actuel--chemin-vers-production)

---

## 1. Vue d'ensemble

**SagaEat** est une application mobile de commande et livraison de repas ciblant le marché haïtien. L'application permet aux utilisateurs de :

- Parcourir les restaurants locaux et leurs menus
- Passer des commandes (livraison à domicile ou pickup en restaurant)
- Payer via portefeuille numérique (dépôt MonCash, Tranzak, Natcash, carte bancaire)
- Gérer un profil KYC avec récompenses (livraison gratuite ou remise 6%)
- Transférer de l'argent en P2P (entre utilisateurs SagaEat, KYC requis)
- Recevoir des notifications push pour chaque étape de commande

**Monnaie:** Gourde haïtienne (HTG)  
**Langue UI:** Kreyòl ayisyen  
**Marché primaire:** Zone métropolitaine de Port-au-Prince (Carrefour, Delmas, Pétion-Ville, Croix-des-Bouquets, etc.)

---

## 2. Stack Technologique

### Flutter App (Client)

| Composant | Technologie | Version |
|---|---|---|
| Framework | Flutter | 3.x |
| Langage | Dart | ^3.11.4 |
| HTTP Client | Dio | ^5.8.0 |
| Auth Token Storage | flutter_secure_storage | ^9.2.4 |
| Préférences | shared_preferences | ^2.3.4 |
| Réseau | connectivity_plus | ^6.1.4 |
| Biométrie | local_auth | ^2.3.0 |
| QR Code | qr_flutter | ^4.1.0 |
| Image Picker | image_picker | ^1.1.2 |
| Notifications locales | flutter_local_notifications | ^18.0.0 |
| Permissions | permission_handler | ^11.3.0 |
| Design | Material Design 3 |  |

### Backend Attendu

| Composant | Technologie |
|---|---|
| Framework | Laravel 11 (PHP 8.2+) |
| Auth | Laravel Sanctum (token-based) |
| Base de données | MySQL 8.0 / MariaDB 10.11 |
| Fichiers | Laravel Storage (disk public) |
| Mail (OTP) | SMTP via Mailtrap (dev) / Brevo (prod) |
| Push Notifications | FCM (Firebase Cloud Messaging) |
| Paiement | MonCash (Digicel Business API) |
| Hosting | VPS Ubuntu 22.04 + Nginx + Certbot SSL |

### Configuration API

```dart
// lib/config/api_config.dart
baseUrl    : 'https://api.sagaeat.ht/api'
tokenKey   : 'auth_token'        // SecureStorage key
userIdKey  : 'user_id'           // SecureStorage key
timeout    : Duration(seconds: 30)
```

---

## 3. Architecture

```
lib/
├── config/
│   └── api_config.dart           # Constantes globales (URL, clés)
├── data/
│   ├── restaurant_data.dart      # RestaurantInfo model + données hardcodées
│   └── haiti_geo.dart            # Départements/Communes Haïti (hiérarchie)
├── models/
│   ├── cart_service.dart         # Panier (singleton statique)
│   ├── wallet_service.dart       # Portefeuille + transactions
│   ├── order_service.dart        # Commandes + statuts
│   ├── address_service.dart      # Adresses de livraison (max 3)
│   ├── kyc_service.dart          # Statut KYC + récompenses
│   ├── security_service.dart     # Biométrie toggle
│   ├── restaurant_follow_service.dart  # Restaurants favoris
│   └── food_item_model.dart      # FoodItem + ModifierGroup + ModifierOption
├── services/
│   ├── api_client.dart           # Dio singleton + auth interceptors
│   ├── auth_repository.dart      # Login/Register/OTP/Logout
│   ├── user_repository.dart      # Profil, photo, adresses CRUD
│   ├── wallet_repository.dart    # Balance, transactions, dépôt, transfert
│   ├── order_repository.dart     # Créer, historique, annuler commandes
│   ├── restaurant_repository.dart # Liste restau, menu, follow toggle
│   ├── kyc_repository.dart       # Upload KYC (multipart)
│   ├── notification_service.dart # Templates notifications locales
│   └── permission_service.dart   # Gestion permissions Android
└── screens/
    ├── splash_screen.dart
    ├── auth_screen.dart
    ├── home_screen.dart          # 4 onglets: Accueil/Recherche/Historique/Profil
    ├── cart_screen.dart
    ├── payment_screen.dart
    ├── wallet_screen.dart
    ├── kyc_screen.dart
    ├── product_description_screen.dart
    └── restaurant_detail_screen.dart
```

### Pattern de réactivité

Tous les services utilisent `ValueNotifier<T>` pour notifier l'UI en temps réel sans setState manuel :

```dart
WalletService.balanceNotifier     // ValueNotifier<double>
CartService.countNotifier         // ValueNotifier<int>
OrderService.countNotifier        // ValueNotifier<int>
KycService.verifiedNotifier       // ValueNotifier<bool>
KycService.rewardNotifier         // ValueNotifier<String?>
RestaurantFollowService.countNotifier // ValueNotifier<int>
AddressService.countNotifier      // ValueNotifier<int>
```

---

## 4. Écrans & Fonctionnalités

### 4.1 splash_screen.dart

**Rôle:** Écran de démarrage avec animation logo  
**Durée:** ~2.5 secondes → redirige vers `auth_screen.dart`  
**Données requises:** Aucune

---

### 4.2 auth_screen.dart

**Rôle:** Inscription et connexion utilisateur

#### Mode Connexion
| Champ | Type | Validation |
|---|---|---|
| Email | TextInput (email) | Format email valide |
| Mot de passe | TextInput (password) | Non vide |

#### Mode Inscription
| Champ | Type | Validation |
|---|---|---|
| Nom complet | TextInput | Non vide |
| Email | TextInput (email) | Format email valide |
| Téléphone | TextInput (tel) | Non vide |
| Date de naissance | Date picker | Date valide |
| Département | Dropdown | haiti_geo.dart |
| Commune | Dropdown | Filtré par département |
| Quartier/Zone | TextInput | Non vide |
| Détails maison | TextInput | Non vide |
| Mot de passe | TextInput | Non vide |
| Confirmer mot de passe | TextInput | Correspondance |

**Flux actuel:** Soumission → navigue directement vers `HomeScreen` (pas d'appel API réel)  
**Flux attendu:** Soumission → `AuthRepository.login()` ou `register()` → stocke token → navigue

**Autres liens:**
- "Mot de passe oublié" → flow OTP (send-otp → verify-otp → change-password)

---

### 4.3 home_screen.dart

**4 onglets via BottomNavigationBar:**

#### Onglet 0 — Accueil (Feed)
- **Bannière publicitaire** — carousel automatique (4 secondes) avec promotions restaurants
- **Filtres catégories** — 12 catégories: Tout, Bouyon, Burger, Pizza, Déjeuner, Diner, Souper, Spaghetti, Fritay, Pwason, Bwason, Salad
- **Carrousel menu horizontal** — plats filtrés par catégorie, avec images, prix, restaurant
- **Liste restaurants verticale** — triée par commune de l'utilisateur (Carrefour en haut si habitant Carrefour), avec mode (livraison/pickup/les deux), note, temps de livraison
- **Recherche globale** — accessible depuis la barre supérieure

#### Onglet 1 — Recherche
- Recherche par nom (plat ou restaurant)
- Filtres par catégorie (chips)
- Filtre commune (toggle "afficher seulement ma commune")
- Résultats: plats + restaurants correspondants

#### Onglet 2 — Historique
- Liste des commandes avec statut coloré (badge)
- Filtres statut: Tout / En cours / En préparation / En livraison / Livré / Annulé
- Filtre date (plage de dates)
- Timeline détaillée par commande (En cours → Préparation → Livraison → Livré)
- Détail items commandés par commande

#### Onglet 3 — Profil
- Photo de profil (picker caméra/galerie)
- Lien de référence (read-only, copyable): `www.sagaeat.com/ref=Nom+Prenom+jour+mois`
- Carte KYC (amber si non-vérifié, verte si vérifié)
- Restaurants suivis (scroll horizontal, tap → RestaurantDetail)
- Adresses de livraison (CRUD, max 3)
- Champs: Nom (lecture seule), Téléphone (modifiable), Email (lecture seule)
- Préférences alimentaires (multi-select par catégorie)
- Bouton "Enregistrer les changements"

#### Onglet 4 — Paramètres (hors nav bar, accessible via icône)
- **Accès Application:** Localisation / Caméra & Photos / Notifications Push (avec bouton "Activer" si non accordé)
- **Préférences:** Toggle notifications commandes, Tester notification promo (demo admin)
- **Sécurité:** Biométrie, changer mot de passe
- **Aide & Support**
- **Déconnecter**

---

### 4.4 restaurant_detail_screen.dart

**Paramètres reçus:** `RestaurantInfo restaurant`, `List<Map> menuItems`

**Fonctionnalités:**
- Header gradient avec photo/emoji restaurant + note + temps de livraison
- Badge mode (livraison/pickup/les deux)
- Bouton Suivre/Ne plus suivre (persiste via RestaurantFollowService)
- Galerie photos (3 images)
- Description
- Liste des plats (tap → ProductDescriptionScreen)
- Section avis clients (affichage + soumission note 1-5 étoiles + commentaire obligatoire)
- Zones de livraison (chips)

---

### 4.5 product_description_screen.dart

**Paramètres reçus:** `Map<String, dynamic> product`

**Structure produit:**
```dart
{
  'name': String,
  'restaurant': String,
  'image': String (URL),
  'price': double,
  'category': String,
  'desc': String,
  'supplements': List<Map> // [{name, price}]
}
```

**Fonctionnalités:**
- Image plat (réseau ou asset local)
- Sélection suppléments (toggle + prix additionnels)
- Sélecteur quantité (min 1)
- Calcul total: `(prix_base + total_suppléments) × quantité`
- Note allergie / restrictions (champ texte)
- Reviews précédents
- Bouton "Ajouter au panier" → `CartService.add(product, qty, total, supplements)`

---

### 4.6 cart_screen.dart

**Fonctionnalités:**
- Affichage items groupés par restaurant
- Modification quantité par item
- Suppression item
- **Calcul frais:**
  - Sous-total = somme des prix items
  - Frais livraison = somme frais par restaurant (150 HTG défaut)
  - Frais service = 6% × (sous-total + frais livraison)
  - Total = sous-total + livraison + service - remise coupon
- **Système coupon:** (3 codes hardcodés → à migrer backend)
  - `SAGA10` → 10% du sous-total
  - `BIENVENI` → 15% du sous-total
  - `VIP500` → 500 HTG fixe
- Bouton "Passer la commande" → `PaymentScreen(subtotal, serviceFee, deliveryFee, couponDiscount, couponCode)`

---

### 4.7 payment_screen.dart

**Paramètres reçus:** `subtotal`, `serviceFee`, `deliveryFee`, `couponDiscount`, `couponCode?`

**Fonctionnalités:**
- **Modes de livraison** par restaurant: livraison / pickup (toggle individuel)
  - Si pickup: sélection d'un restaurant pour retrait
  - Si livraison: validation zone de livraison (commune de l'adresse ∈ `deliveryZones` du restaurant)
- **Adresse de livraison:** sélection depuis AddressService ou nouvelle saisie
- **Téléphones:** Téléphone 1 (obligatoire), Téléphone 2 (optionnel)
- **Remise KYC:** appliquée si `KycService.hasUnusedReward`
  - `free_shipping` → déduit le frais livraison ajusté
  - `discount_6pct` → déduit 6% du sous-total dynamique
- **Méthodes de paiement:** Portefeuille SagaEat, Tranzak (Kaypa), MonCash, Natcash, Carte Bancaire
- **Authentification biométrique** (si activée dans sécurité) avant confirmation
- **Création commande** (1 commande par restaurant):
  - ID format: `sagaeat-{timestamp}-{random}-{P|D}` (P=Pickup, D=Delivery)
  - Appel `OrderService.add(OrderRecord)` pour chaque restaurant
  - Déclenche notification `orderEnCours` via NotificationService
  - Efface le panier et consomme la récompense KYC
- **Récapitulatif coûts:**
  ```
  Sous-total
  + Frais service (6%)
  + Frais livraison
  - Remise coupon
  - Remise KYC
  = Total
  ```

---

### 4.8 wallet_screen.dart

**Fonctionnalités:**

#### Balance
- Affichage en temps réel via `WalletService.balanceNotifier`
- QR Code du compte utilisateur (ID)

#### Dépôt (DepositSheet)
Méthodes affichées:
| Méthode | Couleur UI |
|---|---|
| Tranzak (Kaypa) | Bleu |
| MonCash | Rouge |
| Natcash | Vert |
| Carte Bancaire | Indigo |

Montant saisi → dialogue de confirmation → `WalletService.topUp()` + notification `depotFait`

#### Gift Card (GiftCardSheet)
- Scanner QR (simulé) ou saisie manuelle de code
- Validation: `SAGA-1000-HTG` / `SAGA-0500-HTG` / `SAGA-2500-HTG` / `SAGA-5000-HTG` / `DEMO-2026-XXX`
- Erreurs: `already_used`, `invalid`

#### Transfert P2P (TransferSheet)
- **KYC obligatoire** (dialog de blocage si non-vérifié)
- **Biométrie obligatoire** (si activée)
- Saisie: identifiant destinataire + montant
- Frais de transfert: 10 HTG (fixe)
- Confirmation avec récapitulatif complet
- `WalletService.transferSend(amount, recipient)`

#### Historique Transactions
- Filtres par type: Tout / Dépôt / Achat / Remboursement / Gift Card / Réception / Envoi
- Filtre plage de dates
- Affichage: montant coloré (vert crédit, rouge débit), description, date, peer si transfert

---

### 4.9 kyc_screen.dart

**6 étapes:**

| Étape | Contenu |
|---|---|
| 0 - Intro | Banner récompense (Livraison gratuite OU Remise 6%), description de l'utilité KYC |
| 1 - Infos personnelles | Nom, Prénom, Date de naissance, Lieu de naissance |
| 2 - Choix document | Carte Identité Nationale / Permis de Conduire / Passeport |
| 3 - Photos document | Recto (tous) + Verso (Carte Identité uniquement) |
| 4 - Selfie | Photo du visage en temps réel |
| 5 - Succès + Choix récompense | Animation 3 secondes → Dialog choix: Livraison Gratuite OU Remise 6% |

**Upload attendu:** Multipart FormData vers `POST /kyc/submit`
```
nom, prenom, date_naissance, lieu_naissance, doc_type,
doc_recto (file), doc_verso? (file), selfie (file)
```

---

## 5. Modèles de Données

### UserModel
```dart
class UserModel {
  final String id;
  final String name;        // Lecture seule (ne peut pas être modifié)
  final String email;       // Lecture seule
  final String phone;       // Modifiable
  final String birthDate;   // Format YYYY-MM-DD
  final UserAddress address;
}

class UserAddress {
  final String department;
  final String commune;
  final String city;        // Quartier/zone
  final String houseDetails;
  final double? latitude;
  final double? longitude;
}
```

### OrderRecord
```dart
class OrderRecord {
  final String orderId;
  final String restaurant;
  final List<Map<String, dynamic>> items;
  // item: {name, restaurant, image, unitPrice, suppTotal, quantity, total, supplements: [{name, price}]}
  final double subtotal;
  final double serviceFee;
  final double deliveryFee;
  final double couponDiscount;
  final double total;
  final String mode;        // 'pickup' | 'delivery'
  final DateTime createdAt;
  String status;            // 'En cours' | 'En préparation' | 'En livraison' | 'Livré' | 'Annulé'
  DateTime? tsPreparation;
  DateTime? tsLivraison;
  DateTime? tsLivre;
  DateTime? tsAnnule;
}
```

### WalletTransaction
```dart
class WalletTransaction {
  final String id;
  final String type;        // deposit | purchase | refund | gift_card | transfer_out | transfer_in
  final double amount;      // positif = crédit, négatif = débit
  final String description;
  final DateTime date;
  final String? orderId;
  final String? peer;       // email/username pour les transferts
}
```

### RestaurantInfo
```dart
class RestaurantInfo {
  final String name;
  final String emoji;
  final String address;
  final String commune;
  final String departement;
  final String desc;
  final double rating;
  final String deliveryTime;
  final List<String> dishes;
  final DeliveryMode mode;          // both | pickupOnly | deliveryOnly
  final List<String> deliveryZones; // communes desservies
  final double deliveryFee;
  final int tasteCount;
}
```

### FoodItem (Modèle API enrichi)
```dart
class FoodItem {
  final String id;
  final String name;
  final double basePrice;
  final List<ModifierGroup> modifierGroups;
}

class ModifierGroup {
  final String id;
  final String groupName;
  final bool isRequired;
  final int maxSelection;
  final List<ModifierOption> options;
}

class ModifierOption {
  final String id;
  final String name;
  final double extraPrice;
}
```

---

## 6. Services Internes

*État actuel: tous en mémoire. Doivent être connectés au backend.*

| Service | État | Responsabilité |
|---|---|---|
| `CartService` | In-memory | Items panier, calcul totaux, déduplication par (produit + restaurant + suppléments) |
| `WalletService` | In-memory | Balance, transactions, gift cards, transferts, frais 10 HTG |
| `OrderService` | In-memory | Historique commandes, mise à jour statuts |
| `AddressService` | In-memory | Adresses livraison (max 3), adresse par défaut |
| `KycService` | In-memory | Statut vérifié, récompense (`free_shipping`/`discount_6pct`), consommation récompense |
| `SecurityService` | In-memory | Toggle biométrie |
| `RestaurantFollowService` | In-memory | Restaurants suivis (Set par nom) |

---

## 7. Règles Métier

### 7.1 KYC
- **KYC pas requis pour commander** — les utilisateurs peuvent acheter sans KYC
- **KYC débloque une récompense** (une seule fois):
  - Livraison Gratuite: déduit `deliveryFee` au total
  - Remise 6%: déduit `sousTotal × 0.06`
- **Récompense à usage unique** — consommée à la confirmation de la première commande
- **KYC obligatoire pour les transferts P2P** (prévention fraude financière)

### 7.2 Panier & Commandes
- **Frais service:** 6% × (sous-total + frais livraison) — par restaurant
- **Frais livraison:** 150 HTG défaut, modifiable par restaurant
- **Déduplication:** même produit + même restaurant + mêmes suppléments → incrémente quantité
- **Groupement:** une commande créée par restaurant dans le panier
- **Validation zone livraison:** commune de l'adresse doit être dans `restaurant.deliveryZones`
- **Validation balance:** paiement wallet vérifie `WalletService.balance >= total`

### 7.3 Référence Lien
Format: `www.sagaeat.com/ref={Nom}+{Prenom}+{jourNaissance}+{moisNaissance}`  
Exemple: `www.sagaeat.com/ref=Dary+Sebastien+Petion+15+05`  
Read-only, copie dans presse-papier.

### 7.4 Modes de Livraison Restaurant
| Mode | Comportement |
|---|---|
| `both` | Utilisateur choisit livraison ou pickup |
| `pickupOnly` | Uniquement retrait en restaurant |
| `deliveryOnly` | Uniquement livraison (pas de zone pickup) |

### 7.5 Géographie Haïti
- 9 départements avec communes hiérarchisées dans `lib/data/haiti_geo.dart`
- Utilisé pour: sélecteur adresse (inscription + profil), filtrage restaurants par commune

### 7.6 Coupons
| Code | Type | Valeur |
|---|---|---|
| `SAGA10` | Pourcentage | 10% du sous-total |
| `BIENVENI` | Pourcentage | 15% du sous-total |
| `VIP500` | Montant fixe | 500 HTG |

### 7.7 Transfert Portefeuille
- Frais fixe: 10 HTG par transaction
- KYC obligatoire
- Biométrie obligatoire (si activée)
- Crée 2 transactions: `transfer_out` (envoyeur) + `transfer_in` (destinataire)

---

## 8. Contrat API (Backend Attendu)

Base URL: `https://api.sagaeat.ht/api`  
Auth: Bearer Token (Sanctum)  
Content-Type: `application/json` (sauf upload fichiers → `multipart/form-data`)

### 8.1 Auth (publique)

```
POST /auth/register
Body: { name, email, phone, password, birth_date, address: {department, commune, city, house_details} }
Response: { token, user: UserModel }

POST /auth/login
Body: { email, password }
Response: { token, user: UserModel }

POST /auth/send-otp
Body: { email }
Response: { message: "OTP envoyé" }

POST /auth/verify-otp
Body: { email, otp }
Response: { verified: true }

PUT /auth/change-password
Body: { email, otp, new_password }
Response: { message: "Mot de passe changé" }
```

### 8.2 Auth (protégée)

```
POST /auth/logout
Response: { message: "Déconnecté" }
```

### 8.3 Profil Utilisateur

```
GET /user/profile
Response: UserModel (avec adresses)

PUT /user/profile
Body: { phone? }
Response: UserModel mis à jour

POST /user/profile-photo
Body: multipart { photo: file }
Response: { photo_url: String }

GET /user/addresses
Response: List<UserAddress>

POST /user/addresses
Body: { department, commune, city, house_details, latitude?, longitude? }
Response: UserAddress créée

PUT /user/addresses/{id}
Body: { department?, commune?, city?, house_details? }
Response: UserAddress mise à jour

DELETE /user/addresses/{id}
Response: { message: "Supprimée" }
```

### 8.4 KYC

```
GET /kyc/status
Response: { status: 'pending'|'approved'|'rejected', submitted_at?: DateTime }

POST /kyc/submit
Body: multipart {
  nom, prenom, date_naissance (YYYY-MM-DD), lieu_naissance,
  doc_type: 'carte_identite'|'permis'|'passeport',
  doc_recto: file, doc_verso?: file, selfie: file
}
Response: { message: "Soumis avec succès", status: 'pending' }
```

### 8.5 Portefeuille

```
GET /wallet
Response: { balance: double, currency: 'HTG' }

GET /wallet/transactions
Query: ?type=&from=YYYY-MM-DD&to=YYYY-MM-DD&page=1
Response: { data: List<WalletTransaction>, total, per_page, current_page }

POST /wallet/deposit
Body: { amount: double, method: 'moncash'|'tranzak'|'natcash'|'card' }
Response: { redirect_url?: String, transaction_id: String }
// Si MonCash: retourne une URL de paiement
// Webhook POST /webhooks/moncash confirme et crédite

POST /wallet/redeem-gift-card
Body: { code: String }
Response: { amount: double, new_balance: double }
Errors: 422 { error: 'invalid'|'already_used' }

POST /wallet/transfer
Body: { to_user: String (email ou téléphone), amount: double }
Response: { transaction_id: String, new_balance: double }
Errors: 422 { error: 'insufficient'|'kyc_required'|'user_not_found' }
```

### 8.6 Restaurants & Menu

```
GET /restaurants
Query: ?commune=&page=1
Response: { data: List<RestaurantInfo>, ... }

GET /restaurants/{id}
Response: RestaurantInfo (avec delivery_zones)

GET /restaurants/{id}/menu
Query: ?category=
Response: List<Map> items
// item: {id, name, price, category, image, desc, restaurant, supplements: [{name, price}]}

POST /restaurants/{id}/follow
Response: { following: bool, taste_count: int }
```

### 8.7 Commandes

```
POST /orders
Body: {
  restaurant_id: int,
  items: [{ menu_item_id, name, quantity, unit_price, supplements: [{name, price}] }],
  mode: 'delivery'|'pickup',
  subtotal: double,
  service_fee: double,
  delivery_fee: double,
  coupon_discount: double,
  total: double,
  delivery_address?: { department, commune, city, house_details },
  phone1: String,
  phone2?: String,
  coupon_code?: String
}
Response: OrderRecord (avec status: 'pending')

GET /orders
Query: ?status=&from=&to=&page=1
Response: { data: List<OrderRecord>, ... }

GET /orders/{id}
Response: OrderRecord (détail complet)

POST /orders/{id}/cancel
Response: { message: "Annulée", refund_amount: double }

POST /orders/{id}/confirm-pickup
Response: { message: "Pickup confirmé", status: 'delivered' }

POST /orders/{id}/confirm-delivery
Response: { message: "Livraison confirmée", status: 'delivered' }
```

### 8.8 Coupons

```
POST /coupons/validate
Body: { code: String, cart_total: double }
Response: { type: 'percentage'|'fixed', value: double, discount: double }
Errors: 422 { error: 'invalid'|'expired'|'already_used' }
```

### 8.9 Notifications (Webhooks FCM)

Événements déclenchant une notification push vers le client:

| Événement | Déclencheur backend |
|---|---|
| Commande reçue | Création order |
| En préparation | Statut → `preparing` |
| En livraison | Statut → `delivering` |
| Livrée | Statut → `delivered` |
| Annulée + remboursement | Statut → `cancelled` |
| Dépôt crédité | Webhook MonCash confirmé |
| Argent reçu (P2P) | `transfer_in` créé |
| Code promo admin | Super admin → sélection ciblée (sexe, age, commune, catégories suivies) |

---

## 9. Notifications

Service: `lib/services/notification_service.dart`  
Canal Android: `sagaeat_channel` (importance HIGH)

### Templates

#### Commandes avec Livraison

| Statut | Titre | Corps |
|---|---|---|
| En cours | "Kòmand Resevwa ✅" | "Ou komande {qty} {plat} [ki gen kom sipleman {supps}] nan {restoran}" |
| En préparation | "Manje ap Prepare 👨‍🍳" | "{restoran} ap prepare {qty} {plat}. Disponib nan mwens ke {temps}" |
| En livraison | "Manje nan Livrezon 🛵" | "{restoran} fini prepare {plat}. Li nan livrezon, pran yon ti pasyans" |
| Annulée | "Kòmand Anile ❌" | "Malerezman {restoran} anile kòmand ou an, kòb la ap monte sou kont ou" |
| Remboursement | "Ranbousman Resevwa 💚" | "{qty} {plat} anile, ou gen {montant} HTG ki retounen sou kont ou" |

#### Commandes avec Pickup

| Statut | Corps |
|---|---|
| En préparation | "{restoran} ap prepare {plat}... N ap envite w komanse prepare w pou pase pran kòmand lan" |

#### Portefeuille

| Événement | Titre | Corps |
|---|---|---|
| Dépôt | "Depo Reyisi 💰" | "Ou fè yon depo {amount} HTG sou kont ou, pa bliye manje se lavi!" |
| Argent reçu | "Kòb Resevwa 🎉" | "Jounen an son bèl jounen paske {sender} voye {amount} kob pou ou pou achte manje sou Sagaeat" |
| Code promo | "Pwomo Espesyal 🎁" | Message personnalisé par super admin |

---

## 10. Permissions Android

Déclarées dans `android/app/src/main/AndroidManifest.xml`:

| Permission | Utilisation |
|---|---|
| `INTERNET` | Toutes les requêtes API |
| `ACCESS_NETWORK_STATE` | Vérification connectivité |
| `CAMERA` | Photo profil, KYC documents |
| `READ_MEDIA_IMAGES` | Galerie photos (Android 13+) |
| `READ_EXTERNAL_STORAGE` (maxSdk 32) | Galerie photos (Android 12-) |
| `USE_BIOMETRIC` | Authentification biométrique |
| `USE_FINGERPRINT` | Empreinte digitale (ancien API) |
| `ACCESS_FINE_LOCATION` | Géolocalisation utilisateur |
| `ACCESS_COARSE_LOCATION` | Géolocalisation approximative |
| `POST_NOTIFICATIONS` | Notifications push (Android 13+) |
| `RECEIVE_BOOT_COMPLETED` | Notifications planifiées |
| `SCHEDULE_EXACT_ALARM` | Alarmes précises (notifications) |

Demandées à l'exécution via `PermissionService.requestAll()` au premier lancement de HomeScreen.

---

## 11. État Actuel & Chemin vers Production

### Ce qui est terminé ✅
- 9 écrans Flutter 100% complets (UI + logique)
- Système de navigation et transitions
- API layer Flutter (6 repositories + Dio + interceptors auth)
- Notifications locales (8 templates)
- Gestion permissions Android
- Sérialisation JSON (`fromJson`/`toJson`) sur tous les modèles
- Biométrie, KYC flow, récompenses
- Suivi restaurants, lien référence

### Ce qui est hardcodé (à migrer backend) ⚠️
| Donnée | Localisation actuelle |
|---|---|
| 4 restaurants | `lib/data/restaurant_data.dart` → `allRestaurantData` |
| ~12 items menu | `home_screen.dart` → `allMenuItems` |
| 3 codes coupon | `cart_screen.dart` → dictionnaire local |
| 5 codes gift card | `wallet_service.dart` → `_giftCardCodes` |
| Solde initial 7 500 HTG | `wallet_service.dart` → `_balance` |
| Données utilisateur | `home_screen.dart` → hardcodé "Dary Sebastien Petion" |

### Bloqueurs pour lancement public ❌
1. **Backend Laravel inexistant** — aucune persistence de données
2. **MonCash non intégré** — dépôts/paiements non fonctionnels
3. **FCM absent** — pas de push notifications serveur
4. **Release signing Android** — `debugSigningConfig` utilisé pour release (bloqueur Play Store)

### Corrections rapides (avant Play Store)
```kotlin
// android/app/build.gradle.kts
// ❌ Actuel:
signingConfig = signingConfigs.getByName("debug")
// ✅ Corriger: créer keystore release et configurer release signingConfig
```
```xml
<!-- AndroidManifest.xml — supprimer cette ligne: -->
android:requestLegacyExternalStorage="true"
```

### Feuille de route backend (8-10 semaines)
```
S1-S2:  Laravel setup + MySQL + Auth (register/login/OTP) → Flutter AuthScreen connecté
S3-S4:  Restaurants + Menu API + Seeders → HomeScreen depuis API réelle
S5-S6:  Orders + Wallet API → PaymentScreen + WalletScreen connectés
S7:     MonCash sandbox → dépôts réels testés
S8:     FCM push notifications → alertes commandes temps réel
S9-S10: VPS + Nginx + SSL + Play Store alpha (20-50 testeurs)
```

---

*Document généré le 2026-05-29 · SagaEat v1.0 Flutter*  
*Maintenu par: équipe SagaEat*
