# 🚀 Quick Reference Guide

## Import Everything

```dart
import 'package:finalproject/core/core.dart';
```

## 🎭 Animations

### Page Transitions
```dart
// Navigate with animation
Navigator.push(
  context,
  AppPageTransitions.createRoute(
    page: DetailPage(),
    transitionsBuilder: AppPageTransitions.slideFromRight,
  ),
);
```

### List Animations
```dart
// Staggered list
StaggeredListAnimation.createStaggeredItem(
  index: index,
  child: ListTile(title: Text('Item $index')),
)

// Staggered grid
StaggeredListAnimation.createStaggeredGridItem(
  index: index,
  crossAxisCount: 2,
  child: GridTile(child: Text('Item $index')),
)
```

### Widget Animations
```dart
// Shimmer loading
ShimmerLoading(
  child: Container(height: 100, color: Colors.white),
)

// Pulse
PulseAnimation(child: Icon(Icons.favorite))

// Bounce
BounceAnimation(child: Icon(Icons.check))

// Slide in
SlideAnimationController.slideInFromBottom(
  child: MyWidget(),
)

// Fade in
FadeAnimationController.fadeIn(
  child: MyWidget(),
)

// Scale up
ScaleAnimationController.scaleUp(
  child: MyWidget(),
)
```

## 🎨 Widgets

### Buttons
```dart
AnimatedButton(
  text: 'Submit',
  icon: Icons.check,
  onPressed: () {},
  isLoading: false,
)
```

### Cards
```dart
AnimatedCard(
  onTap: () {},
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      Text('Content'),
    ],
  ),
)
```

### Containers
```dart
// Glass morphism
GlassMorphismContainer(
  blur: 10,
  opacity: 0.1,
  child: Text('Glass effect'),
)

// Gradient
GradientContainer(
  colors: [Colors.blue, Colors.purple],
  child: Text('Gradient background'),
)
```

### Info Display
```dart
InfoCard(
  icon: Icons.electric_bolt,
  title: 'Total Consumption',
  value: '1,234 kWh',
  iconColor: AppColors.primary,
)
```

### States
```dart
// Loading
CustomLoadingIndicator(size: 40)

// Empty
EmptyStateWidget(
  icon: Icons.inbox,
  title: 'No Data',
  subtitle: 'Add some data to get started',
  action: AnimatedButton(
    text: 'Add Data',
    onPressed: () {},
  ),
)

// Error
ErrorStateWidget(
  message: 'Failed to load data',
  onRetry: () {},
)
```

### Other
```dart
// Badge
CustomBadge(
  text: 'New',
  backgroundColor: AppColors.success,
)

// Divider with text
DividerWithText(text: 'OR')
```

## 🎨 Colors

```dart
// Primary colors
AppColors.primary
AppColors.primaryLight
AppColors.primaryDark

// Secondary colors
AppColors.secondary
AppColors.secondaryLight
AppColors.secondaryDark

// Accent colors
AppColors.accent
AppColors.accentLight
AppColors.accentDark

// Status colors
AppColors.success
AppColors.warning
AppColors.error
AppColors.info

// Neutral colors
AppColors.textPrimaryLight
AppColors.textSecondaryLight
AppColors.textPrimaryDark
AppColors.textSecondaryDark

// Background colors
AppColors.backgroundLight
AppColors.backgroundDark
AppColors.surfaceLight
AppColors.surfaceDark
AppColors.cardLight
AppColors.cardDark

// Gradients
AppColors.primaryGradient
AppColors.secondaryGradient
AppColors.accentGradient
AppColors.successGradient
```

## 🎯 Constants

```dart
// App info
AppConstants.appName
AppConstants.appVersion

// API
AppConstants.apiBaseUrl
AppConstants.apiTimeout

// Storage
AppConstants.readingsBoxName
AppConstants.historyBoxName
AppConstants.budgetKeyPrefix

// UI
AppConstants.defaultPadding
AppConstants.defaultBorderRadius
AppConstants.defaultElevation
AppConstants.animationDuration
AppConstants.maxReadingValue
AppConstants.minReadingValue

// Electricity rates
AppConstants.electricityRates
```

## 🛠️ Utils

### Validators
```dart
// Email
Validators.validateEmail('test@example.com')

// Phone
Validators.validatePhone('+201234567890')

// Reading
Validators.validateReading('1234')

// Budget
Validators.validateBudget('500')

// Name
Validators.validateName('John Doe')

// Required
Validators.validateRequired('value', 'Field')
```

### Date Formatter
```dart
// Format date
DateFormatter.formatDate(DateTime.now())

// Format date with time
DateFormatter.formatDateTime(DateTime.now())

// Format month year
DateFormatter.formatMonthYear(DateTime.now())

// Get month name
DateFormatter.getMonthName(DateTime.now())
```

## 🌐 Network

```dart
// Check connection
final networkInfo = NetworkInfoImpl(Connectivity());
final isConnected = await networkInfo.isConnected;

// Listen to changes
networkInfo.onConnectivityChanged.listen((isConnected) {
  if (isConnected) {
    print('Connected');
  } else {
    print('Disconnected');
  }
});
```

## 🏗️ Use Cases

```dart
// Create use case
class MyUseCase extends UseCase<ReturnType, Params> {
  final MyRepository repository;
  
  MyUseCase(this.repository);
  
  @override
  Future<Either<Failure, ReturnType>> call(Params params) async {
    return await repository.doSomething(params);
  }
}

// Use it
final result = await myUseCase(params);
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (data) => print('Success: $data'),
);
```

## ❌ Error Handling

```dart
// Throw exception
throw ServerException('Failed to fetch data');

// Convert to failure
try {
  await datasource.getData();
} on ServerException {
  return Left(ServerFailure('Failed to fetch data'));
} on CacheException {
  return Left(CacheFailure('Failed to load cached data'));
}

// Handle in UI
result.fold(
  (failure) {
    if (failure is ServerFailure) {
      showError('Server error');
    } else if (failure is CacheFailure) {
      showError('Cache error');
    }
  },
  (data) => showData(data),
);
```

## 🎨 Theme

```dart
// Use theme
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)

// Access theme
final theme = Theme.of(context);
final textStyle = theme.textTheme.titleLarge;
final primaryColor = theme.colorScheme.primary;
```

## 📱 Common Patterns

### Loading State
```dart
Obx(() {
  if (controller.isLoading.value) {
    return CustomLoadingIndicator();
  }
  if (controller.error.value != null) {
    return ErrorStateWidget(
      message: controller.error.value!,
      onRetry: controller.retry,
    );
  }
  if (controller.data.isEmpty) {
    return EmptyStateWidget(
      icon: Icons.inbox,
      title: 'No Data',
    );
  }
  return ListView.builder(
    itemCount: controller.data.length,
    itemBuilder: (context, index) {
      return StaggeredListAnimation.createStaggeredItem(
        index: index,
        child: AnimatedCard(
          child: ListTile(
            title: Text(controller.data[index].title),
          ),
        ),
      );
    },
  );
})
```

### Form with Validation
```dart
final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: Column(
    children: [
      TextFormField(
        validator: Validators.validateEmail,
        decoration: InputDecoration(labelText: 'Email'),
      ),
      SizedBox(height: 16),
      AnimatedButton(
        text: 'Submit',
        onPressed: () {
          if (formKey.currentState!.validate()) {
            // Submit
          }
        },
      ),
    ],
  ),
)
```

### Navigation with Animation
```dart
void navigateToDetail() {
  Navigator.push(
    context,
    AppPageTransitions.createRoute(
      page: DetailPage(),
      transitionsBuilder: AppPageTransitions.slideFromRight,
    ),
  );
}
```

## 🎯 Tips

1. **Always use const** where possible
2. **Import from core/core.dart** for all core utilities
3. **Use animations** for better UX
4. **Handle all states**: loading, error, empty, success
5. **Validate inputs** before processing
6. **Use Either** for error handling
7. **Follow clean architecture** principles
8. **Write tests** for business logic
9. **Document complex code**
10. **Keep widgets small** and focused

## 📚 More Info

- See `PROJECT_STRUCTURE.md` for folder organization
- See `UI_UX_GUIDE.md` for detailed UI guidelines
- See `ARCHITECTURE_DIAGRAM.md` for visual diagrams
- See `IMPROVEMENTS_SUMMARY.md` for what's new
