# Flutter Template Project – Clean Architecture with BLoC

This Flutter template project implements Clean Architecture with the BLoC state management pattern. The architecture enforces a clear separation of concerns, improves testability, and keeps the UI independent from business logic and data sources.

## 🏗️ Architecture Overview

### Clean Architecture Layers (Outer to Inner)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  • UI (Screens, Widgets)                                    │
│  • State Management (BLoC/Cubit)                            │
│  • Routes & Navigation                                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│  • Entities (Business Objects)                              │
│  • Use Cases (Business Rules)                               │
│  • Repository Interfaces                                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
│  • Repository Implementations                               │
│  • Data Sources (Remote/Local)                              │
│  • Models & Mappers                                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       CORE LAYER                            │
│  • Base Classes                                             │
│  • Failures & Exceptions                                    │
│  • Utilities                                                │
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
│   │       ├── login_model.dart          # Login request model
│   │       └── user_response_model.dart  # API response model
│   └── repositories/
│       ├── auth_repository_impl.dart     # Auth repository implementation
│       └── setting_repository_impl.dart  # Settings repository implementation
│
├── presentation/                   # UI Layer
│   ├── bloc/
│   │   ├── auth/
│   │   │   ├── login_bloc.dart     # Authentication BLoC
│   │   │   ├── login_event.dart    # Login events
│   │   │   └── login_state.dart    # Login states
│   │   └── internet_status/
│   │       ├── internet_status_bloc.dart  # Network connectivity BLoC
│   │       ├── internet_status_event.dart # Network events
│   │       └── internet_status_state.dart # Network states
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
│   └── exceptions/                # Infrastructure exceptions & UI errors
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

## 🔄 Complete API Flow: UI to Backend and Back

Here's the detailed step-by-step flow showing exactly which functions are called in which files during a login operation:

### 📱 Login Flow (UI → API → UI)

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USER INTERACTION                          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│  1. UI LAYER (Presentation)                                            │
│     📄 File: lib/presentation/screens/authentication/login_screen.dart │
│     🔧 Function: User taps login button                                │
│     📤 Action: context.read<LoginBloc>().add(LoginEventSubmit())       │
└────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  2. BLOC LAYER (State Management)                                   │
│     📄 File: lib/presentation/bloc/auth/login_bloc.dart             │
│     🔧 Function: _onLoginSubmit()  [Line 68-102]                    │
│     📤 Actions:                                                     │
│        • emit(LoginLoading())                                       │
│        • Create LoginParams(email, password)                        │
│        • Call: await _loginUseCase(params)                          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  3. USE CASE LAYER (Business Logic)                                 │
│     📄 File: lib/domain/usecases/auth/login_usecase.dart            │
│     🔧 Function: call()  [Line 15-20]                               │
│     📤 Action: return repository.login(email, password)             │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  4. REPOSITORY IMPLEMENTATION (Data Orchestration)                  │
│     📄 File: lib/data/repositories/auth_repository_impl.dart        │
│     🔧 Function: login()  [Line 22-38]                              │
│     📤 Actions:                                                     │
│        • Create LoginStateModel(email, password)                    │
│        • Call: remoteDataSources.login(loginModel)                  │
│        • Call: localDataSources.cacheUserResponse(result)           │
│        • Return: Right(result.toDomain())  [mapper conversion]      │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  5. REMOTE DATA SOURCE (API Layer)                                  │
│     📄 File: lib/data/data_provider/remote_data_source.dart         │
│     🔧 Function: login()  [Line 34-40]                              │
│     📤 Actions:                                                     │
│        • Uri.parse(RemoteUrls.login)                                │
│        • client.post(uri, body: body.toMap(), headers: headers)     │
│        • NetworkParser.callClientWithCatchException()               │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  6. NETWORK PARSER (HTTP Response Handling)                         │
│     📄 File: lib/data/data_provider/network_parser.dart             │
│     🔧 Function: callClientWithCatchException()  [Line 16-37]       │
│     🔧 Function: _responseParser()  [Line 39-85]                    │
│     📤 Actions:                                                     │
│        • Handle HTTP status codes (200, 400, 401, 422, 500, etc.)   │
│        • Parse JSON response or throw specific exceptions           │
│        • Return parsed response data                                │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  🌐 EXTERNAL API SERVER                                             │
│     🔧 Processes HTTP POST request                                  │
│     📤 Returns JSON response with user data or error                │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  7. RESPONSE PROCESSING (Data Transformation)                       │
│     📄 File: lib/data/mappers/auth_mappers.dart                     │
│     🔧 Function: toDomain()  [Line 19-27]                           │
│     📤 Actions:                                                     │
│        • Convert UserResponseModel → AuthResponse (domain entity)   │
│        • Convert nested UserResponse → User (domain entity)         │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  8. LOCAL STORAGE (Cache Management)                                │
│     📄 File: lib/data/data_provider/local_data_source.dart          │
│     🔧 Function: cacheUserResponse()  [Line 40-43]                  │
│     📤 Action: sharedPreferences.setString(key, userModel.toJson()) │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  9. BLOC STATE EMISSION (UI Update)                                 │
│     📄 File: lib/presentation/bloc/auth/login_bloc.dart             │
│     🔧 Function: _onLoginSubmit()  [Line 92-94]                     │
│     📤 Actions:                                                     │
│        • _user = authResponse                                       │
│        • emit(LoginLoaded(authResponse: authResponse))              │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  10. UI UPDATE (Screen Rebuild)                                         │
│     📄 File: lib/presentation/screens/authentication/login_screen.dart  │
│     🔧 Function: BlocListener/BlocBuilder rebuilds                      │
│     📤 Actions:                                                         │
│        • Hide loading indicator                                         │
│        • Navigate to main screen or show error message                  │
└─────────────────────────────────────────────────────────────────────────┘
```

### 🔄 Error Handling Flow

When errors occur, they follow this path:

```
API Error (422, 401, 500) → NetworkParser._responseParser() 
                         → Throws specific exception (InvalidInputException, UnauthorisedException) 
                         → AuthRepositoryImpl.login() catches exception
                         → Returns Left(ServerFailure/InvalidAuthDataFailure)
                         → LoginBloc._onLoginSubmit() handles Either result
                         → Emits error state (LoginError/LoginFormValidationError)
                         → UI shows error message
```

### 📊 Key Function Calls Summary

| Layer | File | Key Function | Line | Purpose |
|-------|------|--------------|------|----------|
| **Presentation** | `login_bloc.dart` | `_onLoginSubmit()` | 68-102 | Handle login event, orchestrate flow |
| **Domain** | `login_usecase.dart` | `call()` | 15-20 | Execute business rule |
| **Data** | `auth_repository_impl.dart` | `login()` | 22-38 | Coordinate data operations |
| **Data** | `remote_data_source.dart` | `login()` | 34-40 | Make HTTP request |
| **Data** | `network_parser.dart` | `callClientWithCatchException()` | 16-37 | Handle HTTP response/errors |
| **Data** | `auth_mappers.dart` | `toDomain()` | 19-27 | Convert data model to domain entity |
| **Data** | `local_data_source.dart` | `cacheUserResponse()` | 40-43 | Store user data locally |

### 💾 Data Transformation Points

1. **UI Input** → `LoginParams` (domain object)
2. **LoginParams** → `LoginStateModel` (data model for API)
3. **API Response JSON** → `UserResponseModel` (data model)
4. **UserResponseModel** → `AuthResponse` (domain entity) ✨ **[Mapper]**
5. **AuthResponse** → UI state (`LoginLoaded`)

### 🎯 Dependency Flow

```
LoginBloc depends on → LoginUseCase
                   depends on → AuthRepository (interface)
                               implemented by → AuthRepositoryImpl
                                           depends on → RemoteDataSource & LocalDataSource
                                                   implemented by → RemoteDataSourceImpl & LocalDataSourceImpl
```

## 🔄 How Authentication Works (Legacy Description)

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

## 📋 Architecture Notes

- **Clean Architecture**: The project follows Robert C. Martin's Clean Architecture principles
- **SOLID Compliance**: Each layer adheres to SOLID principles for maintainable, testable code
- **Layer Independence**: Domain layer is completely independent of external frameworks
- **Dependency Injection**: All dependencies are injected through the DI container
- **State Management**: Uses BLoC pattern with clean separation between events, states, and business logic

### ✨ Code Cleanup (Resolved Duplication Issue)

**Problem**: There were duplicate BLoC/Cubit implementations:
- `lib/logic/bloc/` and `lib/logic/cubit/` (Legacy pattern)
- `lib/presentation/bloc/` and `lib/presentation/cubit/` (Clean Architecture pattern)

**Solution**: 
- ❌ **Removed** `lib/logic/` folder completely
- ✅ **Moved** `InternetStatusBloc` to `lib/presentation/bloc/internet_status/`
- ✅ **Updated** all imports to use Clean Architecture pattern
- ✅ **Created** new `LoginModel` to replace legacy `LoginStateModel`
- ✅ **Fixed** all references to use new clean implementations

**Result**: Single source of truth with proper Clean Architecture structure!

## 🎯 Benefits of This Architecture

- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Easy to unit test business logic without UI dependencies  
- **Independence**: UI, database, and external services can be changed independently
- **Scalability**: Easy to add new features following established patterns
- **Maintainability**: Clear structure makes code easier to understand and modify
- **Team Development**: Multiple developers can work on different layers simultaneously

## 🧭 SOLID Principles in This Architecture

This project follows SOLID principles through its Clean Architecture structure and layering:

- Single Responsibility Principle (SRP)
  - Each component has one reason to change:
    - Use cases (e.g., lib/domain/usecases/auth/login_usecase.dart) encapsulate one business action.
    - Entities (lib/domain/entities/) model domain data only.
    - Repository interfaces (lib/domain/repositories/) define contracts.
    - Repository implementations (lib/data/repositories/) handle data orchestration and mapping.
    - Data sources (lib/data/data_provider/) focus on a single IO concern each (remote vs local).
    - BLoC/Cubit classes (lib/presentation/bloc/, lib/presentation/cubit/) manage UI state for one feature.

- Open/Closed Principle (OCP)
  - The system is open for extension but closed for modification:
    - Add a new feature by creating new entity, use case, repository interface/impl, data source methods, and BLoC without changing existing code.
    - Dependency wiring occurs in lib/dependency_injection.dart, allowing you to extend behavior by registering new implementations rather than editing consumers.

- Liskov Substitution Principle (LSP)
  - High-level code depends on abstractions and remains valid if implementations are swapped:
    - Use cases depend on AuthRepository/SettingRepository interfaces (lib/domain/repositories/).
    - Concrete implementations (e.g., lib/data/repositories/auth_repository_impl.dart) can be replaced (e.g., different APIs, caching) without breaking callers.

- Interface Segregation Principle (ISP)
  - Clients depend on focused interfaces rather than “fat” ones:
    - Separate repository interfaces per bounded context (auth_repository.dart, setting_repository.dart) keep contracts small and specific.
    - Presentation depends on use cases, not broad service classes, avoiding unused methods.

- Dependency Inversion Principle (DIP)
  - High-level policies do not depend on low-level details:
    - Presentation → Use cases → Repository interfaces (abstractions) → Data layer provides concrete implementations.
    - lib/dependency_injection.dart inverts control by supplying concrete types to abstract dependencies at composition time.

---

**Happy Coding!** 🚀
