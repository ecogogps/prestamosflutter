# Project Blueprint

## Overview
A simple Flutter application that demonstrates basic navigation and UI structure for user authentication.

## Style, Design, and Features

### Initial Setup
- Standard Flutter counter application.

### v1.1 - Authentication Flow
- **Navigation:** Implemented `go_router` for declarative navigation between screens.
- **Screens:**
    - **Home Screen (`/`):** A landing page with prominent "Login" and "Register" buttons.
    - **Login Screen (`/login`):** A modern form with fields for email and password, a primary login button, and a secondary link to the register screen. The UI includes icons and rounded borders for a better user experience.
    - **Register Screen (`/register`):** A form for user registration with fields for email, password, and password confirmation. It includes a primary registration button and a link back to the login screen.
- **UI:** The interface uses Material Design 3 components. Forms are designed to be user-friendly with clear labels, icons, and responsive layout for different screen sizes.

## Current Change: Add Login/Register Flow

### Plan
1.  **Add Dependency:** Add the `go_router` package to `pubspec.yaml` to handle navigation.
2.  **Create Screens:**
    - Create `lib/screens/login_screen.dart` to build the user login interface.
    - Create `lib/screens/register_screen.dart` to build the user registration interface.
3.  **Update `main.dart`:**
    - Configure `GoRouter` to define the routes for `/`, `/login`, and `/register`.
    - Convert `MaterialApp` to `MaterialApp.router` to use the new routing configuration.
    - Replace the home page's default counter with styled "Login" and "Register" buttons that navigate to the respective screens.
