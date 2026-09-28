// The theme generator behind AppicaUI::Blocks::ThemeCustomizer - a port of the Appica UI customizer.
//
// A theme is { mode, base, primary, secondary, radius, font, disableAnimations }: `base` is a
// neutral scale (gray, mauve…), `primary` "base" (the neutral's darkest shades), an accent name
// or a custom color ("#6d6bb5", "oklch(…)"), `secondary` an accent or a custom color. Every token
// in theme.css is read from a shade of those scales; overridesCss() returns only the tokens that
// differ from the defaults - paste them after `@import ".../appica_ui/index.css"`.
//
// applyTheme() writes them into a <style> in the page (and loads a web font); the stored theme is
// re-applied on every page that imports this module, and follows changes made in other tabs.
import { PALETTE, NEUTRAL_COLORS, ACCENT_COLORS } from "appica_ui/blocks/theme_customizer/theme_palette"

export { PALETTE, NEUTRAL_COLORS, ACCENT_COLORS }

export const STORAGE_KEY = "ui-components:theme"
export const DEFAULT_THEME = { mode: "system", base: "gray", primary: "base", secondary: "blue", radius: "large", font: "system", disableAnimations: false }

export const RADIUS_VALUES = { none: "0rem", xsmall: "0.375rem", small: "0.5rem", medium: "0.625rem", large: "0.875rem", xlarge: "1.375rem" }

// Google Fonts families; "system" keeps Tailwind's font stack
export const FONTS = {
  system: null,
  geist: { family: "Geist", stack: "ui-sans-serif, system-ui, sans-serif" },
  "geist-mono": { family: "Geist Mono", stack: "ui-monospace, SFMono-Regular, monospace" },
  inter: { family: "Inter", stack: "ui-sans-serif, system-ui, sans-serif" },
  figtree: { family: "Figtree", stack: "ui-sans-serif, system-ui, sans-serif" },
  urbanist: { family: "Urbanist", stack: "ui-sans-serif, system-ui, sans-serif" },
  "dm-sans": { family: "DM Sans", stack: "ui-sans-serif, system-ui, sans-serif" },
  outfit: { family: "Outfit", stack: "ui-sans-serif, system-ui, sans-serif" },
  manrope: { family: "Manrope", stack: "ui-sans-serif, system-ui, sans-serif" },
  fraunces: { family: "Fraunces", stack: "ui-serif, Georgia, serif" },
  "public-sans": { family: "Public Sans", stack: "ui-sans-serif, system-ui, sans-serif" },
  "instrument-sans": { family: "Instrument Sans", stack: "ui-sans-serif, system-ui, sans-serif" },
  "host-grotesk": { family: "Host Grotesk", stack: "ui-sans-serif, system-ui, sans-serif" },
  "jetbrains-mono": { family: "JetBrains Mono", stack: "ui-monospace, SFMono-Regular, monospace" }
}

// Token → shade of the base (neutral) scale
const BASE_LIGHT = {
  "--foreground": 600, "--foreground-subtle": 400, "--foreground-muted": 500, "--foreground-strong": 700,
  "--foreground-emphasis": 800, "--foreground-intense": 900, "--foreground-inverse": "white",
  "--background": "white", "--background-subtle": 50, "--background-muted": 100, "--background-strong": 200, "--background-inverse": 950,
  "--border": 200, "--border-muted": 100, "--border-strong": 300, "--border-emphasis": 400, "--border-intense": 500,
  "--border-inverse": 800, "--border-overlay": 100, "--focus-ring": 300, "--focus-ring-input": 200,
  "--shadow-color": [ 500, 18 ], "--selection-color": [ 950, 10 ]
}
const BASE_DARK = {
  "--foreground": 300, "--foreground-subtle": 500, "--foreground-muted": 400, "--foreground-strong": 200,
  "--foreground-emphasis": 100, "--foreground-intense": "white", "--foreground-inverse": 900,
  "--background": 950, "--background-subtle": [ 500, 8 ], "--background-muted": 900, "--background-strong": 800, "--background-inverse": "white",
  "--border": 800, "--border-muted": 900, "--border-strong": 700, "--border-emphasis": 600, "--border-intense": 500,
  "--border-inverse": 200, "--border-overlay": 800, "--focus-ring": 700, "--focus-ring-input": 800,
  "--shadow-color": [ "black", 30 ], "--selection-color": [ "white", 15 ]
}
// Primary "base": the neutral itself
const PRIMARY_BASE_LIGHT = { "--primary": 900, "--primary-subtle": 100, "--primary-soft": 200, "--primary-muted": 700, "--primary-strong": 950, "--primary-foreground": "white", "--focus-ring-primary": 300 }
const PRIMARY_BASE_DARK = { "--primary": "white", "--primary-subtle": 900, "--primary-soft": 800, "--primary-muted": 200, "--primary-strong": "white", "--primary-foreground": 900, "--focus-ring-primary": 700 }
// Primary accent
const PRIMARY_LIGHT = { "--primary": 500, "--primary-subtle": [ 500, 10 ], "--primary-soft": [ 500, 20 ], "--primary-muted": 400, "--primary-strong": 600, "--primary-foreground": "white", "--focus-ring-primary": [ 500, 30 ] }
const PRIMARY_DARK = { ...PRIMARY_LIGHT, "--focus-ring-primary": [ 500, 50 ] }
// Secondary accent; its foreground is the base's darkest shade
const SECONDARY_LIGHT = {
  "--secondary": 300, "--secondary-subtle": [ 500, 10 ], "--secondary-soft": [ 500, 20 ], "--secondary-muted": 200, "--secondary-strong": 400,
  "--secondary-emphasis": 500, "--secondary-intense": 600, "--secondary-foreground": { shade: 950, fromBase: true }, "--focus-ring-secondary": [ 500, 30 ]
}
const SECONDARY_DARK = { ...SECONDARY_LIGHT, "--secondary": 400, "--secondary-muted": 300, "--focus-ring-secondary": [ 500, 50 ] }

export function isCustomColor(color) {
  return typeof color === "string" && (color.startsWith("#") || color.startsWith("oklch") || color.startsWith("rgb"))
}

// [ [ "--primary", "oklch(…)" ], … ] for "light" or "dark"
export function themeTokens(theme, mode) {
  const { base, primary, secondary, radius } = { ...DEFAULT_THEME, ...theme }
  const primaryIsBase = primary === "base"
  const tokens = []
  const add = (map, color) => Object.entries(map).forEach(([ name, spec ]) => tokens.push([ name, shadeValue(spec, color, base) ]))

  add(mode === "light" ? BASE_LIGHT : BASE_DARK, base)
  add(primaryIsBase ? (mode === "light" ? PRIMARY_BASE_LIGHT : PRIMARY_BASE_DARK) : (mode === "light" ? PRIMARY_LIGHT : PRIMARY_DARK), primaryIsBase ? base : primary)
  add(mode === "light" ? SECONDARY_LIGHT : SECONDARY_DARK, secondary)
  if (mode === "light") tokens.push([ "--radius", RADIUS_VALUES[radius] || RADIUS_VALUES.large ])
  return tokens
}

// Only the tokens that differ from the default theme (dark repeats what changed in light, like Appica)
export function overridesCss(theme) {
  theme = { ...DEFAULT_THEME, ...theme }
  const light = themeTokens(theme, "light"), dark = themeTokens(theme, "dark")
  const defaultLight = new Map(themeTokens(DEFAULT_THEME, "light")), defaultDark = new Map(themeTokens(DEFAULT_THEME, "dark"))
  const changedLight = new Set(light.filter(([ name, value ]) => defaultLight.get(name) !== value).map(([ name ]) => name))
  const changedDark = new Set(dark.filter(([ name, value ]) => defaultDark.get(name) !== value).map(([ name ]) => name))

  const font = FONTS[theme.font]
  const lightLines = light.filter(([ name ]) => changedLight.has(name)).map(([ name, value ]) => `  ${name}: ${value};`)
  if (font) lightLines.push(`  --font-sans: "${font.family}", ${font.stack};`)
  const darkLines = dark.filter(([ name ]) => changedDark.has(name) || changedLight.has(name)).map(([ name, value ]) => `  ${name}: ${value};`)

  const blocks = []
  if (font) blocks.push(`/* Load the font in your layout: <link rel="stylesheet" href="${fontUrl(font)}"> */`)
  if (lightLines.length) blocks.push(`:root,\n.light {\n${lightLines.join("\n")}\n}`)
  if (darkLines.length) blocks.push(`.dark {\n${darkLines.join("\n")}\n}`)
  return blocks.length ? `${blocks.join("\n\n")}\n` : ""
}

export function fontUrl(font) {
  return `https://fonts.googleapis.com/css2?family=${font.family.replace(/ /g, "+")}:wght@400;500;600;700&display=swap`
}

// Storage

export function loadTheme() {
  try {
    return { ...DEFAULT_THEME, ...JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}") }
  } catch {
    return { ...DEFAULT_THEME }
  }
}

export function saveTheme(theme) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(theme))
  } catch {}
}

export function resetTheme() {
  try {
    localStorage.removeItem(STORAGE_KEY)
  } catch {}
}

// Applying

const STYLE_ID = "ui-components-theme"
const FONT_LINK_ID = "ui-components-theme-font"

export function applyTheme(theme, doc = document) {
  theme = { ...DEFAULT_THEME, ...theme }
  const root = doc.documentElement

  let style = doc.getElementById(STYLE_ID)
  if (!style) {
    style = doc.createElement("style")
    style.id = STYLE_ID
    doc.head.append(style)
  }
  style.textContent = overridesCss(theme).replace(/^\/\*.*\*\/\n\n/, "")

  const font = FONTS[theme.font]
  let link = doc.getElementById(FONT_LINK_ID)
  if (font) {
    if (!link) {
      link = doc.createElement("link")
      link.id = FONT_LINK_ID
      link.rel = "stylesheet"
      doc.head.append(link)
    }
    link.href = fontUrl(font)
  } else {
    link?.remove()
  }

  // "system" follows the OS - unless the page picked its own mode (data-theme-locked, e.g.
  // Lookbook's Theme display option); an explicit light / dark always wins
  if (theme.mode !== "system" || !root.hasAttribute("data-theme-locked")) {
    const dark = theme.mode === "dark" || (theme.mode === "system" && doc.defaultView.matchMedia("(prefers-color-scheme: dark)").matches)
    root.classList.toggle("dark", dark)
    root.classList.toggle("light", !dark)
    root.style.colorScheme = dark ? "dark" : "light"
  }
  root.toggleAttribute("data-disable-animations", !!theme.disableAnimations)
}

// Applies the stored theme now and whenever it changes in another tab or frame
export function watchStoredTheme() {
  applyTheme(loadTheme())
  window.addEventListener("storage", event => {
    if (event.key === STORAGE_KEY || event.key === null) applyTheme(loadTheme())
  })
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => applyTheme(loadTheme()))
}

// Color math

// "white" | "black" | shade | [ shade, alpha ] | { shade, fromBase }
function shadeValue(spec, color, base) {
  const { shade, alpha, fromBase } = Array.isArray(spec) ? { shade: spec[0], alpha: spec[1] } : typeof spec === "object" ? spec : { shade: spec }
  let value
  if (shade === "white") value = "oklch(1 0 0)"
  else if (shade === "black") value = "oklch(0 0 0)"
  else value = scaleFor(fromBase ? base : color, base)[shade]
  return alpha == null ? value : value.replace(/\)\s*$/, ` / ${alpha}%)`)
}

const scales = new Map()

function scaleFor(color, fallback) {
  if (!isCustomColor(color)) return PALETTE[color] || PALETTE[fallback] || PALETTE.gray

  if (!scales.has(color)) {
    let scale
    try { scale = customScale(color) } catch { scale = PALETTE.blue }
    if (scales.size >= 64) scales.clear()
    scales.set(color, scale)
  }
  return scales.get(color)
}

// A Tailwind-like 50…950 scale around any color: its lightness anchors the 500 step, lighter and
// darker steps spread toward Tailwind's lightness curve, chroma follows the curve's profile and is
// clipped to the sRGB gamut.
const STEPS = [ [ 50, 0.977, 0.087 ], [ 100, 0.95, 0.208 ], [ 200, 0.905, 0.399 ], [ 300, 0.84, 0.659 ], [ 400, 0.754, 0.904 ], [ 500, 0.683, 1 ],
  [ 600, 0.598, 0.982 ], [ 700, 0.515, 0.861 ], [ 800, 0.446, 0.708 ], [ 900, 0.395, 0.568 ], [ 950, 0.278, 0.401 ] ]

export function customScale(color) {
  const [ l, c, h ] = toOklch(color)
  const lighter = Math.max(0, 0.977 - l) / (0.977 - 0.683)
  const darker = Math.max(0, l - 0.278) / (0.683 - 0.278)
  const round = (value, digits) => Math.round(value * 10 ** digits) / 10 ** digits
  const scale = {}

  for (const [ step, target, chroma ] of STEPS) {
    const lightness = clamp(l + (target - 0.683) * (step < 500 ? lighter : step > 500 ? darker : 1), 0, 1)
    const hue = c < 1e-6 ? 0 : ((h % 360) + 360) % 360
    const scaledChroma = Math.min(c * chroma, maxChroma(lightness, hue))
    scale[step] = `oklch(${round(lightness * 100, 2)}% ${round(scaledChroma, 4)} ${round(hue, 2)})`
  }
  return scale
}

// "#rgb[a]" / "#rrggbb[aa]" / "rgb(…)" / "oklch(…)" → [ L 0…1, C, H degrees ]
function toOklch(input) {
  const text = input.trim().toLowerCase()
  const oklch = /^oklch\(\s*(-?[\d.]+)(%?)[\s,]+(-?[\d.]+)(%?)[\s,]+(-?[\d.]+)/.exec(text)
  if (oklch) return [ clamp(Number(oklch[1]) / (oklch[2] ? 100 : 1), 0, 1), Math.max(0, Number(oklch[3]) * (oklch[4] ? 0.004 : 1)), Number(oklch[5]) ]

  let r, g, b
  const hex = /^#([0-9a-f]{3,8})$/.exec(text)
  const rgb = /^rgba?\(([^)]*)\)$/.exec(text)
  if (hex && [ 3, 4, 6, 8 ].includes(hex[1].length)) {
    const digits = hex[1], short = digits.length <= 4, size = short ? 1 : 2
    const channel = index => parseInt(short ? digits[index].repeat(2) : digits.slice(index * size, index * size + size), 16) / 255
    ;[ r, g, b ] = [ channel(0), channel(1), channel(2) ]
  } else if (rgb) {
    const parts = rgb[1].replace("/", " ").split(/[\s,]+/).filter(Boolean)
    if (parts.length < 3) throw new Error(`Invalid color "${input}"`)
    ;[ r, g, b ] = parts.slice(0, 3).map(part => part.endsWith("%") ? parseFloat(part) / 100 : parseFloat(part) / 255)
  } else {
    throw new Error(`Invalid color "${input}"`)
  }

  const linear = value => { value = clamp(value, 0, 1); return value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4 }
  const [ lr, lg, lb ] = [ linear(r), linear(g), linear(b) ]
  const l_ = Math.cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb)
  const m_ = Math.cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb)
  const s_ = Math.cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb)
  const L = 0.2104542553 * l_ + 0.793617785 * m_ - 0.0040720468 * s_
  const A = 1.9779984951 * l_ - 2.428592205 * m_ + 0.4505937099 * s_
  const B = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.808675766 * s_
  const C = Math.sqrt(A * A + B * B)
  return [ clamp(L, 0, 1), C, C < 1e-6 ? 0 : (Math.atan2(B, A) * 180 / Math.PI + 360) % 360 ]
}

// The largest chroma at this lightness and hue that stays inside the Display P3 gamut (binary search)
function maxChroma(lightness, hue) {
  const radians = hue * Math.PI / 180, cos = Math.cos(radians), sin = Math.sin(radians)
  const inGamut = chroma => {
    const a = chroma * cos, b = chroma * sin
    const l = (lightness + 0.3963377774 * a + 0.2158037573 * b) ** 3
    const m = (lightness - 0.1055613458 * a - 0.0638541728 * b) ** 3
    const s = (lightness - 0.0894841775 * a - 1.291485548 * b) ** 3
    const r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    const g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    const bl = -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s
    // Appica checks the Display P3 gamut
    const p3r = 0.822462 * r + 0.1775379 * g, p3g = 0.0331942 * r + 0.9668059 * g, p3b = 0.0170826 * r + 0.0723974 * g + 0.9105199 * bl
    return [ p3r, p3g, p3b ].every(channel => channel >= -1e-4 && channel <= 1.0001)
  }
  if (inGamut(0.5)) return 0.5
  let low = 0, high = 0.5
  for (let i = 0; i < 20; i++) {
    const middle = (low + high) / 2
    inGamut(middle) ? low = middle : high = middle
  }
  return low
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value))
}
