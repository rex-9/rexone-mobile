# 🏛️ RexOne Mobile Architectural Law

> [!IMPORTANT]
>
> ### 📜 Unified Ecosystem Constitution (`LAW.md`)
>
> The single canonical source of truth for all architectural laws across the entire **RexOne Ecosystem** (`rex-9`) is maintained centrally in **RexOne Core**:
>
> 🔗 **Master Constitution**:
> [https://github.com/rex-9/rexone-core/blob/dev/LAW.md](https://github.com/rex-9/rexone-core/blob/dev/LAW.md)
>
> 📱 **RexOne Mobile Architectural Laws (Direct Anchor)**:
> [https://github.com/rex-9/rexone-core/blob/dev/LAW.md#-part-iii-rexone-mobile-architectural-laws-mobile--flutter](https://github.com/rex-9/rexone-core/blob/dev/LAW.md#-part-iii-rexone-mobile-architectural-laws-mobile--flutter)
>
> 🌐 **Universal Constitutional Principles (Direct Anchor)**:
> [https://github.com/rex-9/rexone-core/blob/dev/LAW.md#-universal-constitutional-principles-ecosystem-wide](https://github.com/rex-9/rexone-core/blob/dev/LAW.md#-universal-constitutional-principles-ecosystem-wide)

> > _"If you don't follow These LAWS, u're gay."_
> >
> > — _Newton'z Law_

---

## ⚡ RexOne Mobile Quick Reference (Client-Specific Highlights)

For the full binding text and universal ecosystem laws, always refer to the [Unified Master Constitution](https://github.com/rex-9/rexone-core/blob/dev/LAW.md).

| Law & Section                           | Core Architectural Rule                                                                                                                                                         | Key Mechanism                                                              |
| :-------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------- |
| **M1. Design System & Layout Doctrine** | Zero ad-hoc widgets or arbitrary dimensions outside `lib/design/`. NEVER use hardcoded `SizedBox(width: 20)` or `EdgeInsets.all(16)`.                                           | `lib/design/` (`Design.space.*`, `Design.radius.*`, `Design.typography.*`) |
| **M2. Theme-Aware Styling**             | ZERO hardcoded hex colors (`Color(0xFF...)`). Always access colors and styles through context extensions.                                                                       | `context.colors.primary`, `context.colors.surface`, `context.typography.*` |
| **M3. Architecture & GetX Foundation**  | Strict adherence to GetX ecosystem. Forbidden external packages: `provider`, `bloc`, `riverpod`, `shared_preferences`, `hive`, `go_router`.                                     | GetX State, Dependency Injection, Routes, `GetStorage`, `GetConnect`       |
| **M4. 4-Tier MVCS Separation**          | Models $\rightarrow$ Views (`GetView<TController>`) $\rightarrow$ Controllers (`GetxController`) $\rightarrow$ Services (`GetxService`) $\rightarrow$ Transport (`ApiService`). | Clean layering; zero API calls in views; zero UI dialogs in services       |
| **M5. Storage Keys Parity**             | Local storage keys must match `rexone-web` `StorageKeys` exactly (`'token'`, `'user'`, `'locale'`, `'theme'`).                                                                  | `lib/constants/storage_keys.dart` (`StorageKeys.*`)                        |
| **M6. Mandatory Confirmation Dialog**   | ALL destructive, irreversible actions gated behind `AppDialog.confirm`. Active views use `discard`; hard deletion `destroy` strictly in Recycle Bin.                            | `AppDialog.confirm` (`lib/design/components/app_dialog.dart`)              |
| **M7. ActionCable Resilience**          | Real-time WebSocket subscriptions handle app lifecycle (background/foreground), network drops, and auto-reconnect with backoff.                                                 | ActionCable channel client, offline banners                                |
| **M8. Testing & Static Analysis**       | 100% passing tests across unit, widget, and integration suites. Zero analyzer errors or warnings.                                                                               | `flutter analyze`, `flutter test`, `integration_test/`                     |
| **M9. Module Boundaries**               | Feature domains live in `lib/modules/<feature>/` (`data/`, `controllers/`, `services/`, `pages/`, `widgets/`). Shared code in `lib/design/`, `lib/services/`.                   | Clean encapsulation, modular bindings                                      |
| **M10. Local Timezone Presentation**    | Backend operates in UTC. Mobile client formats incoming UTC timestamps into the device's local timezone for presentation.                                                       | Localized date formatting, zero UTC shifting on backend                    |

---

## 🌐 Universal Constitutional Highlights (Ecosystem-Wide)

| Universal Law                       | Ecosystem Architectural Principle                                                                                                                       | Client Implementation                                                             |
| :---------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ | :-------------------------------------------------------------------------------- |
| **U2. Zero Loose Literals**         | Centralized constants/enums for all keys, statuses, providers, and action names. Zero magic strings.                                                     | `StorageKeys.*`, centralized route and action constants                           |
| **U5. Lifecycle Hierarchy**         | Universal `discard` (soft delete) & `undiscard` (restore). Permanent `destroy` strictly confined to Recycle Bin.                                        | Soft-delete actions in active views, permanent purge strictly in Recycle Bin       |
| **U6. Confirmation Dialogs**        | ALL destructive, irreversible actions gated behind explicit confirmation dialogs.                                                                       | `AppDialog.confirm` component; raw unconfirmed executions strictly forbidden      |
| **U9. Parameter Integrity**         | Strict, deterministic parameters. Zero fallback chains (`params[:a] || params[:b]`).                                                                    | Strongly typed request payloads matching backend strong parameters                |
| **U14. Zero Loose Code**            | Strict parameter contracts. Zero alias shims or fallback kwargs (`name: nil, user_name: nil`). Pass cohesive entities directly. Zero dead code.         | Strongly typed GetX models, zero loose dynamic params, clean signatures          |
| **U15. Human-Readable Code**        | Plain English naming, compact straightforward variables, zero alien/cryptic syntax. Easy to read and review.                                             | Self-documenting code, natural English identifiers, clean idiomatic control flow  |
