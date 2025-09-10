# Flutter Template Project – Clean Architecture with BLoC

This Flutter template project implements Clean Architecture with the BLoC state management pattern. The architecture enforces a clear separation of concerns, improves testability, and keeps the UI independent from business logic and data sources.

## 🏗️ Architecture Overview

### Clean Architecture Layers (Outer to Inner)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  • UI (Screens, Widgets)                                   │
│  • State Management (BLoC/Cubit)                           │
│  • Routes & Navigation                                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                          │
│  • Entities (Business Objects)                             │
│  • Use Cases (Business Rules)                              │
│  • Repository Interfaces                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                           │
│  • Repository Implementations                              │
│  • Data Sources (Remote/Local)                             │
│  • Models & Mappers                                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       CORE LAYER                           │
│  • Base Classes                                            │
│  • Failures & Exceptions                                   │
│  • Utilities                                               │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow
```
UI (BLoC/Cubit) → Use Cases → Repository Interfaces → Repository Implementations → Data Sources
```

## 📁 Project Structure

```
lib/
├── core/                           # Cross-cutting concerns
│   ├── error/
│   │   └── failures.dart           # Failure types (Server, Database, Network, etc.)
│   └── usecases/
│       └── usecase.dart            # Base UseCase classes
│
├── domain/                         # Business Logic Layer
│   ├── entities/
│   │   ├── user.dart               # User business entity
│   │   └── auth_response.dart      # Authentication response entity
│   ├── repositories/
│   │   ├── auth_repository.dart    # Authentication repository interface
│   │   └── setting_repository.dart # Settings repository interface
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── logout_usecase.dart
│       │   └── get_existing_user_info_usecase.dart
│       └── setting/
│           └── get_setting_usecase.dart
│
├── data/                           # Data Layer
│   ├── data_provider/
│   │   ├── local_data_source.dart  # Local storage (SharedPreferences)
│   │   ├── remote_data_source.dart # HTTP API calls
│   │   ├── network_parser.dart     # HTTP response parsing
│   │   └── remote_url.dart         # API endpoints
│   ├── mappers/
│   │   └── auth_mappers.dart       # Data ↔ Domain entity mappers
│   ├── models/
│   │   └── auth/
│   │       ├── login_state_model.dart    # Login request model
│   │       └── user_response_model.dart  # API response model
│   └── repositories/
│       ├── auth_repository_impl.dart     # Auth repository implementation
│       └── setting_repository_impl.dart  # Settings repository implementation
│
├── presentation/                   # UI Layer
│   ├── bloc/
│   │   └── auth/
│   │       ├── login_bloc.dart     # Authentication BLoC
│   │       ├── login_event.dart    # Login events
│   │       └── login_state.dart    # Login states
│   ├── cubit/
│   │   └── setting/
│   │       ├── setting_cubit.dart  # Settings Cubit
│   │       └── setting_state.dart  # Settings states
│   ├── screens/                    # UI screens
│   │   ├── authentication/         # Auth screens (login, signup, etc.)
│   │   ├── main_screen/           # Main app screen
│   │   ├── on_boarding/           # Onboarding screens
│   │   └── splash/                # Splash screen
│   ├── widgets/                   # Reusable UI components
│   ├── routes/                    # App routing
│   ├── utils/                     # UI utilities and constants
│   └── errors/                    # Error handling models
│
├── logic/                         # Legacy layer (to be migrated)
│   ├── bloc/                      # Existing BLoCs
│   ├── cubit/                     # Existing Cubits
│   └── repository/                # Legacy repositories
│
├── dependency_injection.dart       # Dependency injection setup
├── dependency_injection_packages.dart # DI exports
└── main.dart                       # App entry point
```

## 🔧 Key Components Explained

### Domain Layer

**Entities**: Pure business objects with no dependencies on Flutter or external frameworks.
```dart
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  // ...
}
```

**Use Cases**: Encapsulate business rules and application-specific logic.
```dart
class LoginUseCase implements UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;
  
  Future<Either<Failure, AuthResponse>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}
```

**Repository Interfaces**: Define contracts for data operations.
```dart
abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({required String email, required String password});
  // ...
}
```

### Data Layer

**Repository Implementations**: Implement domain repository interfaces.
```dart
class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  
  Future<Either<Failure, AuthResponse>> login({required String email, required String password}) {
    // Implementation with error handling and data mapping
  }
}
```

**Data Sources**: Handle external data (API calls, local storage).
**Mappers**: Convert between data models and domain entities.

### Presentation Layer

**BLoC/Cubit**: Manage UI state using use cases (not repositories directly).
```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  
  LoginBloc({required LoginUseCase loginUseCase}) : _loginUseCase = loginUseCase;
}
```

## 🔄 How Authentication Works

1. **UI** dispatches `LoginEventSubmit(email, password, rememberMe)`
2. **LoginBloc** calls `LoginUseCase` with parameters
3. **LoginUseCase** calls `AuthRepository.login()`
4. **AuthRepositoryImpl** uses `RemoteDataSource` to make API call
5. **Response** is mapped from data models to domain entities
6. **Result** is emitted back to UI through BLoC states

## 🏭 Dependency Injection

The DI system is organized in layers:

```dart
// Core dependencies
RepositoryProvider<Client>(create: (context) => Client())

// Data sources
RepositoryProvider<RemoteDataSource>(create: (context) => RemoteDataSourceImpl(...))

// Repository implementations  
RepositoryProvider<AuthRepository>(create: (context) => AuthRepositoryImpl(...))

// Use cases
RepositoryProvider<LoginUseCase>(create: (context) => LoginUseCase(...))

// BLoCs/Cubits
BlocProvider<LoginBloc>(create: (context) => LoginBloc(loginUseCase: context.read()))
```

## ➕ Adding New Features

### 1. Domain Layer
```dart
// 1. Create entity
class Product extends Equatable { ... }

// 2. Create repository interface
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}

// 3. Create use case
class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;
  // ...
}
```

### 2. Data Layer
```dart
// 1. Create data model
class ProductModel { ... }

// 2. Create mapper
extension ProductModelMapper on ProductModel {
  Product toDomain() => Product(...);
}

// 3. Update data sources
abstract class RemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

// 4. Implement repository
class ProductRepositoryImpl implements ProductRepository {
  // Implementation using data sources and mappers
}
```

### 3. Presentation Layer
```dart
// 1. Create BLoC/Cubit
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase _getProductsUseCase;
  // ...
}

// 2. Create events and states
abstract class ProductEvent extends Equatable { ... }
abstract class ProductState extends Equatable { ... }
```

### 4. Update Dependency Injection
```dart
// Add to repositoryProvider list
RepositoryProvider<ProductRepository>(
  create: (context) => ProductRepositoryImpl(...),
),
RepositoryProvider<GetProductsUseCase>(
  create: (context) => GetProductsUseCase(context.read()),
),

// Add to blocProviders list
BlocProvider<ProductBloc>(
  create: (context) => ProductBloc(getProductsUseCase: context.read()),
),
```

## 🧪 Testing Strategy

- **Unit Tests**: Test use cases, entities, and mappers in isolation
- **Widget Tests**: Test UI components with mocked BLoCs
- **Integration Tests**: Test complete feature flows
- **Repository Tests**: Test data layer with mocked data sources

## 📦 Dependencies

### State Management
- `flutter_bloc` - BLoC pattern implementation
- `equatable` - Value equality for states and events

### Functional Programming
- `dartz` - Either type for error handling

### Network & Storage
- `http` - HTTP client
- `shared_preferences` - Local storage
- `connectivity_plus` - Network connectivity

### UI & Styling
- `flutter_screenutil` - Responsive design
- `google_fonts` - Custom fonts
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching

### Utilities
- `intl` - Internationalization

## 🚀 Getting Started

1. **Clone the repository**
```bash
git clone <repository-url>
cd flutter-template-project
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

4. **Run tests**
```bash
flutter test
```

5. **Analyze code**
```bash
flutter analyze
```

## 📋 Migration Notes

- Legacy code under `logic/` directory is preserved for backward compatibility
- New features should use the Clean Architecture structure under `domain/`, `data/`, and `presentation/`
- Gradually migrate existing features to the new architecture when making updates
- The dependency injection system supports both old and new patterns during transition

## 🎯 Benefits of This Architecture

- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Easy to unit test business logic without UI dependencies  
- **Independence**: UI, database, and external services can be changed independently
- **Scalability**: Easy to add new features following established patterns
- **Maintainability**: Clear structure makes code easier to understand and modify
- **Team Development**: Multiple developers can work on different layers simultaneously

---

**Happy Coding!** 🚀
