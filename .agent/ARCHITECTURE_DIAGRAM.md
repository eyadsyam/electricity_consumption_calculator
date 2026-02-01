# 📐 Architecture Diagram

## Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Pages      │  │ Controllers  │  │   Widgets    │      │
│  │  (Screens)   │  │   (GetX)     │  │  (UI Only)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         ↓                  ↓                  ↓              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Use Cases   │  │  Entities    │  │ Repositories │      │
│  │ (Business    │  │  (Models)    │  │ (Interfaces) │      │
│  │   Logic)     │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         ↓                  ↑                  ↑              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Repositories │  │    Models    │  │ Data Sources │      │
│  │    (Impl)    │  │  (DTO/JSON)  │  │ Local/Remote │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         ↓                  ↓                  ↓              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     Hive     │  │   Supabase   │  │     APIs     │      │
│  │   (Local)    │  │   (Remote)   │  │  (External)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Core Layer (Cross-Cutting)

```
┌─────────────────────────────────────────────────────────────┐
│                        CORE LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Animations  │  │    Theme     │  │   Widgets    │      │
│  │  - Transitions│  │  - Colors    │  │  - Animated  │      │
│  │  - Controllers│  │  - Styles    │  │  - Common    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Errors     │  │   Network    │  │    Utils     │      │
│  │  - Failures  │  │  - Checker   │  │  - Validators│      │
│  │  - Exceptions│  │  - Monitor   │  │  - Formatters│      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐                                           │
│  │  Constants   │                                           │
│  │  - App       │                                           │
│  │  - Config    │                                           │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌─────────┐
│  USER   │
└────┬────┘
     │ Interacts
     ↓
┌─────────────────┐
│  UI (Widget)    │ ← Animations, Theme, Widgets
└────┬────────────┘
     │ Triggers Event
     ↓
┌─────────────────┐
│  Controller     │ ← State Management (GetX)
└────┬────────────┘
     │ Calls
     ↓
┌─────────────────┐
│   Use Case      │ ← Business Logic
└────┬────────────┘
     │ Uses
     ↓
┌─────────────────┐
│  Repository     │ ← Interface (Domain)
└────┬────────────┘
     │ Implemented by
     ↓
┌─────────────────┐
│ Repository Impl │ ← Implementation (Data)
└────┬────────────┘
     │ Calls
     ↓
┌─────────────────┐
│  Data Source    │ ← Local (Hive) / Remote (Supabase)
└────┬────────────┘
     │ Returns
     ↓
┌─────────────────┐
│  Data/Error     │
└─────────────────┘
```

## Feature Structure

```
features/
└── electricity_tracking/
    ├── data/
    │   ├── datasources/
    │   │   ├── local/
    │   │   │   └── reading_local_datasource.dart
    │   │   └── remote/
    │   │       └── reading_remote_datasource.dart
    │   ├── models/
    │   │   ├── reading_model.dart
    │   │   └── bill_model.dart
    │   └── repositories/
    │       └── electricity_repository_impl.dart
    │
    ├── domain/
    │   ├── entities/
    │   │   ├── reading.dart
    │   │   ├── bill.dart
    │   │   └── monthly_budget.dart
    │   ├── repositories/
    │   │   └── electricity_repository.dart
    │   └── usecases/
    │       ├── add_reading.dart
    │       ├── get_readings.dart
    │       ├── calculate_bill.dart
    │       ├── delete_reading.dart
    │       └── manage_budget.dart
    │
    └── presentation/
        ├── controllers/
        │   ├── home_controller.dart
        │   ├── readings_controller.dart
        │   └── budget_controller.dart
        ├── pages/
        │   ├── home_page.dart
        │   ├── readings_page.dart
        │   └── budget_page.dart
        └── widgets/
            ├── balance_card.dart
            ├── reading_card.dart
            └── budget_indicator.dart
```

## Dependency Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   Dependency Rule                            │
│                                                              │
│  Outer layers depend on inner layers                        │
│  Inner layers know nothing about outer layers               │
│                                                              │
│  Presentation → Domain → Data → External                    │
│                                                              │
│  ✅ Presentation can use Domain                             │
│  ✅ Data can use Domain                                     │
│  ❌ Domain cannot use Data                                  │
│  ❌ Domain cannot use Presentation                          │
└─────────────────────────────────────────────────────────────┘
```

## Animation System Flow

```
┌─────────────┐
│   Widget    │
└──────┬──────┘
       │ Wraps with
       ↓
┌─────────────────────┐
│ Animation Controller│
└──────┬──────────────┘
       │ Applies
       ↓
┌─────────────────────┐
│  Tween Animation    │
└──────┬──────────────┘
       │ Creates
       ↓
┌─────────────────────┐
│  Visual Effect      │
│  - Slide            │
│  - Fade             │
│  - Scale            │
│  - Rotate           │
└─────────────────────┘
```

## State Management Flow (GetX)

```
┌─────────────┐
│  UI Event   │
└──────┬──────┘
       │ Triggers
       ↓
┌─────────────────────┐
│   Controller        │
│   - Observables     │
│   - Methods         │
└──────┬──────────────┘
       │ Calls
       ↓
┌─────────────────────┐
│    Use Case         │
└──────┬──────────────┘
       │ Returns
       ↓
┌─────────────────────┐
│  Either<Failure, T> │
└──────┬──────────────┘
       │ Updates
       ↓
┌─────────────────────┐
│   Observable        │
└──────┬──────────────┘
       │ Notifies
       ↓
┌─────────────────────┐
│   UI Rebuilds       │
│   (Obx/GetX)        │
└─────────────────────┘
```

## Error Handling Flow

```
┌─────────────────┐
│  Data Source    │
└────┬────────────┘
     │ Throws
     ↓
┌─────────────────┐
│   Exception     │ (CacheException, ServerException, etc.)
└────┬────────────┘
     │ Caught by
     ↓
┌─────────────────┐
│  Repository     │
└────┬────────────┘
     │ Converts to
     ↓
┌─────────────────┐
│    Failure      │ (CacheFailure, ServerFailure, etc.)
└────┬────────────┘
     │ Wrapped in
     ↓
┌─────────────────┐
│  Either<F, T>   │
└────┬────────────┘
     │ Handled by
     ↓
┌─────────────────┐
│   Controller    │
└────┬────────────┘
     │ Shows
     ↓
┌─────────────────┐
│  Error Widget   │
└─────────────────┘
```

## Benefits of This Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        BENEFITS                              │
│                                                              │
│  ✅ Testability       - Easy to unit test each layer        │
│  ✅ Maintainability   - Clear separation of concerns        │
│  ✅ Scalability       - Easy to add new features            │
│  ✅ Flexibility       - Easy to change implementations      │
│  ✅ Reusability       - Components can be reused            │
│  ✅ Independence      - Layers are independent              │
│  ✅ Clarity           - Clear structure and flow            │
└─────────────────────────────────────────────────────────────┘
```
