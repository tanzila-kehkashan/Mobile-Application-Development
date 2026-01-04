# Dark Mode - Remaining Work

## Summary
The main critical UI screens have been updated to support dark mode. The following screens still contain hardcoded colors that should be updated for complete dark mode support.

## Completed ✅
### Phase 1: Main UI Screens
- ✅ explore_screen.dart
- ✅ events_screen.dart
- ✅ profile_screen.dart
- ✅ search_screen.dart
- ✅ notifications_screen.dart

### Phase 2: Navigation
- ✅ side_drawer.dart
- ✅ nav_bar.dart

### Phase 3: Drawer Screens (Partial)
- ✅ followers_screen.dart
- ✅ following_screen.dart

### Phase 4: Event Subscreens (Partial)
- ✅ event_details_screen.dart

## Remaining Work 🔨

### Drawer Screens (Lower Priority)
These screens have hardcoded colors but are less frequently accessed:

1. **about_us_screen.dart** (12 instances)
   - Remove `backgroundColor: Colors.white` from Scaffold/AppBar
   - Replace `color: Colors.black87` in Text widgets
   - Replace `Colors.grey[700]` with `Theme.of(context).textTheme.bodyMedium?.color`

2. **bookmarks_screen.dart** (10 instances)
   - Remove AppBar colors
   - Replace `Colors.grey[300]` with `Theme.of(context).colorScheme.surfaceContainerHighest`
   - Replace `Colors.grey[600]` with theme text colors

3. **booked_events.dart** (23 instances)
   - Update Scaffold/AppBar
   - Replace grey colors in UI elements
   - Update text colors

4. **contact_us_screen.dart** (9 instances)
   - Remove AppBar background colors
   - Update text field colors
   - Replace grey shades

5. **FAQ_screen.dart** (14 instances)
   - Update expansion tiles
   - Replace hardcoded text colors
   - Update divider colors

6. **chat_screen.dart** (13 instances)
   - Update message bubbles
   - Replace input field colors
   - Update timestamps

7. **chats_list_screen.dart** (19 instances)
   - Update list tiles
   - Replace avatar backgrounds
   - Update timestamps

### Event Subscreens (Medium Priority)
These are moderately important screens:

1. **explore_events_screen.dart** (25 instances)
   - Most work needed
   - Update search bar colors
   - Replace filter chip colors
   - Update event cards

2. **organizer_profile_screen.dart** (19 instances)
   - Update profile sections
   - Replace stat colors
   - Update text colors

3. **ticket_booking_screen.dart** (14 instances)
   - Update form fields
   - Replace card colors
   - Update summary section

### Additional Screens
1. **add_events_screens.dart** (16 instances)
   - Update form fields
   - Replace input decoration colors
   - Update button colors (except brand colors)

## Pattern Reference

### Common Replacements

```dart
// Scaffold
// Before:
Scaffold(
  backgroundColor: Colors.white,
  ...
)
// After:
Scaffold(
  // Remove backgroundColor - uses theme
  ...
)

// AppBar
// Before:
AppBar(
  backgroundColor: Colors.white,
  iconTheme: IconThemeData(color: Colors.black87),
  ...
)
// After:
AppBar(
  // Remove backgroundColor and iconTheme
  ...
)

// Text Colors
// Before:
color: Colors.black87
// After:
// Remove color - uses theme default

// Grey Colors
Colors.grey[100] → Theme.of(context).colorScheme.surfaceContainerHighest
Colors.grey[300] → Theme.of(context).dividerColor
Colors.grey[600] → Theme.of(context).textTheme.bodyMedium?.color
Colors.grey[700] → Theme.of(context).colorScheme.onSurface

// Container/Card Colors
// Before:
color: Colors.white
// After:
color: Theme.of(context).cardColor
```

### Keep Unchanged
- Brand colors: `Color(0xFF5B4EFF)`, `Color(0xFF00D9A5)`, `Color(0xFFFF6B6B)`
- Error colors: `Colors.red`
- Success colors: `Colors.green`
- Category-specific colors in badges/chips
- Gradient colors
- Icon colors in colored containers

## Testing
After completing remaining work, test:
1. Toggle dark mode in settings
2. Navigate to all screens
3. Verify text readability
4. Check border/divider visibility
5. Verify card backgrounds
6. Ensure brand colors remain unchanged
7. Test app restart - theme should persist

## Priority Recommendation
1. **High**: explore_events_screen.dart (frequently used)
2. **Medium**: ticket_booking_screen.dart, organizer_profile_screen.dart
3. **Low**: All other drawer screens (less frequently accessed)
4. **Optional**: settings_screen.dart (already mostly theme-aware)
