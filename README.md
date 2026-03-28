# 📱 Offline Task Manager (Flutter)

An **offline-first task management app** built with Flutter using Hive for local storage and a custom sync engine to synchronize data with a backend server.

---

## 🚀 Features

* ✅ Create, update, and delete tasks
* 📦 Offline-first architecture (works without internet)
* 🔄 Automatic background sync when network is restored
* 🧠 Queue-based sync system (ADD / UPDATE / DELETE)
* ⚡ Lightweight local database using Hive
* 🌐 REST API integration with backend

---

## 🏗️ Architecture

```
User Action
   ↓
Local Storage (Hive)
   ↓
Sync Queue (ADD / UPDATE / DELETE)
   ↓
Network Available
   ↓
Backend Sync (Express API)
   ↓
Fetch Latest Data → Update Local DB
```

---

## 🛠️ Tech Stack

* Flutter
* Dart
* Hive (Local Database)
* Connectivity Plus
* HTTP Package

---

## 📂 Project Structure

```
lib/
│
├── db/
│   ├── dataBaseServices.dart
│   └── syncOperations.dart
│
├── services/
│   └── engine.dart
│
├── models/
│   └── task.dart
│
└── screens/
    └── homescreen.dart
```

---

## ⚙️ Setup Instructions

1. Clone the repository

```bash
git clone <your-flutter-repo-url>
cd <project-folder>
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure backend IP

Update your `.env` file:

```
address=YOUR_LOCAL_IP
```

4. Run the app

```bash
flutter run
```

---

## 🔄 Sync Logic

* All operations are stored in a **queue (Hive box)**
* When internet is available:

  * Operations are processed sequentially
  * Successful operations are removed from the queue
* After sync:

  * Local database is refreshed from backend

---


## 👨‍💻 Author

Developed as a learning project to understand:

* Offline-first systems
* Sync mechanisms
* Local + remote data consistency

---
