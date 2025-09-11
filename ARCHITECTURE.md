# Project Architecture

## Clean Architecture + BLoC Pattern

This project follows **Clean Architecture** principles with **BLoC (Business Logic Component)** pattern for state management.

### 🏗️ Architecture Layers

```
lib/
├── core/                           # Core Layer
│   ├── config/                    # Environment & configuration
│   │   └── env_config.dart
│   ├── constants/                 # App-wide constants
│   │   └── app_constants.dart
│   ├── error/                     # Error handling
│   │   └── failures.dart
│   ├── exceptions/                # Exception definitions
│   │   └── exceptions.dart
│   ├── services/                  # Core services
│   │   └── navigation_service.dart
│   ├── usecases/                  # Use case abstractions
│   │   └── usecase.dart
│   └── utils/                     # Utilities
│       ├── logger.dart
│       └── validators.dart
├── data/                          # Data Layer
│   ├── data_provider/            # Data sources
│   │   ├── local_data_source.dart
│   │   └── remote_data_source.dart
│   ├── mappers/                   # Data ↔ Domain mapping
│   │   └── auth_mappers.dart
│   ├── models/                    # Data models
│   │   ├── auth/
│   │   └── errors/
│   └── repositories/              # Repository implementations
│       ├── auth_repository_impl.dart
│       └── setting_repository_impl.dart
├── domain/                        # Business Logic Layer
│   ├── entities/                 # Domain entities
│   │   ├── auth_response.dart
│   │   └── user.dart
│   ├── repositories/             # Repository contracts
│   │   ├── auth_repository.dart
│   │   └── setting_repository.dart
│   └── usecases/                 # Business use cases
│       ├── auth/
│       └── setting/
└── presentation/                  # Presentation Layer
    ├── bloc/                     # State management
    │   ├── auth/
    │   ├── internet_status/
    │   └── cubit/
    ├── routes/                   # Navigation
    ├── screens/                  # UI screens
    ├── utils/                    # UI utilities
    └── widgets/                  # Reusable UI components
```

### 🔄 Data Flow

1. **Presentation Layer** (UI) triggers events
2. **BLoC/Cubit** handles business logic
3. **Use Cases** execute business rules
4. **Repository Interface** defines contracts
5. **Repository Implementation** coordinates data sources
6. **Data Sources** fetch/store data
7. **Mappers** convert between layers
8. **Models/Entities** represent data

### 🎯 Key Principles

#### SOLID Principles ✅
- **S**RP: Each class has a single responsibility
- **O**CP: Open for extension, closed for modification
- **L**SP: Repository implementations are substitutable
- **I**SP: Interfaces are segregated by feature
- **D**IP: Dependencies are inverted through abstractions

#### Clean Architecture Rules ✅
- **Dependency Rule**: Dependencies point inward
- **Layer Separation**: Clear boundaries between layers
- **Framework Independence**: Business logic is independent
- **Testability**: Each layer can be tested in isolation

### 🏛️ Architecture Components

#### Core Layer
- **Configuration**: Environment-specific settings
- **Constants**: App-wide constants and configurations
- **Error Handling**: Centralized error management
- **Services**: Cross-cutting concerns (navigation, logging)
- **Utilities**: Helper functions and validators

#### Data Layer
- **Data Sources**: Remote API and local storage
- **Models**: Data transfer objects
- **Mappers**: Convert between data models and domain entities
- **Repository Implementations**: Concrete data access logic

#### Domain Layer
- **Entities**: Core business objects
- **Repository Interfaces**: Data access contracts
- **Use Cases**: Business logic encapsulation

#### Presentation Layer
- **BLoC/Cubit**: State management and UI logic
- **Screens**: UI components
- **Widgets**: Reusable UI elements
- **Routes**: Navigation configuration

### 🧪 Benefits of This Architecture

1. **Maintainability**: Clear separation of concerns
2. **Testability**: Each layer can be tested independently
3. **Scalability**: Easy to add new features
4. **Flexibility**: Can change frameworks without affecting business logic
5. **Reusability**: Use cases can be reused across different UI components
6. **Error Handling**: Centralized and consistent error management

### 🔧 Development Guidelines

#### Adding New Features
1. Create domain entity (if needed)
2. Define repository interface
3. Implement repository
4. Create use case
5. Implement BLoC/Cubit
6. Build UI screens/widgets

#### Testing Strategy
- **Unit Tests**: Use cases, repositories, validators
- **Widget Tests**: UI components
- **Integration Tests**: Feature flows
- **Mock Dependencies**: Use interfaces for testing

### 📱 State Management

Uses **BLoC Pattern** with:
- **Events**: User interactions and system events
- **States**: UI states (loading, loaded, error)
- **BLoC/Cubit**: Business logic coordinators

### 🚀 Getting Started

1. Set environment in `main.dart`
2. Configure API endpoints in `env_config.dart`
3. Update constants in `app_constants.dart`
4. Follow the established patterns for new features
