# Content / age rating questionnaire notes

Use these notes when filling **Google Play** IARC / content rating (and similar questionnaires).

**Out of scope this pass:** App Store Connect age rating, pricing, and category (owner completes in ASC).

## Product summary for raters

HapoPay is a **campus student spending / allowance** app with **parental controls**, **QR payments**, and **gamified rewards** (points, tiers, streaks). No social feed, no user-generated public posts, no dating, no gambling mechanics with real-money wagering.

## Likely questionnaire themes

| Topic | Suggested direction |
|-------|---------------------|
| Violence / horror / drugs / sexual content | None |
| Gambling | No real-money gambling; rewards are promotional points, not casino |
| User-generated content | No public UGC feed; financial activity is private to the family |
| Share location | No (unless you add it later) |
| Unrestricted web access | No in-app unrestricted browser (confirm if you add WebViews) |
| Age gate | Students + parents; set store rating for a general / teen audience consistent with counsel and school policy |
| In-app purchases / subscriptions | Declare accurately if you add IAP later; v1.0.0 client is wallet/campus pay via your backend, not Play Billing unless you integrate it |
| Ads | None unless you add an ad SDK |

## Play Console steps (owner)

1. Complete **Content rating** questionnaire in Play Console.
2. Apply the generated rating to the release track.
3. Keep answers consistent with [`LISTING_COPY.md`](LISTING_COPY.md) and the Privacy Policy.

## Apple (deferred)

App Store Connect **Age Rating**, **Pricing**, and **Category** are **not** part of this production-prep pass. Complete them when creating the ASC record; use the same product summary above so ratings stay aligned across stores.
