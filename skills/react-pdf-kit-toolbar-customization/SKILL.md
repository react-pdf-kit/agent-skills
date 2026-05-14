---
name: react-pdf-kit-toolbar-customization
description: Add, remove, or replace individual toolbar tools (zoom, print, download, etc.) in @react-pdf-kit/viewer (>=1.0.0 <2.0.0) while preserving the Radix-based accessibility primitives.
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=5.0.0 <6.0.0"
  frameworks: [react, next.js, vite]
  tags: [pdf-viewer, toolbar, customization, accessibility]
---

# react-pdf-kit-toolbar-customization

**Use this skill when**: the developer asks to customize the viewer's
toolbar — adding a custom button, removing a built-in tool, reordering
tools, or wrapping a tool in a custom container — WITHOUT replacing
the entire layout. For full layout replacement use
`react-pdf-kit-custom-layout`.

The toolbar is composed of individual `*Tool` components exported
from `@react-pdf-kit/viewer`. Each is a thin Radix-based wrapper over
a hook. Custom toolbars are built by composing these tools (or
omitting them) in your own toolbar element.

## Gotchas

- **Each built-in tool is independently exportable.** Examples:
  `ZoomInTool`, `ZoomOutTool`, `PrintTool`, `DownloadTool`,
  `RotateClockwiseTool`, `SwitchViewModeTool`, `ToggleSidebarTool`.
  Import only the ones you want; do NOT replicate their behavior by
  hand — you'll lose the accessibility wiring.
- **Preserve Radix primitives.** Built-in tools wrap Radix tooltips
  and buttons. Custom tools should also use Radix or at minimum
  preserve `aria-label`, focusable buttons, and visible focus rings.
- **Keyboard navigation must keep working.** Tools are reachable via
  `Tab` order. Don't insert non-focusable wrappers (`div onClick`)
  where a Radix `Button` belongs.
- **Use the documented hooks** rather than reaching into context
  directly. The viewer exposes `useZoomContext`, `useDocumentContext`,
  `usePaginationContext`, `usePrint`, `useDownload`, etc. for custom
  tools to call.
- **Replacing the toolbar means replacing `RPDefaultLayout`.** There
  is no "toolbar slot" prop on `RPDefaultLayout`; the way to swap
  toolbar contents is to render your own layout (this skill) or use
  `react-pdf-kit-custom-layout` for a fully bespoke layout.

## Procedure

### 1. Identify your audience for the toolbar

- **Small change (one button added/removed)**: replace
  `RPDefaultLayout` with a thin custom layout that re-uses most of
  the default visual structure. Recipe in step 2 below.
- **Large change (entire toolbar redesigned)**: prefer
  `react-pdf-kit-custom-layout` instead — it gives you a clean
  headless surface and avoids re-implementing the default layout's
  containers.

### 2. Compose a custom toolbar from individual tools

```tsx
// src/PdfViewerWithCustomToolbar.tsx
import {
  RPConfig,
  RPProvider,
  RPTheme,
  RPPages,
  ZoomInTool,
  ZoomOutTool,
  PrintTool,
  DownloadTool,
  // ↑ all exported from @react-pdf-kit/viewer/lib/main
} from '@react-pdf-kit/viewer'

function CustomToolbar() {
  return (
    <div
      role="toolbar"
      aria-label="PDF viewer toolbar"
      style={{
        display: 'flex',
        gap: 8,
        padding: '8px 16px',
        borderBottom: '1px solid var(--rp-border, #e5e7eb)',
      }}
    >
      <ZoomOutTool />
      <ZoomInTool />
      <span style={{ flex: 1 }} />  {/* spacer */}
      <PrintTool />
      <DownloadTool />
      {/* Add your own button here, see step 3 */}
    </div>
  )
}

export function PdfViewerWithCustomToolbar({ src }: { src: string }) {
  return (
    <RPConfig>
      <RPProvider src={src}>
        <RPTheme>
          <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
            <CustomToolbar />
            <div style={{ flex: 1, minHeight: 0 }}>
              <RPPages />
            </div>
          </div>
        </RPTheme>
      </RPProvider>
    </RPConfig>
  )
}
```

The wrapper around `RPPages` MUST set `flex: 1; min-height: 0;` so
the virtualizer has a concrete viewport to measure.

### 3. Add a custom tool that uses the documented hooks

```tsx
// src/CopyLinkTool.tsx
import { useDocumentContext } from '@react-pdf-kit/viewer'
import * as Tooltip from '@radix-ui/react-tooltip'

export function CopyLinkTool() {
  const { src } = useDocumentContext()

  return (
    <Tooltip.Provider>
      <Tooltip.Root>
        <Tooltip.Trigger asChild>
          <button
            type="button"
            aria-label="Copy document link"
            onClick={() => navigator.clipboard.writeText(String(src))}
          >
            🔗
          </button>
        </Tooltip.Trigger>
        <Tooltip.Portal>
          <Tooltip.Content sideOffset={6}>Copy link</Tooltip.Content>
        </Tooltip.Portal>
      </Tooltip.Root>
    </Tooltip.Provider>
  )
}
```

Then drop it into the `<CustomToolbar>` next to the built-in tools.
The Radix tooltip preserves the keyboard / screen-reader behavior the
built-in tools have.

### 4. Removing a built-in tool

There is no `omit` prop on the default toolbar — composing your own
toolbar (step 2) and just not importing the tool you want to remove
*is* the omit mechanism. Keep your custom toolbar minimal: only the
tools you want.

## Verify

```bash
pnpm install
pnpm build
pnpm dev
```

Open the page. Tab through the toolbar with the keyboard — every
button should receive focus, show a visible focus ring, and respond
to `Enter`. Use a screen reader (VoiceOver, NVDA) to confirm each
button has an accessible name. Open a PDF, scroll, select text — the
viewer should still virtualize and the text layer should still be
selectable.

## References

- Radix Tooltip: <https://www.radix-ui.com/primitives/docs/components/tooltip>
- Companion skills:
  - `react-pdf-kit-setup` — first-time setup.
  - `react-pdf-kit-custom-layout` — for full headless replacement of
    the default layout (preferred for substantial UI redesigns).
