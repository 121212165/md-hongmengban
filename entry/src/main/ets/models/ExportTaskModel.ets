export enum ExportFormat {
  MARKDOWN = 'markdown',
  TEXT = 'text',
  SHARE_CARD = 'share_card',
  PDF = 'pdf',
  LONG_IMAGE = 'long_image'
}

export enum ExportStatus {
  IDLE = 'idle',
  RUNNING = 'running',
  SUCCEEDED = 'succeeded',
  FAILED = 'failed'
}

export interface ExportTask {
  id: string;
  documentId: string;
  format: ExportFormat;
  targetLabel: string;
  outputName: string;
  status: ExportStatus;
  createdAt: number;
  updatedAt: number;
  outputPath?: string;
  errorMessage?: string;
}

function defaultExtension(format: ExportFormat): string {
  if (format === ExportFormat.TEXT) {
    return 'txt';
  }
  if (format === ExportFormat.PDF) {
    return 'pdf';
  }
  if (format === ExportFormat.LONG_IMAGE || format === ExportFormat.SHARE_CARD) {
    return 'txt';
  }
  return 'md';
}

export function createExportTask(documentId: string, format: ExportFormat, outputName?: string): ExportTask {
  const now = Date.now();
  return {
    id: `export_${now}`,
    documentId: documentId,
    format: format,
    targetLabel: format === ExportFormat.SHARE_CARD ? 'Harmony share' : 'Local export',
    outputName: outputName ?? `draft_${now}.${defaultExtension(format)}`,
    status: ExportStatus.RUNNING,
    createdAt: now,
    updatedAt: now
  };
}

export const EXPORT_TASKS_KEY = 'hongmengmd_export_tasks';
