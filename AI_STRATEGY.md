# Mythrix AI Strategy

> Should you train your own AI model? **Mostly no.** Should you fine-tune one for brand voice? **Yes.** Should you build classical ML for the marketing-specific problems? **Yes.** Should you orchestrate everything through a router? **Absolutely yes — this is the actual product.**

## 1. Current state (be honest about it)

The V1 codebase contains **no real AI**. Every "AI" output is mocked:

| Feature surface | What "AI" you see today | Where it lives in code |
|---|---|---|
| Content Studio variants | Template strings with `_hookFor(v)`, `_ctaFor(v)`, `_paragraph(p)` | `content_studio_screen.dart` |
| Creative Studio gallery | Gradient-filled containers, not generated images | `creative_studio_screen.dart` `_GeneratedAsset` |
| Insights feed | 4 hand-written insights in `MockData.insights()` | `mock_data.dart` |
| Auto-pilot stats | Hard-coded numbers (14 rebalances, 38 negative kws, …) | `autopilot_card.dart` |
| Negative keywords | Hand-written `_Neg` list | `negative_keywords_panel.dart` |
| Best time to post | Hand-written `_windows` list | `best_time_panel.dart` |
| Lead scoring | Hard-coded scores per deal | `crm_screen.dart` |
| Campaign data | `MockData.campaigns()` | `mock_data.dart` |

This was deliberate: build the surface area first so we know exactly which AI capabilities to wire in, and where.

## 2. What Mythrix actually needs (8 different AI capabilities)

Mythrix is not "an AI" — it's **eight different AI capabilities orchestrated by a planner**. Each capability has different cost, latency, and quality requirements.

| # | Capability | Used in | Best technology in 2026 |
|---|---|---|---|
| 1 | Text generation (ads, blogs, captions, email) | Content Studio, Ads Manager | Foundation LLM API (GPT-5 / Claude / Gemini 2) + brand-voice LoRA |
| 2 | Image generation | Creative Studio, Social Scheduler | Foundation model API (Imagen 3, FLUX, Ideogram, DALL-E 4) |
| 3 | Video generation | Creative Studio | Foundation model API (Runway Gen-4, Sora, Veo, Kling) |
| 4 | Voice generation | Creative Studio, video scripts | ElevenLabs / OpenAI voice / Cartesia |
| 5 | Bid & budget optimization | Ads Manager, Auto-Pilot | Classical ML (Bayesian, contextual bandits, RL) — not LLM |
| 6 | Time-series forecasting (best-time-to-post, anomaly detection, budget pacing) | Scheduler, Analytics | Prophet / XGBoost / lightweight neural — not LLM |
| 7 | Classification (lead scoring, creative fatigue detection, audience overlap, negative keyword detection) | CRM, Ads Manager | XGBoost / LightGBM / embeddings + cosine sim — not LLM |
| 8 | Agentic planner — what action should we take next? | Auto-Pilot, the whole orchestrator | LLM with tool-use (Claude 4.6 / GPT-5) wrapping all the above |

**The most important number on this table:** five of the eight needs are NOT solved by an LLM. They're solved by 50-year-old classical ML. Founders who don't realize this end up paying $0.50 per "AI insight" that XGBoost would have produced for fractions of a cent.

## 3. Build vs. buy vs. fine-tune (one decision per capability)

### Capabilities 1–4 (Generation): use APIs, never train from scratch.

Training a GPT/Imagen/Sora-class model from scratch in 2026:
- **Cost:** $10M–$200M+ for compute alone
- **Team:** 10–30 PhD-level ML researchers
- **Timeline:** 12–24 months minimum
- **Verdict:** ❌ **NEVER do this.** Even unicorns like Jasper and Copy.ai don't train their own — they wrap OpenAI / Anthropic.

What to do instead:
- Route to 2–3 providers and pick the best response per task (route → Claude for long-form, GPT-5 for short ad copy, Gemini for multilingual, etc.)
- **Cost:** $0 upfront, ~$0.001–$0.05 per generation
- **Timeline:** 1–2 weeks per provider integration
- **Verdict:** ✅ **Use APIs.**

### Capability 1 special case — Brand voice fine-tuning: this IS your moat.

Every Mythrix customer wants outputs that sound like *their* brand, not generic AI. Fine-tuning a small open model on each customer's 100 best-performing pieces is **how you stop being a wrapper**.

Two options:

**Option A — Per-customer LoRA on Llama 3.1 8B / Mistral 7B (recommended)**
- Train a small adapter (LoRA) per customer on their past content
- **Cost per customer:** $5–$50 of compute (1 hour on a single A100)
- **Inference:** $0.0002–$0.001 per generation when hosted on your own infra (Modal, Replicate, Together, RunPod)
- **Quality:** 70–90% of GPT-5 quality on the brand-voice axis, frequently better on tone match
- **Time to first model:** 2–3 days per customer with 100+ pieces of training data

**Option B — Use OpenAI's fine-tuning API for GPT-4o-mini**
- $25 / million training tokens, $0.30 / million inference tokens
- Quality is high but you're locked into one vendor's pricing forever

**Verdict:** Start with Option B for speed-to-market, migrate top customers to Option A as you scale.

### Capabilities 5–7 (Optimization, forecasting, classification): build classical ML.

These are the **competitive moat** that real marketing-AI companies have over LLM wrappers. Examples:

| Problem | Algorithm | Training time | Inference cost |
|---|---|---|---|
| Bid optimization | Contextual bandit (LinUCB) or Thompson sampling | Online (no offline training) | µs per decision |
| Best time to post | Prophet on historical engagement | 10s per user/channel | ms per query |
| Budget pacing | EWMA + PID controller | None — pure math | µs |
| Lead scoring | XGBoost on CRM features | minutes per workspace | ms |
| Creative fatigue detection | Change-point detection on CTR series | None — pure math | ms |
| Negative keyword candidates | Log-likelihood ratio test on (term, conversion) | seconds | ms |
| Audience overlap | Jaccard / cosine on audience embeddings | minutes | ms |
| Anomaly detection on KPIs | Isolation Forest or Prophet | minutes | ms |

**Verdict:** ✅ **Build these in-house.** Each one is ~200–500 lines of Python + a Postgres table. They produce better results than asking GPT, run 10,000× faster, and cost 100,000× less per inference. **This is where Mythrix wins over Jasper.**

### Capability 8 (Orchestrator): the actual product.

The thing that makes Mythrix feel autonomous is an **LLM agent** that:
1. Watches your KPIs every N minutes
2. Decides which of the above 7 capabilities to invoke
3. Drafts the proposed action
4. Asks you for approval (or just does it, if it's a pre-authorized rule)
5. Reports back what happened

Build this on top of Claude Sonnet 4.6 (best tool-use in 2026) or GPT-5 with the OpenAI Assistants API. Estimated cost per user/month: **$2–$15** depending on activity. Charge $99–$499/month — healthy margin.

## 4. Realistic roadmap (next 3 milestones)

### Milestone 1 — Live generation, no training yet (2–3 weeks)
Wire real APIs into the Content Studio + Creative Studio. The mock generators get replaced by:
- `OpenAiContentService`, `AnthropicContentService` for text
- `IdeogramService`, `FluxService` for images
- `RunwayService`, `KlingService` for video
- One `ContentRouter` that picks the right provider per task

After this milestone, every feature surface in the app works with real AI. Nothing is fine-tuned to your brand yet — outputs are good-but-generic.

**Result: shippable beta to friendly users.**

### Milestone 2 — Brand voice fine-tuning + classical ML (4–6 weeks)
- Build the brand-voice fine-tuning pipeline (training service + Modal/Together inference endpoint)
- Build the 7 classical-ML services above as small Python microservices (FastAPI + Postgres + a worker queue)
- Add the "training your brand model" UX to Brand Assets

**Result: Mythrix sounds like the customer, not like ChatGPT. Bid optimization beats Google's Smart Bidding by ~5-15% on the customer's own data.**

### Milestone 3 — The Mythrix Auto-Pilot agent (6–8 weeks)
- Build the LLM-tool-use orchestrator
- Wire it to all 7 capabilities as callable tools
- Build the "approval queue" UX (already scaffolded in `AutopilotCard`)
- Add policy controls in Settings (what the agent is allowed to do without asking)

**Result: customers leave Mythrix running overnight and wake up to a marketing operation that improved itself. This is the screenshot you put in the Series A deck.**

## 5. Cost model — what running Mythrix actually costs you per customer

Assumes a customer doing ~100 generations/day, 1 fine-tuned brand model, 24/7 auto-pilot:

| Line item | Cost per customer / month |
|---|---|
| Text generation API (GPT-5 / Claude routing) | $8–$22 |
| Image generation API | $3–$12 |
| Video generation API (if used) | $5–$40 |
| Brand-voice LoRA inference (Modal) | $4–$10 |
| Classical ML compute + storage | $0.30–$2 |
| Agent orchestrator (Claude 4.6 tool-use) | $2–$15 |
| Vector DB (Pinecone / pgvector) | $0.50–$3 |
| **Total COGS per customer** | **$23–$104** |
| Charge customers | **$99–$499/month** |
| **Gross margin** | **60–85%** |

The math works. The leverage compounds because of points 2-4: the classical ML and brand fine-tunes get **better** the more usage you have, which is a real moat versus pure LLM wrappers.

## 6. Do you need an ML team?

**For Milestone 1 (live APIs):** No. One Flutter/backend dev can wire all APIs in 2–3 weeks.

**For Milestone 2 (fine-tuning + classical ML):** Yes — one ML engineer who knows PyTorch + scikit-learn + Modal/Together. Hire mid-level for $120K–$180K or use a contractor at $150–$300/hour for the first 3 months.

**For Milestone 3 (agentic auto-pilot):** No new hire needed if Milestone 2's engineer is solid — agent orchestration is mostly prompt engineering + careful tool design, not deep ML.

**You DO NOT need:** GPU clusters, "AI researchers," PhD-level talent, $10M of compute, or a research budget. Anyone selling you on those is selling you a 2021 playbook.

## 7. Where Mythrix wins

Three things, all enabled by the architecture above:

1. **One brain, every channel.** Most competitors do one thing (ads, or content, or social). Mythrix coordinates all of them with one orchestrator that knows the full picture.
2. **Brand voice that's actually theirs.** Fine-tuned adapters per customer means every output sounds like the customer wrote it. Generic LLM wrappers can't do this.
3. **Classical ML where it matters.** Bid optimization, lead scoring, anomaly detection — done with proper algorithms, not LLM hand-waving. Faster, cheaper, more accurate.

This is the playbook. None of it requires building a foundation model. All of it is buildable by a 2–4 person team over 3 months once the surface is ready (which it is).
