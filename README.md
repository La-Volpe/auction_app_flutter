# 🚗 Car Auction App Documentation

Welcome to the official documentation for the Car Auction App! This document provides a complete overview of the project's architecture, design choices, and functionality.

## 1. Overall Architecture 🏛️

The app is built using a simplified **Clean Architecture** approach. This structure is designed to be easy to understand, scalable, and maintainable. The core idea is to separate concerns, making the codebase clean and robust.

The data flow is straightforward: each feature has its own dedicated module containing:
* **Data Layer**: Handles data sources, like API calls or local storage.
* **BLoC (Business Logic Component)**: Manages the state and business logic for the feature.
* **View Layer**: The UI that users interact with, which receives data from the BLoC and sends user events to it.

Here's a breakdown of the main feature modules:

| Module | Description | Key Components |
| :--- | :--- | :--- |
| **Authentication** | Handles user login, session management, and storing credentials securely. | `AuthScreen`, `AuthBloc`, `MockAuthService`, `FlutterSecureStorage`. |
| **Main/Navigation** | The central hub after login, managing the main app layout and navigation between screens. | `MainScreen`, `AppBottomNavBar`. |
| **Search** | Allows users to search for vehicles using a Vehicle Identification Number (VIN). It handles input validation, communicates with the data source, and displays results. | `SearchScreen`, `SearchBloc`, `CosChallenge` (for mock data). |
| **Auction** | Displays the details of a specific auction item and allows users to place bids. | `AuctionScreen`. |
| **Profile** | Shows the logged-in user's information and provides a logout option. | `ProfileScreen`, `ProfileBloc`. |

## 2. Important Decisions & Trade-offs 🤔

The guiding principle behind the technical decisions in this project is: **"Code should be easy to understand, change, fix, scale, and maintain for developers."**

### Using BLoC for State Management

The BLoC (Business Logic Component) pattern was chosen for state management. It provides a robust and mature way to handle application state by separating UI from business logic.

* **How it Works**: UI components send events to the BLoC, the BLoC processes the logic and emits new states, and the UI rebuilds itself in response to these state changes.
* **Implementation**: In `main.dart`, `MultiBlocProvider` is used to make BLoCs like `AuthBloc`, `SearchBloc`, and `ProfileBloc` available throughout the widget tree.

Here's a look at the pros and cons of this approach:

| Pros 👍 | Cons 👎 |
| :--- | :--- |
| **Separation of Concerns**: Keeps business logic neatly separated from the UI code, making both easier to test and manage. | **Boilerplate Code**: Can sometimes lead to creating multiple files for events, states, and the BLoC itself, which can feel verbose for simpler features. |
| **Testability**: Because logic is isolated, BLoCs can be unit-tested independently of the UI. | **Learning Curve**: New developers might find the reactive stream-based nature of BLoC a bit complex at first. |
| **Predictable State Management**: The flow of `Event -> BLoC -> State` makes it clear how and why the UI is changing, which is great for debugging. | |
| **Maturity & Tooling**: BLoC is a well-documented pattern with excellent tooling and a strong community. The `flutter_bloc` package makes implementation straightforward. | |

## 3. How Things Work ⚙️

Here is a step-by-step walkthrough of the primary user journey in the app.

### Step 1: User Authentication 🔐

1.  **Login Screen**: The user starts at the `AuthScreen`, where they enter their email and password. Input fields have built-in validation for email format and password length.
2.  **Sending Credentials**: When the user presses "Login", the `AuthLoginRequested` event is sent to the `AuthBloc`.
3.  **Authentication Logic**: The `AuthBloc` uses `MockAuthService` to verify the credentials.
4.  **Session Management**: On successful authentication, the `AuthBloc` receives a token, which it saves securely to the device using `FlutterSecureStorage`. This allows the user to stay logged in even after closing the app. The user is then navigated to the main screen.
5.  **Persistent Login**: On subsequent app starts, `AuthBloc` checks for a saved token to automatically log the user in.

### Step 2: VIN Search 🔍

1.  **Search UI**: The user interacts with the `SearchScreen`, which contains a form to enter a 17-character VIN.
2.  **VIN Validation**: Before submitting, the VIN is validated in the `SearchBloc` to ensure it is 17 characters long and contains only valid characters (A-Z, 0-9, excluding I, O, Q). The UI also has its own validation layer for immediate user feedback.
3.  **API Request**: A `VinSubmitted` event triggers the `SearchBloc` to make a network request using the provided `CosChallenge.httpClient`. A unique user ID is passed in the request headers, as required.
4.  **Handling Responses**: The `SearchBloc` is designed to handle different HTTP responses from the mock client:
    * **Success (Single Item)**: If a single auction item is found, the response body is parsed into an `AuctionData` object and displayed in a card. A bug in the mock server's JSON response is fixed on the fly before parsing.
    * **Success (Multiple Items)**: If multiple choices are returned, they are parsed into a list of `AuctionDataChoice` objects and displayed for the user.
    * **Errors**: The app handles various errors gracefully, including timeouts, authentication failures, and other server errors. It displays a user-friendly error message with suggestions for resolution.

### Step 3: Viewing Auction Details  gavel

* From the search results, if a single auction is found, the user can tap "View Auction".
* This navigates them to the `AuctionScreen`, passing along the item's details like UUID, model, and price.
* On the `AuctionScreen`, the user can see the auction details and place a bid.

## 4. Future Improvements ✨

If more time were allocated to this project, here are some areas I would focus on improving:
* **Caching Strategy**:
    * **What**: Implement caching for VIN search results.
    * **Why**: To reduce redundant network requests if a user searches for the same VIN multiple times. This would improve performance and reduce data usage.
    * **How**: Integrate a simple caching mechanism (like an in-memory map or a more robust solution like `hive` or `sembast`) within the `SearchBloc` or data layer.

* **CI/CD (Continuous Integration/Continuous Deployment)**:
    * **What**: Set up automated pipelines for building, testing, and deploying the app.
    * **Why**: To streamline the development lifecycle, ensure code quality with automated tests, and make releases faster and more reliable.
    * **How**: Use tools like GitHub Actions or Codemagic to create workflows that trigger on code pushes, run `flutter analyze` and `flutter test`, and build release versions of the app.

* **UI/UX Polishing**:
    * **What**: Enhance the user interface and experience.
    * **Why**: A polished UI is more engaging and easier to use.
    * **How**:
        * Add subtle animations and transitions between screens.
        * Improve visual feedback for user actions (e.g., more interactive buttons, better loading indicators).
        * Conduct user testing to identify and address any usability pain points in the app flow.
        * Refine the layout on the `SearchScreen` and `ProfileScreen` for better readability and aesthetics.

* **Migration to go_router**:
    * **What**: Replace manual navigation with go_router.
    * **Why**: go_router offers better type safety, declarative navigation, and support for code generation.
    * **How**: Refactor route handling using GoRoute, GoRouter, and URL-based deep linking, moving navigation logic out of UI widgets for improved modularity.

* **Improved Dependency Management**:
    * **What**: Use a Flutter-first DI solution instead of relying on generic approaches.
    * **Why**: To simplify testing, improve readability, and align better with Flutter architecture patterns.
    * **How**: Adopt a more Flutter-native tool like get_it, riverpod, or flutter_modular, ensuring clear separation of concerns and ease of integration.

* **Write More Tests**:
    * **What**: Increase coverage for UI, bloc, and repository logic.
    * **Why**: To catch regressions early and build confidence in future refactors.
    * **How**: Add widget tests for major screens, bloc tests using bloc_test, and repository tests with mocked data sources.

* **Decouple Classes**:
    * **What**: Separate tightly coupled components.
    * **Why**: To improve testability, maintainability, and reusability.
    * **How**: Extract responsibilities into smaller units, use interfaces and dependency injection, and follow SOLID principles.