import { Importer, ImportResult, ImportSource } from '../types/FormatPluginTypes';

export class MarkdownImporter implements Importer {
  readonly format: string = 'markdown';

  canHandle(extension: string, mimeType?: string): boolean {
    return extension === 'md' || extension === 'markdown' || mimeType === 'text/markdown';
  }

  import(source: ImportSource): ImportResult {
    const cleanText = (source.textContent ?? '').replace(/\r\n/g, '\n').trimEnd();
    return {
      title: this.normalizeTitle(source.fileName),
      markdown: cleanText.length > 0 ? `${cleanText}\n` : '',
      sourceType: this.format,
      warnings: []
    };
  }

  private normalizeTitle(fileName: string): string {
    return fileName.replace(/\.(md|markdown)$/i, '');
  }
}
