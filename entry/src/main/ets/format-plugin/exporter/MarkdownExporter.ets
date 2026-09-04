import { Exporter, ExportResult, ExportSource } from '../types/FormatPluginTypes';

export class MarkdownExporter implements Exporter {
  readonly format: string = 'markdown';

  canHandle(format: string): boolean {
    return format === this.format;
  }

  export(source: ExportSource): ExportResult {
    return {
      fileName: `${this.safeBase(source.title)}.md`,
      mimeType: 'text/markdown',
      textContent: source.markdown.trimEnd() + '\n',
      warnings: []
    };
  }

  private safeBase(title: string): string {
    const normalized = title.replace(/\.[^.]+$/, '').replace(/[\\/:*?"<>|]/g, '_').trim();
    return normalized.length > 0 ? normalized : 'draft';
  }
}
