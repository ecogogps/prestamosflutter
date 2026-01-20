# Project Blueprint

## Overview
A simple Flutter application that demonstrates a user authentication flow (Login/Register) using Supabase for the backend. After authentication, users can create and submit service requests through a form.

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

## Current Change: Authenticated Home and Request Form

### Plan
1.  **Create Backend Table:** Provided an SQL script to create a `solicitudes` table in Supabase with appropriate columns, relationships, and Row Level Security policies.
2.  **Auth State Redirects:**
    - Updated `go_router` to listen for authentication state changes from Supabase.
    - Implemented a global redirect logic:
        - If a user is logged in, they are automatically redirected from public pages (`/`, `/login`, `/register`) to the new authenticated home (`/home`).
        - If a user is not logged in, they are redirected from protected pages (`/home`) to the login page.
3.  **Authenticated Home Screen (`/home`):**
    - Created a new screen that is only accessible to logged-in users.
    - Added an `AppBar` with the screen title and a "Sign Out" button.
4.  **Request Form:**
    - Built a form on the home screen with the following fields:
        - `Ubicación A`: A dropdown selector with options "punto a" and "punto b".
        - `Ubicación B`: A dropdown selector with the same options.
        - `Descripción`: A multi-line text field for detailed input.
    - The form includes validation to ensure all fields are filled.
5.  **Form Submission Logic:**
    - Implemented a function to handle form submission.
    - When the "Submit Request" button is pressed, the function validates the form, retrieves the current user's ID, and inserts the data into the `solicitudes` table in Supabase.
    - Added loading indicators and user feedback (snackbars) for success and error states.
