import Stripe from "https://esm.sh/stripe@14.25.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);
const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, stripe-signature",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }

  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response(JSON.stringify({ error: "Missing stripe-signature header" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  let event: Stripe.Event;
  try {
    const body = await req.text();
    event = await stripe.webhooks.constructEventAsync(body, signature, webhookSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return new Response(JSON.stringify({ error: "Invalid signature" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  try {
    if (event.type === "payment_intent.succeeded") {
      const intent = event.data.object as Stripe.PaymentIntent;
      const jobRequestId = intent.metadata?.job_request_id;
      const providerId = intent.metadata?.provider_id;
      const amount = parseFloat(intent.metadata?.amount ?? "0");

      console.log(`payment_intent.succeeded: ${intent.id}, job=${jobRequestId}, provider=${providerId}`);

      // 1. Mark transaction as completed
      if (intent.id) {
        await supabase
          .from("transactions")
          .update({ status: "completed" })
          .eq("stripe_payment_intent_id", intent.id);
      }

      // 2. Credit provider wallet (upsert to handle first-time wallet creation)
      if (providerId && amount > 0) {
        const { data: wallet } = await supabase
          .from("wallet")
          .select("balance")
          .eq("id", providerId)
          .maybeSingle();

        const currentBalance = (wallet?.balance as number) ?? 0;

        await supabase
          .from("wallet")
          .upsert(
            { id: providerId, balance: currentBalance + amount },
            { onConflict: "id" }
          );

        console.log(`Credited provider ${providerId} wallet: +${amount} (new balance: ${currentBalance + amount})`);
      }
    }

    if (event.type === "payment_intent.payment_failed") {
      const intent = event.data.object as Stripe.PaymentIntent;
      console.log(`payment_intent.payment_failed: ${intent.id}`);

      await supabase
        .from("transactions")
        .update({ status: "failed" })
        .eq("stripe_payment_intent_id", intent.id);
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Webhook handler error:", err);
    return new Response(JSON.stringify({ error: "Internal handler error" }), {
      status: 500,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }
});
