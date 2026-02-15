# Design System: The Online Graveyard

## 1. Visual Theme & Atmosphere

A **serene, respectful, and emotionally warm** memorial application. The design evokes the feeling of a quiet sanctuary — contemplative yet not somber. Two distinct moods coexist:

- **Home Feed (Light Mode):** Airy, open, and sky-blue-tinted. A Pinterest-style masonry grid gives each memorial its own visual weight, creating an organic, lived-in feel.
- **Memorial Profile (Dark Mode):** Solemn, ethereal, and intimate. A deep indigo-purple darkness wraps around the content, with a subtle radial gradient creating an almost celestial backdrop. The darkness amplifies the emotional weight of photos and written tributes.

**Font:** Newsreader (serif) — gives the app a newspaper obituary quality: dignified, timeless, literary.

---

## 2. Color Palette & Roles

### Home Screen (Light Theme)
| Color | Hex | Role |
|-------|-----|------|
| Tranquil Blue | `#195de6` | Primary — active chips, FAB, candle counts, bottom nav active icon |
| Cloud White Background | `#f6f8fb` | Scaffold background — slightly blue-tinted off-white |
| Pure White Surface | `#ffffff` | Cards, bottom nav bar, chip backgrounds |
| Slate 800 | `#1e293b` | Primary text (names, headers) |
| Slate 500 | `#64748b` | Secondary text (dates, muted info) |
| Slate 400 | `#94a3b8` | Inactive bottom nav icons, flower counts |
| Slate 200 | `#e2e8f0` | Card borders, chip borders |

### Memorial Profile (Dark Theme)
| Color | Hex | Role |
|-------|-----|------|
| Deep Indigo-Violet | `#3b19e6` | Primary — ethereal gradient source, CTA buttons, candle actions |
| Obsidian Background | `#141121` | Scaffold background — near-black with violet undertone |
| Amber Glow | `#f59e0b` | Candle lit state — warm, sacred, glowing |
| White at 5% | `rgba(255,255,255,0.05)` | Card backgrounds — frosted glass effect |

### Shadows
- **Soft:** `0 10px 40px -10px rgba(25, 93, 230, 0.08)` — hover state, elevated cards
- **Card:** `0 4px 20px -2px rgba(25, 93, 230, 0.05)` — resting card state
- **FAB:** `shadow-blue-500/30` — floating action button glow

---

## 3. Typography Rules

| Element | Font | Weight | Size | Style |
|---------|------|--------|------|-------|
| App Title | Newsreader | Medium (500) | 30px | Tracking tight, two-line break |
| Person Name (Card) | Newsreader | Semibold (600) | 20px | Leading tight |
| Person Name (Profile) | Newsreader | Medium (500) | 30px | — |
| Birth–Death Dates | Newsreader | Normal (400) | 14px | *Italic*, muted color |
| Section Headings | Newsreader | Medium (500) | 20px | — |
| Body Text | Newsreader | Normal (400) | 16px | Leading relaxed |
| Section Divider Label | System | Normal | 12px | ALL CAPS, widest tracking, muted |
| Filter Chips | Newsreader | Normal (400) | 18px | — |

---

## 4. Component Stylings

### Memorial Cards (Home)
- **Shape:** Generously rounded corners (`1.5rem`)
- **Background:** Pure white, whisper-thin border (`slate-100`)
- **Shadow:** Subtle blue-tinted card shadow, elevates on hover
- **Image:** Variable height (masonry layout), gradient overlay from bottom (`black/60`)
- **Hover:** Image scales 105% over 700ms, shadow intensifies
- **Stats Row:** Top border separator, fire icon (candles) in primary blue, flower icon in muted slate

### Filter Chips
- **Active:** Pill-shaped (`rounded-full`), primary blue fill, white text, soft shadow
- **Inactive:** Pill-shaped, white fill, slate border, slate text, subtle border highlight on hover

### Floating Action Button
- **Shape:** Perfect circle (64×64px)
- **Color:** Primary blue with 30% blue shadow glow
- **Icon:** Plus (+) rotates 90° on hover
- **Animation:** Scale 105% hover, scale 95% active press

### Bottom Navigation Bar
- **Style:** Frosted glass (`backdrop-blur-xl`), 90% white opacity
- **Border:** Top hairline border
- **Icons:** Material Icons Round, 24px
- **Active:** Primary blue, Inactive: slate-400
- **Safe area:** Bottom padding for iOS home indicator

### Tribute Video Card (Profile)
- **Shape:** Rounded `xl` corners, full-width
- **Overlay:** Semi-transparent black with centered play button (frosted glass circle)
- **Bottom info:** Gradient fade from black, title + duration text
- **Shadow:** Deep blue-purple shadow (`shadow-primary/20`)

### Tribute Cards (Profile)
- **Background:** White at 5% with `backdrop-blur-sm` (frosted glass)
- **Border:** White at 5% opacity
- **Candle Button (unlit):** Primary/10 background, muted sun icon
- **Candle Button (lit):** Amber/10 background, glowing amber sun icon with `drop-shadow` filter

### Write Tribute CTA
- **Shape:** Pill (`rounded-full`) with edit icon + text
- **Color:** Primary fill, white text
- **Shadow:** Primary at 40% opacity glow
- **Position:** Fixed bottom center, floating

---

## 5. Layout Principles

- **Mobile-first:** All screens designed at ~412px width
- **Home grid:** CSS masonry (2-column, `column-count: 2`, 1rem gap), variable card heights
- **Profile:** Single column, max-width `md` (448px), centered
- **Spacing:** Generous vertical whitespace between sections (mb-8 to mb-12)
- **Safe areas:** iOS status bar (48px top), home indicator (bottom padding)
- **Header:** Sticky with frosted glass blur effect
- **Content padding:** 16–32px horizontal depending on section importance

---

## 6. Key Interactions

| Element | Interaction | Duration |
|---------|-------------|----------|
| Card Image | Scale to 105% on hover | 700ms |
| Gallery Image | Scale to 110% on hover, caption overlay fades in | 500ms |
| FAB "+" Icon | Rotates 90° on hover | 300ms |
| FAB Button | Scale 105% hover / 95% active | Instant |
| Candle Button | Icon transitions from muted to amber glow | Default |
| Header Title | Fades in on scroll (profile page) | 300ms |
