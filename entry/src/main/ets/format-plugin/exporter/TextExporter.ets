import { Exporter, ExportResult, ExportSource } from '../types/FormatPluginTypes';

export class TextExporter implements Exporter {
  readonly format: string = 'text';

  canHandle(format: string): boolean {
    return format === this.format;
  }

  export(source: ExportSource): ExportResult {
    const plain = source.markdown
      .replace(/```[\s\S]*?```/g, (block: string) => block.replace(/```/g, '').trim())
      .replace(/^#{1,6}\s+/gm, '')
      .replace(/^[-*]\s+\[[ xX]\]\s+/gm, '')
      .replace(/^[-*]\s+/gm, '')
      .replace(/^\d+\.\s+/gm, '')
      .replace(/^>\s+/gm, '')
      .replace(/`([^`]+)`/g, '$1')
      .replace(/\*\*([^*]+)\*\*/g, '$1')
      .replace(/\*([^*]+)\*/g, '$1')
      .replace(/~~([^~]+)~~/g, '$1')
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '$1 ($2)')
      .replace(/\n{3,}/g, '\n\n')
      .trim();

    return {
      fileName: `${this.safeBase(source.title)}.txt`,
      mimeType: 'text/plain',
      textContent: plain.length > 0 ? `${plain}\n` : '',
      warnings: []
    };
  }

  private safeBase(title: string): string {
    const normalized = title.replace(/\.[^.]+$/, '').replace(/[\\/:*?"<>|]/g, '_').trim();
    return normalized.length > 0 ? normalized : 'draft';
  }
}
