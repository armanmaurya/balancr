/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { setGlobalOptions } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Set global options with region (CRITICAL - must match Firestore region!)
setGlobalOptions({ 
  maxInstances: 1,
  region: 'asia-southeast1' // ← CHANGE THIS to match your Firestore region!
});

// Interface for Transaction data
interface TransactionData {
  toContactId?: string;
  amount: number | string;
  isGiven: boolean;
  date?: string;
  note?: string;
  fromUserId?: string;
  toUserId?: string;
}

/**
 * Cloud Function to update contact balance when a transaction is modified
 * Triggers on: create, update, delete of transaction documents
 * Uses incremental approach for better performance
 */
export const updateContactOnTransaction = onDocumentWritten(
  {
    document: "users/{userId}/transactions/{transactionId}",
    region: 'asia-southeast1' // ← MUST match your Firestore region!
  },
  async (event) => {
    const db = admin.firestore();
    const userId = event.params.userId;
    const transactionId = event.params.transactionId;

    try {
      logger.info(
        `🚀 Processing transaction change for user: ${userId}, transaction: ${transactionId}`,
        { structuredData: true }
      );

      const before = event.data?.before?.data() as TransactionData | undefined;
      const after = event.data?.after?.data() as TransactionData | undefined;

      // Determine the operation type
      const isCreate = !before && after;
      const isUpdate = before && after;
      const isDelete = before && !after;

      logger.info(
        `📊 Operation type - Create: ${isCreate}, Update: ${isUpdate}, Delete: ${isDelete}`,
        { structuredData: true }
      );

      // Debug log the data received
      logger.info("📝 Data received:", {
        before: before,
        after: after,
        hasToContactId: after?.toContactId || before?.toContactId
      });

      // Handle different operation types with incremental updates
      if (isCreate && after) {
        // New transaction created - add to contact balance
        await incrementContactBalance(db, userId, after, 1);
      } else if (isDelete && before) {
        // Transaction deleted - subtract from contact balance
        await incrementContactBalance(db, userId, before, -1);
      } else if (isUpdate && before && after) {
        // Transaction updated - handle changes
        await handleTransactionUpdate(db, userId, before, after);
      }

      logger.info("✅ Successfully processed transaction change");
    } catch (error) {
      logger.error("❌ Error updating contact on transaction change:", error);
      throw error;
    }
  }
);

/**
 * Helper function to incrementally update contact balance
 */
async function incrementContactBalance(
  db: admin.firestore.Firestore,
  userId: string,
  transactionData: TransactionData,
  multiplier: number
): Promise<void> {
  const contactId = transactionData.toContactId;
  if (!contactId) {
    logger.info("⏭️ No toContactId found, skipping balance update");
    return;
  }

  const amount = transactionData.amount ? parseFloat(transactionData.amount.toString()) : 0;
  const isGiven = transactionData.isGiven;

  // Calculate the balance change
  const balanceChange = (isGiven ? amount : -amount) * multiplier;

  logger.info(
    `🔄 Incrementing balance for contact ${contactId} by ${balanceChange}`
  );

  try {
    // Update the contact document with incremental balance change
    const contactRef = db.doc(`users/${userId}/contacts/${contactId}`);
    
    await contactRef.update({
      balance: admin.firestore.FieldValue.increment(balanceChange),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info(
      `✅ Successfully updated balance for contact ${contactId} by ${balanceChange}`
    );
  } catch (error) {
    logger.error(`❌ Failed to update contact ${contactId}:`, error);
    throw error;
  }
}

/**
 * Helper function to handle transaction updates
 */
async function handleTransactionUpdate(
  db: admin.firestore.Firestore,
  userId: string,
  beforeData: TransactionData,
  afterData: TransactionData
): Promise<void> {
  const beforeContactId = beforeData.toContactId;
  const afterContactId = afterData.toContactId;

  // Case 1: Contact changed - remove from old contact, add to new contact
  if (beforeContactId !== afterContactId) {
    logger.info(`🔄 Contact changed from ${beforeContactId} to ${afterContactId}`);

    // Remove from old contact
    if (beforeContactId) {
      await incrementContactBalance(db, userId, beforeData, -1);
    }

    // Add to new contact
    if (afterContactId) {
      await incrementContactBalance(db, userId, afterData, 1);
    }
    return;
  }

  // Case 2: Same contact, but transaction details changed
  if (beforeContactId && afterContactId && beforeContactId === afterContactId) {
    const beforeAmount = beforeData.amount ? parseFloat(beforeData.amount.toString()) : 0;
    const afterAmount = afterData.amount ? parseFloat(afterData.amount.toString()) : 0;
    const beforeIsGiven = beforeData.isGiven;
    const afterIsGiven = afterData.isGiven;

    // Calculate the net change
    const beforeBalance = beforeIsGiven ? beforeAmount : -beforeAmount;
    const afterBalance = afterIsGiven ? afterAmount : -afterAmount;
    const netChange = afterBalance - beforeBalance;

    if (netChange !== 0) {
      logger.info(
        `📈 Updating balance for contact ${afterContactId} by ${netChange}`
      );

      const contactRef = db.doc(`users/${userId}/contacts/${afterContactId}`);
      await contactRef.update({
        balance: admin.firestore.FieldValue.increment(netChange),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info(
        `✅ Successfully updated balance for contact ${afterContactId} by ${netChange}`
      );
    } else {
      logger.info("➖ No balance change needed for this update");
    }
  }
}

// Add a simple test function to verify deployment
export const testDeployment = onRequest({ region: 'asia-southeast1' }, (req, res) => {
  logger.info("✅ Test function called successfully");
  res.send("Deployment test successful - function is working!");
});