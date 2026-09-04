export class FormatDetector {
  static detect(fileName: string, mimeType?: string): string | null {
    const normalized = fileName.trim().toLowerCase();
    if (normalized.endsWith('.md') || normalized.endsWith('.markdown')) {
      return 'markdown';
    }
    if (normalized.endsWith('.txt')) {
      return 'text';
    }
    if (mimeType === 'text/markdown') {
      return 'markdown';
    }
    if (mimeType === 'text/plain') {
      return 'text';
    }
    return null;
  }

  static extensionOf(fileName: string): string {
    const normalized = fileName.trim().toLowerCase();
    if (normalized.endsWith('.markdown')) {
      return 'markdown';
    }
    const dotIndex = normalized.lastIndexOf('.');
    return dotIndex >= 0 ? normalized.slice(dotIndex + 1) : '';
  }
}
