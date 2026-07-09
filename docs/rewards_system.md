# HapoPay Student Rewards System

## Overview
The Student Rewards System adds gamification to the HapoPay Flutter app. It provides a dedicated rewards screen with progress bars, tier badges, and achievements, along with a live summary card embedded directly in the student dashboard.

## Status
**Completed** - The rewards system UI, state management, and backend data modeling are fully implemented and integrated. 
The codebase has been verified with zero static analysis errors (`flutter analyze` passed). 
Code generation for Riverpod and GoRouter is up-to-date.

## Architecture

The feature follows the **Feature-Driven Architecture** within `lib/features/student/`:

- **Model Layer**: `reward_model.dart`
  - Defines `RewardTier`, `AchievementModel`, `MilestoneModel`, and the root `RewardModel`.
  - Maps to the `/api/rewards/{studentId}/` endpoint.
  - Includes a `demo()` factory to provide robust fallback data if the backend is unreachable.

- **Repository Layer**: `rewards_repository.dart`
  - Handles API requests via `DioClient`.
  - Integrates endpoints for fetching rewards (`GET`) and claiming achievements (`POST`).

- **Provider Layer**: `rewards_provider.dart`
  - Uses Riverpod's `AsyncNotifier` for state management.
  - Optimistically updates UI state when claiming achievements before the backend confirms.

- **Presentation Layer**: 
  - `rewards_screen.dart`: The full-page UI featuring an animated Hero Card (tier progress), Tier Ladder, and Achievement Grid.
  - `student_dashboard_screen.dart`: Updated to feature a `_RewardsSummaryCard` that links directly to the full rewards screen.

- **Routing**: `app_router.dart`
  - Nested `/student/rewards` route registered via GoRouter.

## Commands Used

To generate the code for Riverpod and run static analysis during development, the following commands were used:

```bash
# Generate Riverpod provider stubs and router files
dart run build_runner build --delete-conflicting-outputs

# Verify the codebase for static analysis issues
flutter analyze
```

## How to Test
1. Log in to the application as a Student.
2. Observe the **Rewards Summary Card** on the main dashboard which displays the current tier and points.
3. Tap the summary card to navigate to the **Rewards Screen**.
4. View the animated progress bars and tier ladder.
5. Tap an earned, unclaimed achievement in the grid to trigger the claim flow.

*(Note: If the backend `/api/rewards/` is not reachable, the system will automatically fall back to demo data so you can freely test the UI and state transitions.)*
