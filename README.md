# Proceduralize English

An anti-sycophantic, research-grounded English tutor that runs inside Claude Code or a claude.ai Project. It treats every learner self-diagnosis as a hypothesis to test, refuses to praise adequate-but-non-native output, and pushes the learner from recognition toward production through an elicit → recast → re-elicit → delayed-retest loop.

This is not a chatbot you talk to. It is a system prompt, a knowledge-base layout, and a set of slash commands that turn a long-context LLM into a tutor with persistent state, a self-updating rule file, and built-in defenses against the characteristic failure modes of LLM tutors.

## Why this exists

The target is first-language internalization — English as the medium of thought, not just academic or professional competence. The standard routes have known ceilings. Human tutors are bottlenecked by hours, by memory between sessions, and by patience on the hundredth rep of the same drill. Apps like Duolingo, Pimsleur, and Glossika escape those bottlenecks but introduce others: a fixed corpus that doesn't know your field, drills tuned to a generic learner rather than your specific errors, engagement loops optimized for retention rather than learning, and a closed pedagogy you can neither inspect nor fork.

An LLM with persistent state and on-demand availability shares neither set of limits, and the whole pedagogy fits in a markdown file you own. The bet is to spend that capacity on a pedagogy grounded in the second-language acquisition literature — proceduralization, pushed output, noticing, retrieval practice, chunk inventory — rather than tutor-instinct heuristics or engagement-tuned drill cycles.

That capacity is mostly wasted today. Off-the-shelf LLM tutors fail in characteristic ways:

- They praise output that is comprehensible but flat, leaving no signal about register or naturalness.
- They invent collocations that sound plausible but aren't corpus-frequent.
- They give the better phrasing on demand, training recognition rather than production.
- They drift across long conversations and forget what they were drilling 50 turns ago.
- They agree with the learner's self-diagnosis instead of checking it against the data.

Proceduralize English encodes counter-measures for each as concrete rules in `CLAUDE.md`, not as best-effort hopes. The result is a tutor you fight with sometimes — and that is the point.

## Core principles

1. **Procedural over declarative.** Adult L2 learners recognize far more than they produce. Every correction ends in re-elicitation in a *new* sentence, with delayed re-test in a later turn. (Swain; Long; Karpicke & Roediger.)
2. **Chunks before fluency.** Spoken fluency is bottlenecked by formulaic-sequence inventory and retrieval speed, not "more conversation." The tutor mines chunks from the learner's own reading and drills them under time pressure. (Wray; Segalowitz.)
3. **English-first, L1-on-demand.** The L1 is a debugging tool, not the default mode. Translation requests are refused; the tutor builds English from the *function*, not the L1 surface.
4. **Active, not reactive.** The tutor initiates diagnostics, retrievals, pushbacks, and edits to its own instruction file. It does not wait to be asked.
5. **Anti-sycophancy hardcoded.** Affective praise ("great job," "perfect") is banned, replaced with concrete diagnostics ("idiomatic," "flat," "wrong register"). Uncertainty must be hedged, not asserted.
6. **Low-friction, gap-tolerant.** Default sessions are 15 minutes. Routines that only work under daily compliance are designed wrong. Gaps are neutral; the tutor opens each session as if no time has passed.
7. **Compounding personalization.** Every session leaves an artifact in the knowledge base; the next session reads from it. The instruction file is editable via an approved-diff protocol with an auditable changelog.
8. **Open by default.** Every rule, drill, slash command, and session log lives in plain text under your control — auditable, forkable, modifiable. No proprietary curriculum, no black-box pedagogy.

## How it works

The project is a single directory with a strict layout:

```
CLAUDE.md                 # operating instructions, read every session
sessions.md               # session-by-session log, appended by the tutor
level.md                  # per-sub-skill CEFR snapshot, updated by /diagnostic
chunks.md                 # mined formulaic sequences with usage notes
retired_targets.md        # error patterns that have been mastered or dropped
assimilation_policy.md    # learner-specific extensions to the pragmatics policy
.claude/
  commands/               # slash-command definitions (/diagnostic, /chunk-mine, …)
  hooks/
    session-start.sh      # injects last sessions + current level into context
    auto-git.sh           # commits and pushes KB files on Stop
    claude-md-guard.sh    # forces approval prompt on any CLAUDE.md edit
  settings.json           # wires the hooks
```

Three mechanisms hold it together:

- **CLAUDE.md is durable; KB files are mutable.** Rules change only through the propose → approve → changelog protocol (§10). Session-by-session state lives in the markdown KB files and updates freely. Environment-independent.
- **Session-start hook auto-injects context.** *(Claude Code only.)* The last three session entries and the CEFR snapshot are injected at session start. Outside Claude Code, the §4 instruction has the model read those files itself — same effect, slightly slower.
- **CLAUDE.md is guarded.** *(Claude Code only.)* A `PreToolUse` hook forces an approval prompt before any `CLAUDE.md` edit. In a claude.ai Project, the constraint is enforced structurally — the model can't write to the Instructions field or Project Files directly.

## Setup

1. **Fork or clone** this repository.
2. **Edit §2 of `CLAUDE.md`** (Learner Profile). At minimum:
   - Your L1. Examples throughout the file use Korean as the worked L1 (높임법, 눈치, sentence-final particles); swap in your own L1-only constructs.
   - Your field or context. Many examples assume an academic/research learner (PI emails, reviewer rebuttals); adapt to your setting.
   - Any stated phenomenology you want the tutor to treat as a hypothesis worth testing.
3. **Pick a run environment:**
   - **Claude Code (CLI).** `cd` into the directory and run `claude`. All three hooks fire automatically.
   - **claude.ai Project.** Paste `CLAUDE.md` into the **Instructions** field; attach the KB files via upload or the GitHub connector. Hooks don't fire here, so you'll sync KB changes back manually after sessions that modified them. In exchange: voice mode, useful for `/speaking-drill` and `/pragma`.
4. **Run `/diagnostic`.** A 15-min mixed task that yields per-sub-skill CEFR estimates, populates `level.md`, and seeds the first Active Targets via the §10 edit protocol.
5. **Use it.** Subsequent sessions can be open-ended ("here's a paragraph I wrote, tear it apart") or scoped through slash commands.

## Slash commands

| Command | What it does |
|---|---|
| `/diagnostic` | 15-min mixed task, populates `level.md`, seeds Active Targets |
| `/diagnostic-mini` | 3-min stagnation check |
| `/chunk-mine` | Extracts 5–10 formulaic sequences from a pasted native-English passage |
| `/paper-paraphrase` | Breaks down a paper sentence's register and hedging; learner rewrites; tutor diagnoses gap |
| `/notion-rewrite` | Native rewrite of a planning bullet, with push-back retrieval on the next item |
| `/speaking-drill` | Fast retrieval drill: prompt, 20s response, recast, re-elicit, 10 reps |
| `/pragma <situation>` | Produces 2–3 register variants for a real situation; learner attempts; tutor diagnoses |
| `/error-postmortem` | Diagnoses a "felt-wrong" production and proposes an Active Target if recurring |
| `/retire <target>` | Explicitly retires an Active Target |
| `/no-pushback` | One-turn vent mode; corrections suppressed |
| `/audit` | Reads the last 20 turns and reports drift from the rules in `CLAUDE.md` |

## Research foundations

The rules in `CLAUDE.md` trace to specific findings in the SLA and learning-science literature:

- **Swain (1995)** — Output Hypothesis: pushed output forces noticing, hypothesis testing, metalinguistic reflection.
- **Long (1996)** — Interaction Hypothesis: implicit negative feedback through recasts is well-evidenced.
- **Karpicke & Roediger (2008)** — testing effect: repeated retrieval produces large gains in delayed recall; repeated study does not.
- **Wray (2002)**, **Howarth (1998)**, **Nattinger & DeCarrico (1992)** — formulaic sequences as the substrate of fluency.
- **Segalowitz (2010)** — automaticity and attention control as the basis of fluent action.
- **Schmidt (1990)** — Noticing Hypothesis: conscious attention to form is necessary for uptake.

Anti-sycophancy and anti-drift guardrails draw on contemporary work on LLM failure modes (sycophancy, hallucinated naturalness, confidence laundering).

## What this is not

- **Not a pronunciation tool.** Voice mode handles speaking drills, but systematic accent or phonology work is orthogonal and better served by purpose-built tools.
- **Not multi-learner.** One learner per directory; compounding personalization breaks if multiple people share a KB.
- **Not a substitute for human conversation.** Native interlocutors do things this system can't.
- **Not a clinical or therapeutic product.** "Low-friction, gap-tolerant" is a design choice, not a diagnostic claim.

## How this was built

With my own felt gap, motivation, and conceptual design, the concrete realization came through Claude Opus 4.7. To me, this is the work that matters in the LLM era — if you carry the idea, you can build the tool for it.

## License

MIT.
