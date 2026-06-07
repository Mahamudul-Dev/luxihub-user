import { JWT } from "npm:google-auth-library@9";

export interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
  [key: string]: unknown;
}

export function getServiceAccount(): ServiceAccount {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!raw) throw new Error("FCM_SERVICE_ACCOUNT secret is not set.");
  try {
    const json = new TextDecoder().decode(
      Uint8Array.from(atob(raw), (c) => c.charCodeAt(0))
    );
    const parsed = JSON.parse(json) as ServiceAccount;
    console.log("[fcm] Service account loaded for:", parsed.client_email);
    return parsed;
  } catch (e) {
    throw new Error(`Failed to decode FCM_SERVICE_ACCOUNT: ${e}`);
  }
}

export async function getFcmAccessToken(account: ServiceAccount): Promise<string> {
  const auth = new JWT({
    email: account.client_email,
    key: account.private_key,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });

  const tokenResponse = await auth.authorize();
  if (!tokenResponse?.access_token) {
    throw new Error("Google auth returned no access_token");
  }
  console.log("[fcm] OAuth2 access token obtained");
  return tokenResponse.access_token;
}

export async function sendFcmToToken(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string> = {}
): Promise<boolean> {
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: { title, body },
        data,
        android: {
          priority: "high",
          notification: {
            sound: "default",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          headers: { "apns-priority": "10" },
          payload: { aps: { sound: "default", badge: 1 } },
        },
      },
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    console.warn(`[fcm] FCM send failed for token …${token.slice(-10)}: ${err}`);
    return false;
  }
  console.log(`[fcm] FCM sent to token …${token.slice(-10)}`);
  return true;
}

export async function sendFcmToMany(
  accessToken: string,
  projectId: string,
  tokens: string[],
  title: string,
  body: string,
  data: Record<string, string> = {}
): Promise<number> {
  const results = await Promise.all(
    tokens.map((t) => sendFcmToToken(accessToken, projectId, t, title, body, data))
  );
  return results.filter(Boolean).length;
}
