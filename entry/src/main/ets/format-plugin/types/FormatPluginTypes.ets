export interface ImportSource {
  fileName: string;
  extension: string;
  mimeType?: string;
  textContent?: string;
}

export interface ImportResult {
  title: string;
  markdown: string;
  sourceType: string;
  warnings: string[];
}

export interface ExportSource {
  title: string;
  markdown: string;
}

export interface ExportResult {
  fileName: string;
  mimeType: string;
  textContent: string;
  warnings: string[];
}

export interface Importer {
  readonly format: string;
  canHandle(extension: string, mimeType?: string): boolean;
  import(source: ImportSource): ImportResult;
}

export interface Exporter {
  readonly format: string;
  canHandle(format: string): boolean;
  export(source: ExportSource): ExportResult;
}
