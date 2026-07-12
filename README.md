# HelpDesk Lite - Internal Support Ticketing System

HelpDesk Lite is a lightweight, responsive corporate internal support ticketing application designed in Flutter. It replaces unstructured request channels with organized queues, clear assignments, and status visibility.

## 🚀 Key Features
- **Role-Based Workspaces**: Customized dashboards and actions for **Employees**, **Support Agents**, and **Managers**.
- **Self-Service Ticketing**: Submission of support tickets with priority levels (Low, Medium, High, Urgent) and service categories.
- **Assigned Queue Routing**: Support agents can claim requests from the global unassigned pool, route assignments, and update ticket statuses.
- **Visual Analytics**: Interactive manager metrics dashboard tracking workloads and status distributions.
- **Integrated Activity logs**: Unread badged notification drawers alert users of assignment modifications and status changes.
- **Fully Responsive**: Adapts fluidly from Mobile phone bottom nav bars to Desktop sidebar grids.

---

## 🛠️ Architecture & Folder Structure

This application conforms to strict software engineering standards:
- **Clean Architecture**: Separates the codebase into `Data` (Models, Repositories Impl), `Domain` (Entities, Repositories Interfaces, Use Cases), and `Presentation` (BLoCs, UI Screens).
- **Feature-First Organization**: Grouped inside logical domains (`auth`, `tickets`, `dashboard`, `notifications`) for high modularity.
- **State Management**: Orchestrated via `flutter_bloc`.
- **Dependency Injection**: Decoupled constructor bindings configured with `get_it`.
- **Routing**: Session-guarded navigation rules governed by `go_router`.

```
lib/
├── main.dart                      # App initialization & MultiBlocProviders
├── core/                          # Cross-cutting layers
│   ├── di/                        # get_it Dependency Injection container
│   ├── error/                     # Failure structures (Server, Cache, Validation)
│   ├── router/                    # go_router configuration & redirect auth guard
│   ├── theme/                     # Material 3 colors and typography theme system
│   ├── utils/                     # Validators for forms
│   └── widgets/                   # Reusable UI shells, buttons, and state handlers
└── features/                      # Business feature packages
    ├── auth/                      # Authentication Feature (Login, Logout, Session check)
    ├── dashboard/                 # Analytics Panels for Employees, Support, and Managers
    ├── notifications/             # Activity logs and badged headers
    └── tickets/                   # Ticket creation, detail controls, search, and filtering
```

---

## 📂 Pre-configured Roles & Accounts

The Version 1 mock repository supports persistent session caching using `SharedPreferences`. You can use these accounts to sign in immediately:

| Role | Username / Email | Password | Details |
| :--- | :--- | :--- | :--- |
| **Employee** | `employee@company.com` | `password123` | Can submit requests, view status logs, and close resolved items. |
| **Support Staff** | `support@company.com` | `password123` | Can view unassigned queues, claim tickets, reassign agents, and update statuses. |
| **Manager** | `manager@company.com` | `password123` | Can oversee all metrics, charts, ticket pools, and re-allocate support workloads. |

---

## 🔧 Setup & Running Guide

### Prerequisites
- Flutter SDK (>= 3.12.2)
- Dart SDK

### Installation & Run
1. Fetch and install package dependencies:
   ```bash
   flutter pub get
   ```
2. Launch the application:
   ```bash
   flutter run
   ```

### Running Tests
To execute repository, BLoC, and widget tests:
```bash
flutter test
```
