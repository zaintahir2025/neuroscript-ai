# ASP.NET Core Proxy Gateway API Specification

This document specifies the REST API endpoints exposed by the NeuroScript AI backend proxy gateway (`server/NeuroScriptProxy/`), built with ASP.NET Core (.NET 10 LTS).

---

## 1. Overview & Authentication

The proxy gateway serves as a rate-limiting, stateless security boundary between the offline-first Flutter mobile client and upstream foundational LLMs (Google Gemini API).

* **Base URL:** `http://localhost:5000` (development) or `https://neuroscript.uet.edu.pk` (production).
* **OpenAPI Specification:** Frozen contract located at [`docs/contracts/proxy-api.openapi.yaml`](contracts/proxy-api.openapi.yaml).
* **Authentication Header:** All protected endpoints require an `X-Api-Key` HTTP header.
  * The server performs a constant-time cryptographic equality check (`CryptographicOperations.FixedTimeEquals`) against the configured server secret (`NEUROSCRIPT_PROXY_API_KEY`).
  * Empty or missing keys return `HTTP 401 Unauthorized`.
* **Client Identification Header:** The mobile client supplies `X-Install-Id` containing the device installation UUID stored in `FlutterSecureStorage`. This ID is hashed and used for token-bucket rate limiting.

---

## 2. Rate Limiting & Quotas

The proxy enforces a per-device sliding-window token bucket rate limiter:

* **Default Limit:** 20 requests per minute per `X-Install-Id`.
* **Standard Response Headers:**
  * `X-RateLimit-Limit`: Maximum requests permitted within the 1-minute window (e.g., `20`).
  * `X-RateLimit-Remaining`: Count of requests remaining in the current window.
  * `Retry-After`: Returned on `HTTP 429 Too Many Requests`, specifying seconds the client must wait before retrying.

---

## 3. Endpoints

### 3.1 Health Check (`GET /health`)

Returns the operational status of the proxy gateway and the active lesson generation provider.

* **Method:** `GET`
* **Path:** `/health`
* **Authentication:** None required (public health probe).

#### Response 200 OK

```json
{
  "status": "Healthy",
  "timestamp": "2026-11-19T09:30:00.000Z",
  "provider": "Gemini-1.5-Flash"
}
```

---

### 3.2 Lesson Generation (`POST /api/v1/lessons/generate`)

Generates a structured, line-grounded study unit (concept map and active-recall flashcards) from confirmed OCR note lines.

* **Method:** `POST`
* **Path:** `/api/v1/lessons/generate`
* **Headers:**
  * `Content-Type: application/json`
  * `X-Api-Key: <client-proxy-key>`
  * `X-Install-Id: <uuid-v4-installation-id>`
* **Payload Constraints:**
  * Maximum request body size: 256 KB (enforced at Kestrel web server level).
  * Maximum lines array count: 200 lines.
  * Maximum total characters: 25,000 characters.

#### Request Example

```json
{
  "noteHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "profile": "Dyslexia",
  "lines": [
    "Photosynthesis occurs in plant chloroplasts.",
    "Light-dependent reactions take place within thylakoids.",
    "The Calvin cycle synthesizes glucose in the stroma."
  ]
}
```

#### Response 200 OK

*Conforms strictly to [`docs/contracts/lesson.schema.json`](contracts/lesson.schema.json)*.

```json
{
  "schemaVersion": 1,
  "title": "Photosynthesis Fundamentals",
  "meta": {
    "profile": "Dyslexia",
    "source": "cloud",
    "promptVersion": "v1"
  },
  "conceptMap": {
    "nodes": [
      { "id": "n1", "label": "Chloroplast", "sourceLines": [1] },
      { "id": "n2", "label": "Thylakoids", "sourceLines": [2] },
      { "id": "n3", "label": "Calvin Cycle", "sourceLines": [3] }
    ],
    "edges": [
      { "from": "n1", "to": "n2", "label": "houses" },
      { "from": "n2", "to": "n3", "label": "drives" }
    ]
  },
  "flashcards": [
    {
      "id": "c1",
      "question": "Where do light-dependent reactions take place?",
      "answer": "Inside the thylakoid membranes of plant chloroplasts.",
      "sourceLines": [1, 2],
      "groundingScore": 0.94,
      "verified": true
    },
    {
      "id": "c2",
      "question": "What is the primary product of the Calvin cycle?",
      "answer": "Glucose synthesized inside the chloroplast stroma.",
      "sourceLines": [3],
      "groundingScore": 0.91,
      "verified": true
    }
  ]
}
```

---

## 4. Error Responses (`application/problem+json`)

All non-200 responses return standard RFC 7807 Problem Details objects:

```json
{
  "type": "https://neuroscript.uet.edu.pk/errors/rate-limited",
  "title": "Rate Limit Exceeded",
  "status": 429,
  "detail": "Rate limit of 20 requests per minute exceeded. Please retry after 45 seconds.",
  "errorCode": "RATE_LIMITED"
}
```

### Error Code Reference Table

| Status Code | Error Code | Root Cause |
| :--- | :--- | :--- |
| **400 Bad Request** | `INVALID_INPUT` | Missing `noteHash` or empty `lines` array. |
| **401 Unauthorized** | `UNAUTHORIZED` | Missing or invalid `X-Api-Key` header. |
| **413 Payload Too Large** | `LINE_LIMIT_EXCEEDED` | Request contains more than 200 lines. |
| **413 Payload Too Large** | `CHAR_LIMIT_EXCEEDED` | Cumulative text exceeds 25,000 characters. |
| **429 Too Many Requests** | `RATE_LIMITED` | Install ID exceeded 20 requests in 60 seconds. |
| **502 Bad Gateway** | `UPSTREAM_ERROR` | Upstream Gemini API unreachable or returned invalid JSON. |
| **503 Service Unavailable** | `PROXY_NOT_CONFIGURED` | Server missing `NEUROSCRIPT_PROXY_API_KEY` configuration. |

---

## 5. Security & Privacy Guarantees

1. **Stateless Server Processing:**
   * The proxy never persists student notes, transcripts, or flashcard contents in any database or file system.
2. **Metadata Audit Logging:**
   * Audit logs record only: timestamp, masked install ID (e.g. `1a2b...9z8y`), line count, total characters, status code, and latency in milliseconds.
3. **Secret Isolation:**
   * `GEMINI_API_KEY` is loaded from server environment variables; it is never transmitted to or embedded inside the mobile application binary.
