## SupaSet
# SupaSet

<img src="/api/placeholder/120/120" alt="SupaSet Logo" width="120" height="120" style="border-radius: 20px; margin-bottom: 20px" />

**SupaSet** is a comprehensive workout tracking app built with SwiftUI that helps you achieve your fitness goals through detailed exercise tracking and progress visualization.

## Core Features

### 🏋️‍♂️ Advanced Workout Management

- **Interactive Workout Builder**
  - Drag and drop interface to reorder exercises
  - Swipe actions to delete exercises and sets
  - Add multiple sets with customizable reps and weights
  - Mark sets as complete during your workout

- **Exercise Configuration**
  - Custom rest timers for between sets
  - Toggle between pounds and kilograms
  - Add detailed notes for each exercise
  - Set-by-set tracking with warmup set identification

- **Workout Lifecycle**
  - Real-time workout duration tracking
  - Live Activities integration for lock screen tracking
  - Auto-save functionality
  - Finish and save workouts with complete statistics

### 📊 Detailed Progress Analytics

- **Workout Completion Summary**
  - Total volume calculations
  - Maximum weight lifted
  - Average reps per set
  - Set completion statistics
  - Animated celebration effects

- **Visual Performance Tracking**
  - Volume distribution by exercise
  - Weight progression charts
  - Set-by-set performance graphs
  - Muscle group activation radar chart

- **Exercise History**
  - Comprehensive workout history list
  - Detailed workout session review
  - Exercise performance over time
  - Training volume trends

### 📚 Comprehensive Exercise Library

- **Extensive Database**
  - Categorized by muscle groups and movement patterns
  - Searchable exercise index
  - Multiple filtering options (equipment, difficulty, muscle targets)
  - Exercise details with proper form instructions

- **Filtering Options**
  - By muscle group (chest, back, legs, etc.)
  - By equipment type (barbell, dumbbell, bodyweight, etc.)
  - By difficulty level (beginner, intermediate, expert)
  - By exercise category (strength, cardio, plyometrics, etc.)

- **Exercise Detail View**
  - Step-by-step instructions
  - Primary and secondary muscle targeting
  - Equipment requirements
  - Difficulty level indicators
  - Force and mechanic type information

### 🗄️ Template System

- **Template Management**
  - Create reusable workout templates
  - Start workouts directly from templates
  - Track template usage history
  - Visual template cards for quick access

- **Template Organization**
  - Drag and drop reordering
  - Visual customization
  - Exercise count display
  - Quick edit capabilities

- **Exercise Sets in Templates**
  - Preconfigured set schemes
  - Default weight and rep ranges
  - Copy templates for variations
  - Exercise-specific notes

### 🔐 User Authentication & Profiles

- **Multiple Sign-in Options**
  - Sign in with Apple
  - Sign in with Google
  - Email and password authentication
  - Secure authentication flows

- **User Profile**
  - Account management
  - Workout statistics
  - Member since date tracking
  - Settings customization

- **Data Management**
  - Secure data storage
  - Account-linked workouts
  - Sign out with data clearing
  - Automatic sync (coming soon)

## Technical Architecture

### SwiftUI Framework
- Modern declarative UI built entirely with SwiftUI
- Smooth animations and transitions
- Responsive design for all iOS devices
- Support for light and dark mode

### Data Management
- **SwiftData** for efficient local persistence
- Relationship models for workouts, exercises, and sets
- Optimized queries for performance
- Structured schema versioning

### Authentication
- Firebase Authentication integration
- Secure credential management
- OAuth flows for social sign-ins
- Token management and refresh

### Design Patterns
- MVVM architecture throughout the application
- Observable objects for state management
- Dependency injection for view models
- Protocol-oriented programming for flexibility

## UI Components

### Exercise Cards
- Interactive exercise cards with expansion capability
- Set management directly within cards
- Visual completion indicators
- Quick access to exercise details

### Workout Progress Tracking
- Visual progress dots for workout navigation
- Animated completion effects
- Interactive rest timers
- Set completion markers

### Template Interface
- Template cards with exercise previews
- Quick-start workout buttons
- Last used date tracking
- Template editing interface

### Custom UI Elements
- Specialized input components for weight and reps
- Custom progress visualization
- Radar charts for muscle activation
- Animated completion celebrations

## Development Information

### Requirements
- iOS 16.0 or later
- Xcode 15 or later (for development)
- Firebase account (for authentication)

### Key Technologies
- SwiftUI for the user interface
- SwiftData for persistence and data management
- Firebase Authentication for user accounts
- ActivityKit for iOS Live Activities
- Charts framework for data visualization

### Upcoming Features
- Workout sharing functionality
- Cloud synchronization across devices
- Custom exercise creation
- Advanced progress analytics
- Training program builder

## Screenshots

<div style="display: flex; flex-wrap: wrap; justify-content: space-between; margin-bottom: 20px;">
  <img src="/api/placeholder/240/520" alt="Workout Session" width="240" height="520" style="border-radius: 10px; margin-bottom: 10px" />
  <img src="/api/placeholder/240/520" alt="Exercise Library" width="240" height="520" style="border-radius: 10px; margin-bottom: 10px" />
  <img src="/api/placeholder/240/520" alt="Completed Workout Summary" width="240" height="520" style="border-radius: 10px; margin-bottom: 10px" />
</div>

---

© 2025 SupaSet LLC.