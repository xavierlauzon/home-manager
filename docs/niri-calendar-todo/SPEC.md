# Niri Calendar + To-Do — Product & Design Spec

Single-user personal to-do + calendar for host `blackhawk` / user `sam`, running
containerized on Postgres, hot-syncing to the DankMaterialShell (DMS) calendar
bar, and exposing an MCP server for Hermes.

**Grounding files (the style/data conventions this spec replicates):**

- `/home/sam/src/lumae/solutions/src/app.css` (lines 16–56 canonical tokens;
  lines 191–195 focus ring; lines 85–88 font-feature-settings)
- `/home/sam/src/lumae/solutions/src/lib/server/db/schema.ts` (drizzle pgTable style)
- `/home/sam/src/lumae/solutions/src/lib/server/db/index.ts` (drizzle node-postgres
  boot + migration + seed pattern)
- `/home/sam/src/lumae/solutions/src/lib/server/config.ts` (env/config pattern,
  devMode + fail-closed logic)
- `/home/sam/src/lumae/solutions/src/lib/server/oidc.ts` (OIDC + PKCE)
- `/home/sam/src/lumae/solutions/src/lib/server/session-cookie.ts` (signed cookie
  HMAC-SHA256 pattern)
- `/home/sam/src/lumae/solutions/src/hooks.server.ts` (auth guard)
- `/home/sam/src/lumae/solutions/drizzle.config.ts` (drizzle-kit config)
- `/home/sam/.hermes/skills/creative/popular-web-designs/templates/linear.app.md`
  (task-app aesthetic: 510 weight, luminance stacking, radius/depth scale)

---

## 0. Design adaptation decision (the key call)

The solutions `app.css` is a **marketing page** system: a `content-scrim` over a
`BackgroundFX` liquid-chrome canvas (lines 101–121, 154–162), `scroll-snap`
sections (line 170), and glass surfaces (`--panel-glass*`, lines 34–36) meant to
let a moving background read through.

A to-do/calendar **app shell** does not want any of that. The background is
static (`--canvas`), there is no scroll-snap, and surfaces are **solid
luminance-stacked** panels, not glass-over-chrome. So:

**KEEP from solutions** (verbatim, unchanged):
- Surface ladder `--canvas #08090a`, `--panel #0f1011`, `--panel-2 #191a1b`
- Text ladder `--ink #f7f8f8`, `--ink-soft #d0d6e0`, `--muted #8a8f98`,
  `--faint #62666d`
- Border ladder `--line 0.08`, `--line-strong 0.16`, `--line-subtle 0.05`
- Accent family `--accent #2dd4bf`, `--accent-strong #34d399`,
  `--accent-text #5eead4`, `--accent-soft rgba(45,212,191,0.12)`,
  gradient `--grad-a #34d399` → `--grad-b #60a5fa`
- Fonts: Space Grotesk (display), Inter (sans), JetBrains Mono (mono)
- `font-feature-settings: "cv01", "ss03"` on body (app.css:85–88)
- `color-scheme: dark`, `::selection` (ink-on-canvas), `:focus-visible`
  outline `2px solid var(--accent)` (app.css:191–195)
- `@theme inline` mapping (app.css:58–81)

**DROPPED** (marketing-only):
- `--scrim-color/--scrim-opacity`, `--frost-color/--frost-opacity`,
  `--panel-glass`, `--panel-glass-2`, `--panel-glass-hi` (glass over chrome)
- `.content-scrim`, `.background-host`, `BackgroundFX`, `.scroll-cue*`
- `html { scroll-snap-type: y mandatory }` and `scroll-behavior: smooth`

**ADDED** (app-shell specific) — see token block in §4: an app background (canvas
directly), a proper `--app-radius` scale, a **semantic status palette** for
overdue/due-today/upcoming/priority (the accent is the only brand color; status
uses restrained tints so the UI stays "toned down"), control tokens
(`--control`, `--control-hover`), and a `--focus-ring` that is a shadow stack
rather than a plain outline so it reads on dark.

Elevation in an app is **luminance stepping**, never drop shadows
(linear.app.md §6). Hover = bump `--panel` → `--panel-2`; selected/active =
accent border + `--accent-soft` wash; focus = accent ring.

---

## 1. Feature set

**Lists / projects (grouping):**
- Lists (Projects/Inbox), each with name, optional accent `color`, `icon`,
  `ordr`, `archived`. `Inbox` is a built-in default list (no due-date tasks).
- Tasks belong to zero or one list (null = Inbox).

**Tasks:**
- Title (required), description/notes, due **date** (`yyyy-MM-dd`) + optional
  **time**, priority (low/medium/high/urgent), tags, subtasks (self-FK),
  completed + `completed_at`, soft delete, `position` for manual ordering.
- **Recurrence** on a task: daily/weekly/monthly/yearly, `interval`, `byday`,
  `byMonthDay`, `until`/`count`, timezone. A recurring task is a "template";
  completed instances roll forward to the next occurrence.

**Calendar:**
- Month / Week / Day views (grid). Events from both standalone `events` and
  tasks-with-due-time.
- Standalone events: title, start/end, `allDay`, location, description, url,
  calendar (color group), `completed`.

**Sync (the DMS contract):**
- Materialize `tasks.json` at `~/.config/niri-calendar-todo/tasks.json`:
  `{ "yyyy-MM-dd": [ {id, text, completed}, ... ] }` — the DMS bar hot-reloads.
- Materialize the DMS event list:
  `{id,title,start,end,location,description,url,calendar,color,allDay,isMultiDay,completed}`.

**Reminders (optional, v2):** a `reminders` table + a small scheduler that
emits a desktop notification via a DMS-compatible hook.

**MCP for Hermes:** a thin MCP server exposing the same REST endpoints so the
agent can create/complete/list tasks and read the calendar, authenticated by a
long-lived `MCP_TOKEN`.

**Single-user now, multi-user later:** every table carries a `user_id` FK
(present from day one, so multi-tenant is a data-plumbing exercise, not a
migration). All reads are scoped `WHERE user_id = :me`.

---

## 2. Postgres schema (drizzle-orm, pg-core)

Follows the solutions `schema.ts` style (`pgTable`, snake_case column names,
explicit `.notNull()` / `.default()`, `$inferSelect`/`$inferInsert` types).
UUIDs via `uuid().defaultRandom()` (or `gen_random_uuid()`); `timestamptz`
via `timestamp(..., { withTimezone: true })`.

```ts
// src/lib/server/db/schema.ts
import { sql } from 'drizzle-orm';
import {
  boolean, date, index, integer, jsonb, pgEnum, pgTable, primaryKey,
  text, time, timestamp, uniqueIndex, uuid
} from 'drizzle-orm/pg-core';

export const priorityEnum = pgEnum('priority', ['none', 'low', 'medium', 'high', 'urgent']);
export const recFreqEnum  = pgEnum('rec_freq', ['daily', 'weekly', 'monthly', 'yearly']);

// ---- users (multi-tenant anchor) ----
export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  sub: text('sub').notNull().unique(),          // OIDC sub
  email: text('email').notNull().unique(),
  name: text('name'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow()
}, (t) => ({ emailIdx: uniqueIndex('users_email_idx').on(t.email) }));

// ---- lists / projects ----
export const lists = pgTable('lists', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id),
  name: text('name').notNull(),
  color: text('color'),                          // accent hex, optional
  icon: text('icon'),
  ordr: integer('ordr').notNull().default(0),
  archived: boolean('archived').notNull().default(false),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow()
}, (t) => [
  index('lists_user_idx').on(t.userId),
  uniqueIndex('lists_user_name_idx').on(t.userId, t.name)
]);

// ---- tasks (self-referencing → supports subtasks) ----
export const tasks = pgTable('tasks', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id),
  listId: uuid('list_id').references(() => lists.id),   // null = Inbox
  parentId: uuid('parent_id').references(() => tasks.id), // null = top-level; else subtask
  title: text('title').notNull(),
  description: text('description'),
  dueDate: date('due_date'),                       // 'yyyy-MM-dd' (the DMS key)
  dueTime: time('due_time'),
  priority: priorityEnum('priority').notNull().default('none'),
  completed: boolean('completed').notNull().default(false),
  completedAt: timestamp('completed_at', { withTimezone: true }),
  position: integer('position').notNull().default(0),
  deletedAt: timestamp('deleted_at', { withTimezone: true }), // soft delete
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow()
}, (t) => [
  index('tasks_user_due_idx').on(t.userId, t.dueDate),
  index('tasks_user_completed_idx').on(t.userId, t.completed),
  index('tasks_user_list_idx').on(t.userId, t.listId),
  index('tasks_user_parent_idx').on(t.userId, t.parentId)
]);

// ---- recurrence ----
export const recurrenceRules = pgTable('recurrence_rules', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id),
  taskId: uuid('task_id').notNull().references(() => tasks.id, { onDelete: 'cascade' }).unique(),
  freq: recFreqEnum('freq').notNull(),
  interval: integer('interval').notNull().default(1),
  byday: text('byday'),                 // 'MO,WE' for weekly
  byMonthDay: integer('by_month_day'),
  timezone: text('timezone').notNull().default('UTC'),
  until: date('until'),
  count: integer('count')
}, (t) => [index('rec_user_idx').on(t.userId)]);

// ---- tags (user-scoped, unique per user) ----
export const tags = pgTable('tags', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id),
  name: text('name').notNull(),
  color: text('color')
}, (t) => [uniqueIndex('tags_user_name_idx').on(t.userId, t.name)]);

// ---- task↔tag junction ----
export const taskTags = pgTable('task_tags', {
  taskId: uuid('task_id').notNull().references(() => tasks.id, { onDelete: 'cascade' }),
  tagId: uuid('tag_id').notNull().references(() => tags.id, { onDelete: 'cascade' })
}, (t) => [primaryKey({ columns: [t.taskId, t.tagId] })]);

// ---- calendar events ----
export const events = pgTable('events', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id),
  taskId: uuid('task_id').references(() => tasks.id, { onDelete: 'cascade' }), // optional link
  title: text('title').notNull(),
  start: timestamp('start', { withTimezone: true }).notNull(),
  end: timestamp('end', { withTimezone: true }).notNull(),
  allDay: boolean('all_day').notNull().default(false),
  location: text('location'),
  description: text('description'),
  url: text('url'),
  calendar: text('calendar').notNull().default('default'), // color-group key
  color: text('color'),                                    // hex for DMS
  completed: boolean('completed').notNull().default(false)
}, (t) => [
  index('events_user_start_idx').on(t.userId, t.start),
  index('events_user_end_idx').on(t.userId, t.end)
]);

// ---- reminders (v2) ----
export const reminders = pgTable('reminders', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id),
  taskId: uuid('task_id').references(() => tasks.id, { onDelete: 'cascade' }),
  remindAt: timestamp('remind_at', { withTimezone: true }).notNull(),
  method: text('method').notNull().default('notification'),
  sentAt: timestamp('sent_at', { withTimezone: true })
}, (t) => [index('reminders_due_idx').on(t.remindAt)]);

// ---- MCP / API tokens ----
export const apiTokens = pgTable('api_tokens', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id),
  name: text('name').notNull(),        // e.g. 'hermes-mcp'
  tokenHash: text('token_hash').notNull(), // sha256 of the raw token
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  expiresAt: timestamp('expires_at', { withTimezone: true })
}, (t) => [index('api_tokens_user_idx').on(t.userId)]);

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type List = typeof lists.$inferSelect;
export type Task = typeof tasks.$inferSelect;
export type TaskWithList = Task & { list?: List };
export type Event = typeof events.$inferSelect;
// ... etc for each table
```

**Derivation / sync view (the DMS contract).** A server module
`src/lib/server/dms.ts` reads `tasks` + `events` and produces exactly:

```jsonc
// ~/.config/niri-calendar-todo/tasks.json  (DMS bar hot-reloads this)
{
  "2026-10-27": [ { "id": "…", "text": "Ship v1", "completed": false }, … ],
  "2026-10-28": [ … ]
}
```

and the DMS event list:

```jsonc
[ { "id": "…", "title": "…", "start": "…", "end": "…", "location": null,
    "description": null, "url": null, "calendar": "default", "color": "#2dd4bf",
    "allDay": false, "isMultiDay": false, "completed": false }, … ]
```

`id` is the UUID; `isMultiDay` = `end - start > 1 day`; `calendar`/`color` come
from the event's `calendar`+`color` (or a task's list `color`, defaulting to the
accent). Write the JSON atomically (write-tmp-then-rename) so a hot-reload never
reads a half-written file. `dms.ts` re-materializes on every create/update/delete
and on a schedule.

**Where the file lives (per AGENTS.md rule 5, this is user data, not a secret):**
`~/.config/niri-calendar-todo/`. The container must mount `~/.config/niri-calendar-todo`
read-write into the app, and the app (not the shell) owns the write. Keep the
path in `config.ts` (`dmsTasksPath`, `dmsEventsPath`).

**Recurrence model:** `recurrence_rules` is 1:1 with a template task. On the
template's `dueDate`, the sync/rollover job marks the instance done and clones a
new task with the next `dueDate` computed from `freq`/`interval`/`byday`/
`byMonthDay` in `timezone`. The template stays `completed=false`; instances are
plain tasks. (Simple + inspectable — no exploding series in the DB.)

---

## 3. REST API surface

Reuses the solutions auth stack verbatim (OIDC + PKCE in `oidc.ts`, signed
cookie in `session-cookie.ts`, guard in `hooks.server.ts`), plus an
`Authorization: Bearer <MCP_TOKEN>` path for the agent.

**Auth**
- `GET /api/auth/login?next=` → 303 to IdP (copy `oidc.ts:createAuthorizeUrl`).
- `GET /api/auth/callback` → exchange code, set cookie (copy `exchangeCode`).
- `GET /api/auth/logout`, `GET /api/auth/me`.
- `hooks.server.ts` guard: protect `/app/**` and `/api/**` (except `/api/auth/*`,
  `/api/health`). Copy the `readSessionCookie` check from lines 16–28.
- **MCP/agent auth:** `Authorization: Bearer <token>` → sha256(token) matched
  against `api_tokens.token_hash`, scoped to `userId`. Generate tokens server-side
  (`POST /api/tokens`) and only ever store the hash.

**Conventions:** JSON in/out; `GET` list endpoints support
`?list=&due=&tag=&q=&completed=&priority=&from=&to=`. All routes resolve the
authenticated `userId` from the cookie or bearer token and scope every query
with `WHERE user_id = :me`. Errors: `{ error: string }` with 400/401/403/404/409.

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/health` | liveness (public) |
| GET | `/api/lists` | list projects |
| POST | `/api/lists` | create list `{name,color?,icon?}` |
| PATCH | `/api/lists/:id` | rename/recolor/reorder/archive |
| DELETE | `/api/lists/:id` | archive (soft) |
| GET | `/api/tasks` | filter tasks |
| POST | `/api/tasks` | create `{title,listId?,parentId?,dueDate?,dueTime?,priority?,tags?[]}` |
| GET | `/api/tasks/:id` | fetch + recurrence + tags |
| PATCH | `/api/tasks/:id` | update any field incl. `completed` |
| DELETE | `/api/tasks/:id` | soft delete |
| POST | `/api/tasks/:id/complete` | toggle completed (sets `completedAt`) |
| GET | `/api/events` | calendar events in `[from,to]` |
| POST | `/api/events` | create event |
| PATCH | `/api/events/:id` | update |
| DELETE | `/api/events/:id` | delete |
| GET | `/api/tags` | list tags |
| POST | `/api/tags` | create |
| GET | `/api/sync/tasks.json` | the derived DMS tasks.json view (read-only) |
| GET | `/api/sync/events` | the derived DMS event list |
| POST | `/api/tokens` | issue an MCP token (admin) |
| GET | `/api/tokens` | list active tokens |

**Response shape (task):**
```jsonc
{
  "id": "…", "title": "…", "description": "…",
  "listId": null, "parentId": null, "dueDate": "2026-10-27", "dueTime": "09:30",
  "priority": "medium", "completed": false, "completedAt": null,
  "tags": [{ "id": "…", "name": "work", "color": null }],
  "recurrence": { "freq": "weekly", "interval": 1, "byday": "MO,WE", "timezone": "America/Toronto" }
}
```

---

## 4. Frontend design specification

### 4.1 Token block (adapted for an app shell) — `src/app.css`

Keep `@import "tailwindcss"` + the three `@fontsource-variable/*` imports
(app.css:1–4). Replace the `:root` block. Keep the `@theme inline` mapping, then
add the app-shell additions:

```css
:root {
	/* Surfaces — luminance-stacked. NO glass, NO scrim (static app bg). */
	--canvas: #08090a;
	--panel: #0f1011;       /* app background */
	--panel-2: #191a1b;     /* elevated: selected row, popover, dialog, hover */
	--panel-3: #212224;     /* NEW: hover on elevated surfaces */

	/* Text — luminance ladder (unchanged) */
	--ink: #f7f8f8;
	--ink-soft: #d0d6e0;
	--muted: #8a8f98;
	--faint: #62666d;

	/* Borders — whisper-thin white (unchanged) */
	--line: rgba(255, 255, 255, 0.08);
	--line-strong: rgba(255, 255, 255, 0.16);
	--line-subtle: rgba(255, 255, 255, 0.05);

	/* Accent — the only chromatic color (unchanged) */
	--accent: #2dd4bf;
	--accent-strong: #34d399;
	--accent-text: #5eead4;
	--accent-soft: rgba(45, 212, 191, 0.12);
	--grad-a: #34d399;
	--grad-b: #60a5fa;

	/* NEW — status palette (restrained tints; accent stays the brand color).
	   Used for due/overdue/priority; saturations kept low so the app stays toned-down. */
	--ok: #34d399;            /* emerald — done / healthy */
	--warn: #fbbf24;          /* amber — due today */
	--danger: #f87171;        /* red — overdue / urgent */
	--info: #60a5fa;          /* blue — upcoming */

	/* NEW — control tokens (inputs, buttons, checkboxes) */
	--control: rgba(255, 255, 255, 0.02);          /* input/ghost bg */
	--control-hover: rgba(255, 255, 255, 0.04);    /* hover bg */
	--control-pressed: rgba(255, 255, 255, 0.06);  /* pressed/active bg */

	/* NEW — radius scale (Linear-style: micro→panel) */
	--r-micro: 2px;   /* inline badges, toolbar buttons */
	--r-sm: 4px;      /* small containers, list items */
	--r-md: 6px;      /* buttons, inputs */
	--r-lg: 8px;      /* cards, dropdowns, popovers */
	--r-panel: 12px;  /* panels, dialogs, command palette */

	/* NEW — focus ring (shadow stack reads on dark, beats a plain outline) */
	--focus-ring: 0 0 0 2px var(--canvas), 0 0 0 4px var(--accent);

	color-scheme: dark;
}

@theme inline {
	/* keep all the --color-* mappings from app.css:58-81 */
	--color-canvas: var(--canvas);
	--color-panel: var(--panel);
	--color-panel-2: var(--panel-2);
	--color-panel-3: var(--panel-3);
	--color-ink: var(--ink);
	--color-ink-soft: var(--ink-soft);
	--color-muted: var(--muted);
	--color-faint: var(--faint);
	--color-line: var(--line);
	--color-line-strong: var(--line-strong);
	--color-line-subtle: var(--line-subtle);
	--color-accent: var(--accent);
	--color-accent-strong: var(--accent-strong);
	--color-accent-text: var(--accent-text);
	--color-accent-soft: var(--accent-soft);
	--color-ok: var(--ok);
	--color-warn: var(--warn);
	--color-danger: var(--danger);
	--color-info: var(--info);
	--color-control: var(--control);
	--color-control-hover: var(--control-hover);

	--font-display: "Space Grotesk Variable", ui-sans-serif, system-ui, sans-serif;
	--font-sans: "Inter Variable", ui-sans-serif, system-ui, sans-serif;
	--font-mono: "JetBrains Mono Variable", ui-monospace, "SF Mono", monospace;
}

body { background: var(--canvas); color: var(--ink); font-family: var(--font-sans);
	-webkit-font-smoothing: antialiased; text-rendering: optimizeLegibility; }
body, .font-sans { font-feature-settings: "cv01", "ss03"; }
::selection { background: var(--ink); color: var(--canvas); }
:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; border-radius: 2px; }
```

**App-shell directives (what to remove / not include):** no `.content-scrim`,
no `.background-host`, no `html { scroll-snap-type }`, no `--panel-glass*`, no
`BackgroundFX` import. The app's root is `background: var(--canvas)` directly.

### 4.2 Typography scale (app, not marketing)

| Role | Font | Size | Weight | LH | Tracking | Color |
|---|---|---|---|---|---|---|
| App title (sidebar) | Space Grotesk | 15px | 500 | 1.2 | -0.2px | `--ink` |
| View title (list header) | Space Grotesk | 20px | 500 | 1.25 | -0.3px | `--ink` |
| Task title | Inter | 14px | 510 | 1.4 | normal | `--ink` |
| Task title (done) | Inter | 14px | 400 | 1.4 | normal | `--muted`, `text-decoration: line-through` |
| Meta (due, tags, list) | Inter | 12px | 510 | 1.4 | normal | `--muted` |
| Day-of-week / calendar | Inter | 11px | 510 | 1.4 | +0.02em | `--faint`, uppercase |
| Date number | Inter | 13px | 510 | 1.2 | normal | `--ink` |
| Eyebrow / section label | JetBrains Mono | 11px | 400 | 1.4 | +0.18em | `--accent-text`, uppercase |
| Button / chip label | Inter | 12px | 510 | 1.4 | normal | `--ink-soft` |
| Dialog title | Inter | 16px | 590 | 1.3 | -0.2px | `--ink` |

Weights: 400 read, **510 the workhorse**, 590 emphasis. Never 700. Never pure
white (`#f7f8f8` is max). Font `510` is Inter Variable's fractional weight —
keep the variable font (no static weights) so 510 renders. If a static Inter
must be used, fall back to `500` and accept slightly heavier emphasis.

### 4.3 Spacing + radius

- Base unit **8px** (linear.app.md §5). Scale: 2, 4, 6, 8, 12, 16, 24, 32, 40, 48.
- Padding: list rows 8px 12px; card/dialog padding 16–20px; sidebar 12px;
  calendar cell 6px.
- Gap: list `gap-y-0` (rows are full-width, divider `--line-subtle`); grid
  `gap-2`; toolbar `gap-1`.
- Radius mapping: checkbox/control `--r-sm`; buttons/inputs `--r-md`;
  cards/popovers `--r-lg`; dialog/command palette `--r-panel`; chips `9999px`.

### 4.4 Component specs

**App shell (layout)**
- Root: `display: grid; grid-template-columns: 240px 1fr;` on `--canvas`.
- **Sidebar** (240px, `background: var(--panel)`, right border
  `1px solid var(--line)`): list tree + "＋ New list" ghost button. Active list =
  `background: var(--panel-2)`, left accent bar `2px solid var(--accent)`,
  text `--ink`; inactive list text `--ink-soft`.
- **Main list header**: Space Grotesk title + eyebrow (JetBrains Mono, uppercase,
  `--accent-text`) + toolbar (view switcher, "＋ New task").
- **Calendar grid**: 7-column; cell `background: var(--panel)`, border
  `1px solid var(--line-subtle)`; today's date number = `--accent` in a filled
  `--accent` circle; event chip = `background: var(--accent-soft)`,
  `color: var(--accent-text)`, `border-left: 2px solid var(--accent)`.

**Task row** (the core unit)
- Container: `padding: 8px 12px; border-bottom: 1px solid var(--line-subtle);
  border-radius: var(--r-sm); background: transparent;`
- **Hover**: `background: var(--panel)` (luminance step, no shadow).
- **Selected/active**: `background: var(--panel-2); outline: 1px solid var(--line-strong)`.
- Grid: `[checkbox] [content] [meta]`, checkbox 16px, gap 10px.
- **Checkbox** (custom, since it's the signature control):
  ```css
  .checkbox { width:16px; height:16px; border-radius: var(--r-sm);
    border: 1px solid var(--line-strong); background: var(--control);
    transition: background .12s ease, border-color .12s ease; }
  .checkbox:hover { border-color: var(--accent); background: var(--control-hover); }
  .checkbox[aria-checked="true"] { background: var(--accent-strong);
    border-color: var(--accent-strong); color: var(--canvas); }
  ```
  Checked = filled `--accent-strong` with a `--canvas` check mark (accent = done,
  matching the accent-for-active rule).
- **Due-date meta**: `font-mono`, 12px. Overdue → `color: var(--danger)`.
  Due today → `--warn`. Tomorrow/upcoming → `--muted`.
- **Priority chip**: `medium` = `--accent`; `high` = `--warn`; `urgent` = `--danger`.
  Rendered as a 6px dot + mono label, `color: <status>`.
- **Tag chips**: `background: var(--control); color: var(--ink-soft);
  border: 1px solid var(--line-subtle); border-radius: 9999px; padding: 0 8px;
  font: 11px/1.4 510 var(--font-sans);`

**Date picker** (popover)
- `background: var(--panel-2); border: 1px solid var(--line-strong);
  border-radius: var(--r-panel); padding: 12px; box-shadow: var(--focus-ring)
  removed / use multi-layer (linear.app.md §6 Level 5).`
- Header: month name (Inter 510 14px `--ink`) + chevrons (ghost icon buttons).
- Grid: 7×N cells; selected day = filled `--accent` circle with `--canvas` text;
  today = `border: 1px solid var(--accent)`; hover = `background: var(--panel)`.

**Dialog / modal** (task edit, quick-add)
- Overlay: `background: rgba(0,0,0,0.85)` (linear.app.md overlay primary).
- Panel: `background: var(--panel-2); border: 1px solid var(--line-strong);
  border-radius: var(--r-panel); box-shadow: 0 8px 24px rgba(0,0,0,.5);`
  title 16px/590, fields labeled with mono eyebrow `--accent-text`.
- Inputs: `background: var(--control); border: 1px solid var(--line);
  border-radius: var(--r-md); padding: 8px 12px; color: var(--ink);`
  focus → `border-color: var(--accent); box-shadow: var(--focus-ring)`.

**Buttons**
- Primary (accent): `background: var(--accent-strong); color: var(--canvas);
  border-radius: var(--r-md); padding: 6px 14px; font 12px/1.4 510;`
  hover `filter: brightness(1.08)`.
- Ghost/secondary: `background: var(--control); color: var(--ink-soft);
  border: 1px solid var(--line);` hover `--control-hover`.
- Icon button: 28×28, `border-radius: var(--r-md)`, `background: transparent`,
  hover `--control`; color `--muted` → hover `--ink`.
- **Focus** on any control: `box-shadow: var(--focus-ring)` (shadow stack, not
  plain outline — reads better on dark).

**Empty states:** centered, `--faint` text + mono eyebrow, on `--canvas`.

### 4.5 Interaction principles (toned-down)
- Motion: only 120–150ms ease transitions on color/background (no spring/bounce,
  no liquid chrome). Respect `prefers-reduced-motion` (copy app.css:197–207).
- The only saturated color is the green→blue accent + the restrained status
  tints; everything else is the luminance ladder.
- Every interactive element has a visible `:focus-visible` accent ring.
- Keyboard-first: `Cmd+K` command palette, `n` new task, `e` edit, `x` complete,
  arrow navigation in list/calendar.

---

## 5. Tech-stack recommendation + build/container notes

**Stack (mirrors solutions):**
- **SvelteKit (Svelte 5, `adapter-node`)** — reuse the `$props()`/`$state()` Svelte 5
  idioms from `header.svelte`/`service-card.svelte` (runes `$props`, `$state`,
  `$derived`).
- **drizzle-orm + drizzle-kit + `node-postgres`** — copy `db/index.ts` (Pool,
  `migrate`, `seedIfEmpty`, fallback mode) and `drizzle.config.ts` verbatim.
- **Tailwind** with the `@theme inline` tokens (same as solutions) for class-
  based styling; use the token classes (`bg-panel-2`, `text-muted`,
  `border-line`, `bg-accent-soft`) as `service-card.svelte` does.
- **OIDC auth**: reuse `oidc.ts` + `session-cookie.ts` + `hooks.server.ts` from
  solutions (they're already generic — just swap `SESSION_COOKIE` name and
  `OIDC_CLIENT_ID`).
- **@sveltejs/kit** + **svelte 5** for the SPA; a tiny **scheduler**
  (`node-cron` or a `setInterval` in the node server) that runs the DMS
  re-materialization + recurrence rollover + reminder emission.

**Container notes (host `blackhawk`, all containerized):**
- Single container: SvelteKit node server + drizzle migrations + the DMS sync
  writer, all in one image (matches solutions' container model).
- Mount `~/.config/niri-calendar-todo` **read-write** into the container so the
  DMS bar's host process sees the updated `tasks.json`. The container writes the
  file (via the `dms.ts` module) — the shell/host never does.
- Postgres as a sibling container (same docker network as the solutions DB, or a
  dedicated DB + user).
- Env (via `config.ts`, copying the `.env` loader at config.ts:10–30):
  `DATABASE_URL`, `PUBLIC_URL`, `OIDC_ISSUER`, `OIDC_CLIENT_ID`,
  `OIDC_CLIENT_SECRET`, `SESSION_SECRET`, `DMS_TASKS_PATH`,
  `DMS_EVENTS_PATH`, `MCP_TOKEN`.
- Keep the fail-closed `devMode` logic (config.ts:66–70): refuse `devMode`
  behind a public `https` URL.

**MCP server for Hermes:** a thin wrapper (Node `stdio` MCP server, e.g. via
`@modelcontextprotocol/sdk`) exposing `list_tasks`, `create_task`,
`complete_task`, `list_events`, `create_event`. It authenticates with
`Authorization: Bearer $MCP_TOKEN` against the same REST API. Register it in the
user's home-manager config so Hermes can call it (the AGENTS.md note that
`node/npm/bun` aren't on PATH → run under `nix shell nixpkgs#nodejs_22`).

**Build notes:**
- `drizzle-kit generate` → commit migration + snapshot (solutions
  `drizzle/meta/*.json` pattern); `drizzle-kit push` only in dev.
- `node_modules`/`.svelte-kit`/`build` gitignored (like solutions).
- Seed: copy `seedIfEmpty` from `db/index.ts` to create the default `Inbox` list
  and the `hermes-mcp` token row for a first-run user.

---

## 6. Open items / decisions to confirm with the user
- Confirm the DMS tasks.json **path** (`~/.config/niri-calendar-todo/tasks.json`
  is the spec's assumption) and whether the bar wants events via a file or a
  socket/HTTP poll.
- Confirm `MCP_TOKEN` should be provisioned via the DB (`api_tokens`) vs. a
  single env token.
- Confirm whether "calendar" events are user-created or should also derive from
  all tasks with a due date (spec keeps them separate + links via `task_id`).
