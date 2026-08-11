/**
 * Contract every platform adapter (macos, windows, ...) must implement.
 * The bridge core talks ONLY to this interface — it never contains
 * OS-specific logic itself. See /click-tools/bridge/src/platform/<os>/.
 */
export interface CapCutController {
  /** True if a CapCut Desktop process is currently running. */
  isCapCutRunning(): Promise<boolean>;

  /** Brings CapCut to the foreground. Returns true if it ended up frontmost. */
  focusCapCut(): Promise<boolean>;

  /**
   * Imports a local image file into whatever CapCut project is currently open.
   * Must internally try strategies in order of stability and report which
   * one succeeded (or that all failed) via the returned result.
   */
  importImage(filePath: string): Promise<ImportResult>;
}

export type ImportStrategy = "clipboard" | "os-automation" | "accessibility-ui" | "manual-fallback";

export type OperationStage =
  | "DOWNLOADED"
  | "CAPCUT_DETECTED"
  | "IMPORT_ATTEMPTED"
  | "IMPORTED"
  | "FAILED";

export interface ImportResult {
  stage: OperationStage;
  strategyUsed: ImportStrategy | null;
  message: string;
}
