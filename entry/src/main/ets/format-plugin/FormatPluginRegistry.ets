import { FormatDetector } from './detector/FormatDetector';
import { MarkdownExporter } from './exporter/MarkdownExporter';
import { TextExporter } from './exporter/TextExporter';
import { MarkdownImporter } from './importer/MarkdownImporter';
import { TextImporter } from './importer/TextImporter';
import { Exporter, Importer } from './types/FormatPluginTypes';

export class FormatPluginRegistry {
  private static readonly IMPORTERS: Importer[] = [
    new MarkdownImporter(),
    new TextImporter()
  ];

  private static readonly EXPORTERS: Exporter[] = [
    new MarkdownExporter(),
    new TextExporter()
  ];

  static importerFor(fileName: string, mimeType?: string): Importer | null {
    const extension = FormatDetector.extensionOf(fileName);
    for (let i = 0; i < FormatPluginRegistry.IMPORTERS.length; i++) {
      if (FormatPluginRegistry.IMPORTERS[i].canHandle(extension, mimeType)) {
        return FormatPluginRegistry.IMPORTERS[i];
      }
    }
    return null;
  }

  static exporterFor(format: string): Exporter | null {
    for (let i = 0; i < FormatPluginRegistry.EXPORTERS.length; i++) {
      if (FormatPluginRegistry.EXPORTERS[i].canHandle(format)) {
        return FormatPluginRegistry.EXPORTERS[i];
      }
    }
    return null;
  }

  static detect(fileName: string, mimeType?: string): string | null {
    return FormatDetector.detect(fileName, mimeType);
  }
}
