import { importPKCS8, SignJWT } from "https://deno.land/x/jose@v4.14.4/index.ts";

export interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

export function getServiceAccount(): ServiceAccount {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!raw) throw new Error("FCM_SERVICE_ACCOUNT secret is not set.");
  const json = new TextDecoder().decode(
    Uint8Array.from(atob(raw), (c) => c.charCodeAt(0))
  );
  return JSON.parse(json) as ServiceAccount;
}

export async function getFcmAccessToken(account: ServiceAccount): Promise<string> {
  const privateKey = await importPKCS8(account.private_key, "RS256");
  const now = Math.floor(Date.now() / 1000);

  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256" })
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .setIssuer(account.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .sign(privateKey);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth2:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const data = await res.json();
  if (!data.access_token) {
    throw new Error(`OAuth2 token error: ${JSON.stringify(data)}`);
  }
  return data.access_token as string;
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
    console.warn(`FCM failed for token ${token.slice(0, 20)}…: ${err}`);
    return false;
  }
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
