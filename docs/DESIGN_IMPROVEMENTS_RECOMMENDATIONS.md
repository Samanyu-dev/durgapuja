# Durga Idol Maker – Design Module: Further Additions & Recommendations

This document lists **additions and changes** that would improve the Design Module and the app overall. Items already implemented in this session are marked **Done**.

---

## Done in this session

- **Save to My Concepts** – From Enhanced Image Editor, users can save the current design to My Concepts (persisted via SharedPreferences). My Concepts loads saved concepts first, then demo concepts; remove works for saved items.
- **Back navigation from Enhanced Editor** – App bar has a back button that goes to Design Welcome.
- **Sanitized error messages** – Create Design shows user-friendly messages for API key / server errors; Image-to-Image already had sanitization.
- **My Concepts thumbnails** – Concept cards show actual images (network or asset) when available.

---

## High impact (recommended next)

### 1. **Real “Save to gallery” (device photos)**

- **Current:** `ImageSaveService.saveToGallery()` only logs; no file is written to the device gallery.
- **Change:** Use `image_gallery_saver` (or platform channels) to write the downloaded image to the device photo library and show “Saved to gallery”.
- **Where:** `ImageSaveService`, and any screen that calls it (e.g. Enhanced Editor download could optionally “Save to gallery” as well).

### 2. **Share design**

- **Current:** `ImageSaveService.shareImage()` only logs.
- **Change:** Use `share_plus` to share the image (file or URL) with other apps.
- **Where:** Image Viewer and Enhanced Editor “Share” actions.

### 3. **Concepts in Firestore (optional sync)**

- **Current:** Concepts are stored only in SharedPreferences (local).
- **Change:** Add a Firestore `concepts` (or `designs`) collection and, when the user is signed in, save/load concepts there so they sync across devices and survive reinstall.
- **Where:** New or extended service (e.g. `ConceptsStoreService` + Firestore), My Concepts screen, Save to My Concepts flow.

### 4. **“Save to My Concepts” from Create Design / Image-to-Image**

- **Current:** After generation, the app pushes to Enhanced Editor; saving to My Concepts is only from there.
- **Change:** Optional “Save to My Concepts” (or “Save & continue”) in the result screen or right after generation, so users can save without opening the full editor if they want.

---

## Medium impact (UX and robustness)

### 5. **Loading and disabled state consistency**

- Disable “Generate” / “Transform” / “Apply Edit” while requests are in progress across Create Design, Image-to-Image, Tap-to-Edit, and Enhanced Editor.
- Use a single pattern for loading (e.g. overlay + “Processing…” or button `isLoading`) so behaviour is consistent.

### 6. **API key and network errors**

- On KREA/Replicate “token not found” or “network error”, show a short, actionable message (e.g. “Check API key in .env” or “No internet. Try again.”) and optionally a “Retry” or “Settings” action.
- Avoid showing raw exception text or HTML in SnackBars.

### 7. **Image Viewer → Edit flow**

- From Image Viewer (e.g. after Create Design / Image-to-Image), add actions like “Edit in Enhanced Editor” or “Tap-to-Edit” so the user can go straight into editing the current image.
- Ensures “View generated image → Edit → Save to My Concepts” is a clear path.

### 8. **Tap-to-Edit with image from Create / Image-to-Image**

- Ensure when navigating from Create Design or Image-to-Image to Tap-to-Edit, the generated image is passed (e.g. via route `extra` or state) so Tap-to-Edit opens with that image pre-loaded.
- Router already has `/design/tap-to-edit/image/:id` with `extra: GeneratedImage`; verify all entry points pass the image.

### 9. **My Concepts search and filters**

- **Current:** Search and theme/date filters are UI-only; they don’t filter the list.
- **Change:** Filter `_concepts` by search text and selected theme/date so the grid shows only matching concepts.

### 10. **Delete confirmation**

- Before removing a concept in My Concepts, show a dialog: “Remove this concept?” with Cancel / Remove to avoid accidental deletion.

---

## Lower priority / polish

### 11. **Accessibility**

- Add `Semantics` labels for main actions (Generate, Save to My Concepts, Download, Back).
- Ensure contrast and touch targets meet accessibility guidelines for key buttons.

### 12. **Haptic feedback**

- Trigger light haptic on primary actions (Generate, Apply Edit, Save to My Concepts) where it’s not already used.

### 13. **Offline / cached thumbnails**

- Cache concept thumbnails (e.g. with `cached_network_image`) so My Concepts and grids load faster and work better with slow or intermittent network.

### 14. **Quality / steps in Create Design**

- Expose “Quality” or “Steps” (e.g. 85% vs 100%, or step count) in Create Design so advanced users can trade off speed vs quality, if the Krea API supports it.

### 15. **Voice search in My Concepts**

- Implement real voice search: use Speech-to-Text (or existing `SpeechService`) to fill the search field and then apply the same filter logic as text search.

---

## Technical / maintenance

### 16. **Concept model and store**

- **Current:** My Concepts uses `Map<String, String>`; `Concept` model exists but isn’t used in the main flow.
- **Change:** Use `Concept` (or a DTO) end-to-end: ConceptsStoreService saves/loads `Concept` (or equivalent), and the UI maps from that. Eases future Firestore/sync and validation.

### 17. **Centralized error sanitization**

- **Current:** Create Design, Image-to-Image, and Enhanced Editor each have their own `_sanitizeError`-style logic.
- **Change:** Move to a small `ErrorSanitizer` or `UserFacingError` helper used by all design screens so messages and behaviour are consistent.

### 18. **Environment and API keys**

- Document in README or `docs/` which keys are required (e.g. KREA_API_TOKEN, Replicate) and where to set them (.env vs `api_keys.dart`).
- Optionally add a simple “API status” or “Check keys” in Settings that validates keys without calling full generation.

---

## Summary

- **Already done:** Save to My Concepts with local persistence, back from Enhanced Editor, sanitized errors in Create Design, My Concepts thumbnails.
- **Next steps to prioritise:** Real save to gallery, share via `share_plus`, optional Firestore sync for concepts, and consistent loading/error handling. Then UX improvements: filters/search, confirm delete, and clear paths from viewer to edit and Tap-to-Edit.

If you tell me which area you want to tackle first (e.g. “save to gallery” or “Firestore concepts”), I can outline concrete code changes and file-level steps.
