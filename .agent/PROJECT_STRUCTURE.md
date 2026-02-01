# Flutter Project Structure - Clean Architecture

## 📁 Folder Organization

```
lib/
├── core/                           # Core functionality (framework-agnostic)
│   ├── animations/                 # Animation utilities
│   │   ├── animated_widgets.dart   # Reusable animated widgets
│   │   ├── animation_controllers.dart # Animation controllers
│   │   └── page_transitions.dart   # Page transition animations
│   │
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart      # All constants in one place
│   │
│   ├── errors/                     # Error handling
│   │   ├── exceptions.dart         # Custom exceptions
│   │   └── failures.dart           # Failure classes
│   │
│   ├── network/                    # Network utilities
│   │   └── network_info.dart       # Network connectivity checker
│   │
│   ├── theme/                      # App theming
│   │   ├── app_colors.dart         # Color palette
│   │   └── app_theme.dart          # Theme configuration
│   │
│   ├── usecases/                   # Base use case
│   │   └── usecase.dart            # UseCase abstract class
│   │
│   ├── utils/                      # Utility functions
│   │   ├── date_formatter.dart     # Date formatting
│   │   └── validators.dart         # Input validators
│   │
│   └── widgets/                    # Reusable widgets
│       ├── animated_widgets.dart   # Custom animated widgets
│       └── common_widgets.dart     # Common UI components
│
├── features/                       # Feature modules
│   ├── electricity_tracking/       # Main feature
│   │   ├── data/                   # Data layer
│   │   │   ├── datasources/        # Data sources
│   │   │   │   ├── local/          # Local data (Hive)
│   │   │   │   └── remote/         # Remote data (Supabase)
│   │   │   ├── models/             # Data models
│   │   │   └── repositories/       # Repository implementations
│   │   │
│   │   ├── domain/                 # Domain layer (business logic)
│   │   │   ├── entities/           # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/           # Use cases
│   │   │
│   │   └── presentation/           # Presentation layer
│   │       ├── controllers/        # GetX controllers
│   │       ├── pages/              # Screen pages
│   │       └── widgets/            # Feature-specific widgets
│   │
│   ├── profile/                    # Profile feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── complaints/                 # Complaints feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── config/                         # App configuration
│   ├── routes/                     # Route definitions
│   │   └── app_routes.dart
│   └── bindings/                   # Dependency injection
│       └── app_bindings.dart
│
└── main.dart                       # App entry point
```

## 🎯 Layer Responsibilities

### Core Layer
- **Purpose**: Framework-agnostic utilities and base classes
- **Dependencies**: None (except Flutter SDK)
- **Contains**: Animations, constants, errors, theme, utils, widgets

### Domain Layer
- **Purpose**: Business logic and rules
- **Dependencies**: None (pure Dart)
- **Contains**: Entities, repository interfaces, use cases

### Data Layer
- **Purpose**: Data management and external communication
- **Dependencies**: Domain layer
- **Contains**: Models, datasources, repository implementations

### Presentation Layer
- **Purpose**: UI and user interaction
- **Dependencies**: Domain layer
- **Contains**: Controllers, pages, widgets

## 📋 File Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE` or `camelCase` (for const)
- **Private**: Prefix with underscore `_privateName`

## 🎨 Animation System

### Available Animations

1. **Page Transitions**
   - Fade
   - Slide (from right, left, top, bottom)
   - Scale
   - Combined (slide + fade)

2. **Widget Animations**
   - Staggered list/grid
   - Shimmer loading
   - Pulse
   - Bounce

3. **Custom Animations**
   - Slide controllers
   - Fade controllers
   - Scale controllers
   - Rotation controllers

### Usage Example

```dart
// Page transition
Navigator.push(
  context,
  AppPageTransitions.createRoute(
    page: MyPage(),
    transitionsBuilder: AppPageTransitions.slideFromRight,
  ),
);

// Staggered list
StaggeredListAnimation.createStaggeredItem(
  index: index,
  child: MyWidget(),
);

// Animated button
AnimatedButton(
  text: 'Submit',
  onPressed: () {},
  icon: Icons.check,
);
```

## 🎨 Widget Library

### Available Widgets

1. **Animated Widgets**
   - `AnimatedCard`: Card with hover and tap effects
   - `AnimatedButton`: Button with scale animation
   - `GlassMorphismContainer`: Glass effect container
   - `GradientContainer`: Gradient background container

2. **Common Widgets**
   - `CustomLoadingIndicator`: Loading spinner
   - `EmptyStateWidget`: Empty state display
   - `ErrorStateWidget`: Error state display
   - `CustomBadge`: Badge component
   - `DividerWithText`: Divider with centered text
   - `InfoCard`: Information display card

## 🚀 Best Practices

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Rule**: Dependencies point inward (toward domain)
3. **Testability**: Business logic is isolated and testable
4. **Reusability**: Common code in core, feature-specific in features
5. **Consistency**: Follow naming conventions and folder structure
6. **Performance**: Use const constructors where possible
7. **Animations**: Use provided animation system for consistency

## 📦 Migration Guide

### Moving Existing Files

1. **UI Components** → `lib/features/[feature]/presentation/widgets/`
2. **Business Logic** → `lib/features/[feature]/domain/usecases/`
3. **Data Models** → `lib/features/[feature]/data/models/`
4. **Utilities** → `lib/core/utils/`
5. **Theme** → `lib/core/theme/`
6. **Constants** → `lib/core/constants/`

### Example Migration

```
Old: lib/elec.dart
New: lib/features/electricity_tracking/presentation/pages/home_page.dart

Old: lib/calculateBill.dart
New: lib/features/electricity_tracking/domain/usecases/calculate_bill.dart

Old: lib/themeService.dart
New: lib/core/theme/theme_service.dart
```

## 🎯 Next Steps

1. ✅ Core layer setup (DONE)
2. ✅ Domain layer setup (DONE)
3. ✅ Animation system (DONE)
4. ✅ Widget library (DONE)
5. ⏳ Data layer implementation
6. ⏳ Presentation layer refactoring
7. ⏳ Route configuration
8. ⏳ Dependency injection setup
9. ⏳ Testing setup
10. ⏳ Documentation
