# 24CS2016 – Building Applications using Flutter

**Ex. No. 8 — Firestore Data Retrieval**
Reg No: URK23CS5015

## Aim

To design and implement a Flutter application that retrieves information from Google Cloud Firestore based on user search input and displays the corresponding records dynamically.

## Description

Google Cloud Firestore is a NoSQL, document-oriented cloud database. The cloud_firestore plugin lets a Flutter app query collections of documents directly from the client. A common pattern for "search as you type" style name lookups in Firestore is a prefix range query: ordering the collection by the target field and bounding it with startAt(query) and endAt('$query\uf8ff'), where \uf8ff is a very high Unicode code point that sorts after virtually any normal character, so every document whose field starts with the typed prefix falls inside the range.

This experiment implements a People Search screen backed by a people collection in Firestore. A PeopleRepository service wraps the query (ordered by name, bounded with startAt/endAt, limited to 20 results, with a request timeout so a slow or unreachable backend fails fast instead of hanging). The SearchScreen holds a TextField bound to the query, triggers the repository call when the user submits, and renders the results in a ListView of PersonTile cards. Three explicit UI states are handled: the initial "type a query" prompt, a loading spinner while the query is in flight, and an error/empty state. Because this submission does not have a live Firebase project attached (firebase_options.dart ships with placeholder credentials and a comment telling the student to run flutterfire configure), the app detects the placeholder configuration before even calling Firebase.initializeApp and shows a clear 'Firebase not configured' banner instead of crashing or hanging — once a real project is connected the exact same search code will return live documents.

## Run it

```bash
cd code
flutter pub get
flutter run -d chrome   # or an Android device/emulator
```

## Contents

- `code/` — Flutter project source
- `screenshots/` — real output screenshots
- `record_spec.json` / `record.pdf` — lab record document (see `scripts/gen_record.py` to regenerate)
