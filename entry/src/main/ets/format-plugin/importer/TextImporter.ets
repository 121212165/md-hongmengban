import { Importer, ImportResult, ImportSource } from '../types/FormatPluginTypes';

export class TextImporter implements Importer {
  readonly format: string = 'text';

  canHandle(extension: string, mimeType?: string): boolean {
    return extension === 'txt' || mimeType === 'text/plain';
  }

  import(source: ImportSource): ImportResult {
    const raw = (source.textContent ?? '').replace(/\r\n/g, '\n');
    const normalized = raw
      .split('\n')
      .map((line: string) => line.trimEnd())
      .join('\n')
      .replace(/\n{3,}/g, '\n\n')
      .trim();
    const title = this.normalizeTitle(source.fileName);
    const markdown = normalized.length > 0 ? normalized : `# ${title}\n\n`;
    return {
      title: title,
      markdown: markdown,
      sourceType: this.format,
      warnings: []
    };
  }

  private normalizeTitle(fileName: string): string {
    return fileName.replace(/\.txt$/i, '');
  }
}
