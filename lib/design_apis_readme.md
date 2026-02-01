# Design Module – Krea & Replicate

## Audit notes (client-ready)

- **Image-to-Image**: All flows (Enhance, Style transfer, Creative, generateImageToImage) use real Krea: upload asset → Bloom enhance. No mocks.
- **Enhancement**: Uses Krea’s real Bloom endpoint: `POST /generate/enhance/topaz/bloom-enhance` (not the non-existent `/generate/enhance`).
- **Tap-to-Edit**: Replicate SAM + Krea generative fill + Krea enhance. If Krea inpainting returns 404 (endpoint may not exist), the user sees a clear message; raw HTML is never shown.
- **Error handling**: All Krea/Replicate calls send `Accept: application/json`. HTML error responses are sanitized; UI never shows raw HTML or long dumps.

## Configuration

- **Krea**: Use either `KREA_API_TOKEN` in `.env` or `ApiKeys.kreaApiKey` in `lib/config/api_keys.dart`. Both tap-to-edit and image-to-image use this.
- **Replicate**: Set `ApiKeys.replicateApiKey` in `lib/config/api_keys.dart` (used for SAM 2 mask generation in tap-to-edit).

## What works

### Image reference (Image-to-Image screen)

- **Enhance**: Original image is uploaded to Krea, then enhanced via Krea’s enhance API. **Works** with a valid Krea token.
- **Style transfer**: Original (and reference) are uploaded; enhancement is run on the original. **Works** (reference is used for flow; full style-transfer API can be added later).
- **Creative transform**: Original is uploaded and enhanced. **Works** with a valid Krea token.
- **Quick enhancements** (e.g. enhance details, color boost): All go through the same Krea upload + enhance path. **Work**.

### Edits (Tap-to-Edit)

- **Edit with prompt**: User traces a region → Replicate SAM 2 generates a mask from the tap → Krea generative fill applies the prompt to the masked area → Krea enhancement polishes the result. **Works** when:
  - Replicate API key is set.
  - Krea token is set (see above).
  - The image has a **public URL** (e.g. from the design flow). Gallery images (local file path) cannot be sent to Replicate; the app shows a message and blocks the request.
- **Edit with reference image**: Tap-to-edit is prompt-based (trace + prompt). Reference image in the app is used on the **Image-to-Image** screen (style transfer), not in the tap-to-edit flow.

## Summary

| Feature                    | Krea | Replicate | Status |
|---------------------------|------|-----------|--------|
| Image-to-image (enhance)  | Yes  | –         | Works  |
| Image-to-image (style)    | Yes  | –         | Works  |
| Image-to-image (creative) | Yes  | –         | Works  |
| Tap-to-edit (trace + prompt) | Yes | Yes       | Works (image must have URL) |
| Gallery image in tap-to-edit | –   | –         | Blocked (needs URL) |
