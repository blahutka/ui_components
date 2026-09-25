// Places a popup (position: fixed) against an anchor - an element or a rect { left, top,
// right, bottom } - like Floating UI: the preferred `side` (bottom / top / left / right /
// inline_end / inline_start), flipped when there's no room, `align` (start / center / end) along
// it, offsets, clamped to the viewport. An `arrow` element inside the popup is slid to point at
// the anchor's center. Sets data-side on the popup and the arrow, --transform-origin and
// --available-height; returns the side used.
export function placeFloating(popup, anchor, { side = "bottom", align = "center", sideOffset = 6, alignOffset = 0, arrow = null, margin = 8 } = {}) {
  const rect = anchor.getBoundingClientRect ? anchor.getBoundingClientRect() : { ...anchor, width: anchor.right - anchor.left, height: anchor.bottom - anchor.top }
  const rtl = getComputedStyle(popup).direction === "rtl"
  const width = popup.offsetWidth
  const height = popup.offsetHeight
  const logical = side
  if (side === "inline_end" || side === "inline-end") side = rtl ? "left" : "right"
  if (side === "inline_start" || side === "inline-start") side = rtl ? "right" : "left"

  const fits = {
    bottom: rect.bottom + sideOffset + height <= window.innerHeight - margin,
    top: rect.top - sideOffset - height >= margin,
    right: rect.right + sideOffset + width <= window.innerWidth - margin,
    left: rect.left - sideOffset - width >= margin
  }
  const opposite = { bottom: "top", top: "bottom", left: "right", right: "left" }
  if (!fits[side] && fits[opposite[side]]) side = opposite[side]

  let top
  let left
  if (side === "bottom" || side === "top") {
    top = side === "bottom" ? rect.bottom + sideOffset : rect.top - sideOffset - height
    const start = rtl ? rect.right - width : rect.left
    const end = rtl ? rect.left : rect.right - width
    left = align === "center" ? rect.left + (rect.width - width) / 2 : align === "end" ? end : start
    left += rtl ? -alignOffset : alignOffset
  } else {
    left = side === "right" ? rect.right + sideOffset : rect.left - sideOffset - width
    top = align === "center" ? rect.top + (rect.height - height) / 2 : align === "end" ? rect.bottom - height : rect.top
    top += alignOffset
  }

  left = Math.max(margin, Math.min(left, window.innerWidth - width - margin))
  top = Math.max(margin, Math.min(top, window.innerHeight - height - margin))
  Object.assign(popup.style, { top: `${top}px`, left: `${left}px` })

  const origins = { bottom: "center top", top: "center bottom", right: "left center", left: "right center" }
  let origin = origins[side]
  if (arrow) {
    const vertical = side === "bottom" || side === "top"
    const size = vertical ? arrow.offsetWidth : arrow.offsetHeight
    const span = vertical ? width : height
    const center = vertical ? rect.left + rect.width / 2 - left : rect.top + rect.height / 2 - top
    const position = Math.max(12, Math.min(center - size / 2, span - size - 12))
    arrow.style.left = vertical ? `${position}px` : ""
    arrow.style.top = vertical ? "" : `${position}px`
    arrow.dataset.side = side
    origin = vertical ? `${center}px ${side === "bottom" ? "top" : "bottom"}` : `${side === "right" ? "left" : "right"} ${center}px`
  } else if (side === "bottom" || side === "top") {
    origin = `${align === "center" ? "center" : (align === "start") !== rtl ? "left" : "right"} ${side === "bottom" ? "top" : "bottom"}`
  }

  popup.style.setProperty("--transform-origin", origin)
  popup.style.transformOrigin = origin
  popup.style.setProperty("--available-height", `${window.innerHeight - margin * 2}px`)
  popup.dataset.side = side
  popup.dataset.logicalSide = logical
  return side
}
