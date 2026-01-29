import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const checkPhoneRegistered = onCall(async (request) => {
  const phoneNumber = request.data.phoneNumber;

  if (!phoneNumber) {
    throw new HttpsError(
      "invalid-argument",
      "phoneNumber is required"
    );
  }

  const snapshot = await db
    .collection("users")
    .where("phoneNumber", "==", phoneNumber)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return {
      registered: false,
    };
  }

  const user = snapshot.docs[0].data();

  return {
    registered: true,
    uid: snapshot.docs[0].id,
    name: user?.name ?? null,
  };
});
