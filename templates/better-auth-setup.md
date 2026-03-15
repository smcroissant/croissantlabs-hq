# Better Auth — CroissantLabs Standard Setup

This is the standard auth configuration for all CroissantLabs SaaS projects.

## Stack
- **Better Auth** — auth library
- **Drizzle** — database adapter
- **Neon** — serverless Postgres
- **Next.js 15** — App Router

## Quick Start for New SaaS

```bash
# 1. Install
npm install better-auth

# 2. Set env vars
BETTER_AUTH_SECRET=$(openssl rand -base64 32)
BETTER_AUTH_URL=http://localhost:3000  # Change in prod

# 3. Create auth config (see lib/auth.ts template below)

# 4. Run migration
npx @better-auth/cli@latest migrate

# 5. Verify
curl http://localhost:3000/api/auth/ok
# → { "status": "ok" }
```

## Template: `lib/auth.ts`

```typescript
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "./db"; // Your Drizzle instance

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
  }),
  emailAndPassword: {
    enabled: true,
  },
  socialProviders: {
    // Add as needed:
    // github: {
    //   clientId: process.env.GITHUB_CLIENT_ID!,
    //   clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    // },
    // google: {
    //   clientId: process.env.GOOGLE_CLIENT_ID!,
    //   clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    // },
  },
  plugins: [
    // Add plugins as needed:
    // twoFactor(),
    // organization(),
    // username(),
  ],
});
```

## Template: `app/api/auth/[...all]/route.ts`

```typescript
import { auth } from "@/lib/auth";
import { toNextJsHandler } from "better-auth/next-js";

export const { GET, POST } = toNextJsHandler(auth);
```

## Template: Client (`lib/auth-client.ts`)

```typescript
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000",
});

export const { signIn, signUp, signOut, useSession } = authClient;
```

## Database Migration

After creating `lib/auth.ts`, run:
```bash
npx @better-auth/cli@latest migrate
```

This creates tables: `user`, `session`, `account`, `verification`.

**With Drizzle:** You can also generate the schema:
```bash
npx @better-auth/cli@latest generate --drizzle
```

## Common Patterns

### Protecting a Server Component
```typescript
import { auth } from "@/lib/auth";
import { headers } from "next/headers";
import { redirect } from "next/navigation";

export default async function Dashboard() {
  const session = await auth.api.getSession({
    headers: await headers(),
  });

  if (!session) redirect("/login");

  return <div>Welcome, {session.user.name}</div>;
}
```

### Protecting a tRPC Route
```typescript
import { protectedProcedure } from "@/server/trpc";

export const userRouter = {
  me: protectedProcedure.query(({ ctx }) => {
    return ctx.session.user;
  }),
};
```

### Middleware Protection (optional)
```typescript
// middleware.ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const protectedPaths = ["/dashboard", "/settings"];

export function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname;

  if (protectedPaths.some((p) => path.startsWith(p))) {
    const session = request.cookies.get("better-auth.session_token");
    if (!session) {
      return NextResponse.redirect(new URL("/login", request.url));
    }
  }

  return NextResponse.next();
}
```

## Plugins (Optional)

### Two Factor Auth
```typescript
import { twoFactor } from "better-auth/plugins/two-factor";

// Add to plugins array:
twoFactor()
```

### Organization (Team/Multi-tenant)
```typescript
import { organization } from "better-auth/plugins/organization";

organization()
```

### Username
```typescript
import { username } from "better-auth/plugins/username";

username()
```

## Environment Variables

Required for all SaaS projects:
```
BETTER_AUTH_SECRET=<32+ char secret>
BETTER_AUTH_URL=<app url>
```

Optional:
```
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
```

---

**Docs:** https://better-auth.com/docs
**LLMs:** https://better-auth.com/llms.txt
