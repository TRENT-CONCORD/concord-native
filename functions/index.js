const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Scheduled function that runs daily to clean up accounts that were scheduled for deletion
 * more than 90 days ago. This permanently deletes user data that has exceeded the grace period.
 */
exports.cleanupExpiredAccounts = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    const auth = admin.auth();
    const storage = admin.storage();
    
    // Calculate cutoff date (90 days ago)
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 90);
    const cutoffDateStr = cutoffDate.toISOString();
    
    console.log(`Running cleanup for accounts scheduled for deletion before ${cutoffDateStr}`);
    
    try {
      // Find accounts scheduled for deletion more than 90 days ago
      const expiredAccountsSnapshot = await db.collection('users')
        .where('scheduledForDeletion', '==', true)
        .where('deletionScheduledAt', '<=', cutoffDateStr)
        .get();
      
      if (expiredAccountsSnapshot.empty) {
        console.log('No expired accounts found for cleanup');
        return null;
      }
      
      console.log(`Found ${expiredAccountsSnapshot.size} expired accounts to clean up`);
      
      // Process each expired account
      const batch = db.batch(); // Use batch writes for efficiency
      let successCount = 0;
      let errorCount = 0;
      
      for (const doc of expiredAccountsSnapshot.docs) {
        const uid = doc.id;
        const userData = doc.data();
        
        try {
          console.log(`Processing account deletion for user ${uid}`);
          
          // 1. Delete profile photos from storage
          try {
            // Delete main profile photo
            const mainPhotoRef = storage.bucket().file(`profile_pictures/${uid}.jpg`);
            await mainPhotoRef.delete().catch((err) => {
              // Ignore "file not found" errors
              if (err.code !== 404) {
                console.warn(`Error deleting main profile photo for ${uid}:`, err);
              }
            });
            
            // Delete additional photos if they exist
            if (userData.additionalPhotos && Array.isArray(userData.additionalPhotos)) {
              for (let i = 0; i < userData.additionalPhotos.length; i++) {
                try {
                  const additionalPhotoRef = storage.bucket().file(`profile_pictures/${uid}/additional_${i}.jpg`);
                  await additionalPhotoRef.delete().catch((err) => {
                    if (err.code !== 404) {
                      console.warn(`Error deleting additional photo ${i} for ${uid}:`, err);
                    }
                  });
                } catch (photoErr) {
                  console.warn(`Error processing additional photo ${i} for ${uid}:`, photoErr);
                }
              }
            }
            console.log(`Successfully deleted storage files for ${uid}`);
          } catch (storageErr) {
            console.error(`Error deleting storage files for ${uid}:`, storageErr);
            // Continue with account deletion even if storage deletion fails
          }
          
          // 2. Delete the Firestore profile document
          batch.delete(doc.ref);
          
          // 3. Delete the Firebase Auth account
          try {
            await auth.deleteUser(uid);
            console.log(`Successfully deleted auth account for ${uid}`);
          } catch (authErr) {
            // If the auth user doesn't exist, it may have been deleted manually
            if (authErr.code === 'auth/user-not-found') {
              console.log(`Auth account for ${uid} was already deleted`);
            } else {
              console.error(`Error deleting auth account for ${uid}:`, authErr);
              errorCount++;
              // Continue with deletion of other users
            }
          }
          
          successCount++;
        } catch (err) {
          console.error(`Error processing deletion for ${uid}:`, err);
          errorCount++;
          // Continue with the next account
        }
      }
      
      // Commit the batch write to delete all the documents
      await batch.commit();
      
      console.log(`Completed cleanup: ${successCount} accounts deleted successfully, ${errorCount} errors`);
      return { success: successCount, errors: errorCount };
    } catch (error) {
      console.error('Error executing cleanupExpiredAccounts function:', error);
      return { error: error.message };
    }
  });

/**
 * Scheduled weekly report on accounts pending deletion
 * This helps monitor the deletion queue and sends alerts if needed
 */
exports.generateDeletionReport = functions.pubsub
  .schedule('every monday 09:00')
  .timeZone('America/New_York') // Adjust to your timezone
  .onRun(async (context) => {
    const db = admin.firestore();
    
    try {
      // Query all accounts scheduled for deletion
      const scheduledDeletionsSnapshot = await db.collection('users')
        .where('scheduledForDeletion', '==', true)
        .get();
      
      if (scheduledDeletionsSnapshot.empty) {
        console.log('No accounts scheduled for deletion');
        return null;
      }
      
      // Count users by days remaining
      const pendingDeletions = scheduledDeletionsSnapshot.size;
      const expiringIn7Days = [];
      const expiringIn30Days = [];
      const now = new Date();
      
      scheduledDeletionsSnapshot.forEach(doc => {
        const data = doc.data();
        if (data.deletionScheduledAt) {
          const scheduledDate = new Date(data.deletionScheduledAt);
          const deletionDate = new Date(scheduledDate);
          deletionDate.setDate(deletionDate.getDate() + 90);
          
          const daysRemaining = Math.ceil((deletionDate - now) / (1000 * 60 * 60 * 24));
          
          if (daysRemaining <= 7) {
            expiringIn7Days.push({
              uid: doc.id,
              email: data.email || 'Unknown email',
              daysRemaining
            });
          } else if (daysRemaining <= 30) {
            expiringIn30Days.push({
              uid: doc.id,
              email: data.email || 'Unknown email', 
              daysRemaining
            });
          }
        }
      });
      
      // Log the report (in production you'd email this or save to a database)
      console.log('===== ACCOUNT DELETION REPORT =====');
      console.log(`Total accounts pending deletion: ${pendingDeletions}`);
      console.log(`Accounts expiring in next 7 days: ${expiringIn7Days.length}`);
      console.log(`Accounts expiring in next 30 days: ${expiringIn30Days.length}`);
      
      if (expiringIn7Days.length > 0) {
        console.log('\nAccounts expiring in the next 7 days:');
        expiringIn7Days.forEach(account => {
          console.log(`- ${account.email} (${account.uid}): ${account.daysRemaining} days remaining`);
        });
      }
      
      // In a production app, you might want to send this report via email or save to a database
      
      return {
        report: {
          total: pendingDeletions,
          expiringIn7Days: expiringIn7Days.length,
          expiringIn30Days: expiringIn30Days.length,
        }
      };
    } catch (error) {
      console.error('Error generating deletion report:', error);
      return { error: error.message };
    }
  }); 