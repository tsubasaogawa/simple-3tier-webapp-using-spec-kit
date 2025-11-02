# Application Layer (src/app)

This directory contains the application (service) layer for the simple 3‑tier web app.

## Purpose
- Encapsulates business logic independent from transport (HTTP, CLI) and persistence.
- Coordinates data flow between controllers (interface layer) and repositories (data layer).
- Provides reusable services and domain models.

## Typical Contents
- controllers/ (request orchestration; minimal logic)
- services/ (business rules, workflows)
- models/ (domain/data transfer objects)
- repositories/ or gateways/ (abstract access to DB or external APIs)
- config/ (application-specific configuration)
- utils/ (pure helper functions)

## Conventions
- Keep controllers thin; place logic in services.
- Avoid direct DB calls outside repositories/gateways.
- Prefer dependency injection (pass collaborators explicitly).
- Write unit tests per service; integration tests per controller.

## Running (example)
```bash
# Install dependencies
npm install

# Run application
npm start

# Run tests
npm test
```

(Adjust commands above if using a different runtime.)

## Error Handling
- Throw typed errors in services.
- Map errors to HTTP responses (or other interface concerns) outside this layer.

## Logging
- Log only contextual info (no secrets).
- Use a shared logger instance (e.g., injected).

## Extending
1. Add a service in services/.
2. Define/extend models if needed.
3. Expose via a controller method.
4. Add tests before integrating.

## Testing
- Unit: isolate services with mocked repositories.
- Integration: exercise controller + service + repository against test DB.
- Keep fast tests in CI.

## Security
- Validate and sanitize inputs at the boundary (controller level).
- Enforce authorization checks inside services where business rules apply.

## Notes
Adjust structure if the technology stack differs; this README describes intended layering, not strict implementation.