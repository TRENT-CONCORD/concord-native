# Firebase Cloud Functions for Account Management

This directory contains Firebase Cloud Functions for Concord app account management, particularly for handling the scheduled deletion of accounts after the 90-day grace period.

## Functions Overview

### `cleanupExpiredAccounts`
- Runs daily to permanently delete accounts that were scheduled for deletion more than 90 days ago
- Cleans up storage (profile pictures), Firestore documents, and Authentication accounts
- Uses batch operations for efficiency

### `generateDeletionReport`
- Runs weekly to provide a report of accounts pending deletion
- Helps monitor the deletion queue and identify accounts expiring soon
- Logs information that can be used for admin notifications

## Deployment Instructions

### Prerequisites
1. Install Firebase CLI globally:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase in your project (if not already done):
```bash
firebase init
```

### Setup
1. Navigate to the functions directory:
```bash
cd functions
```

2. Install dependencies:
```bash
npm install
```

### Deploy
1. Deploy only the functions:
```bash
firebase deploy --only functions
```

Or deploy specific functions:
```bash
firebase deploy --only functions:cleanupExpiredAccounts,functions:generateDeletionReport
```

### Testing Locally
You can test the functions locally before deployment:

```bash
firebase emulators:start --only functions
```

## Monitoring

You can monitor your function execution and logs in the Firebase Console:
1. Go to Firebase Console > Functions
2. Check the logs for each function execution
3. Set up alerts for function failures

## Important Notes

- These functions handle permanent account deletion, so be careful when testing in production
- The 90-day grace period is calculated based on the `deletionScheduledAt` field in user profiles
- Ensure your app's client-side code doesn't attempt to delete Firebase Auth accounts directly when a user requests deletion
- Instead, it should mark the account for scheduled deletion in Firestore and rely on these functions for the actual deletion 