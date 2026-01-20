# Project Blueprint

## Overview
A simple Flutter application that demonstrates a user authentication flow (Login/Register) using Supabase for the backend.

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

### v1.2 - Supabase Integration
- **Backend:** Integrated the Supabase Flutter SDK to handle user authentication.
- **Initialization:** Supabase client is initialized at app startup with the project URL and anon key.
- **Authentication Logic:**
    - The Login screen now calls `supabase.auth.signInWithPassword` to authenticate users.
    - The Register screen now calls `supabase.auth.signUp` to create new users.
- **User Feedback:** Implemented loading indicators during authentication requests and snackbar notifications for success or error messages.
- **Error Handling:** Added `try-catch` blocks to gracefully handle `AuthException` and other potential errors during login or registration.

## Current Change: Connect to Supabase

### Plan
1.  **Add Dependency:** Add the `supabase_flutter` package to `pubspec.yaml`.
2.  **Initialize Supabase:** Configure the Supabase client in `lib/main.dart` using the provided URL and anon key.
3.  **Implement Login:**
    - Convert `LoginScreen` to a `StatefulWidget`.
    - Add `TextEditingController`s, a `Form`, and validation for the email and password fields.
    - Create a `_login` method that calls `supabase.auth.signInWithPassword`.
    - Implement a loading state and provide user feedback via `ScaffoldMessenger`.
4.  **Implement Registration:**
    - Convert `RegisterScreen` to a `StatefulWidget`.
    - Add `TextEditingController`s, a `Form`, and validation, including a check for matching passwords.
    - Create a `_register` method that calls `supabase.auth.signUp`.
    - Implement a loading state and provide user feedback, including a message to check for a confirmation email.
