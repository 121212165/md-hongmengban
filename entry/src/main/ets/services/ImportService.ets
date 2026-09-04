import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import { Document } from '../models/DocumentModel';
import { FormatDetector } from '../format-plugin/detector/FormatDetector';
import { FormatPluginRegistry } from '../format-plugin/FormatPluginRegistry';
import { FileService } from './FileService';

const DOMAIN = 0x0001;
const TAG = 'ImportService';

export class ImportService {
  private static instance: ImportService;

  private constructor() {
  }

  static getInstance(): ImportService {
    if (!ImportService.instance) {
      ImportService.instance = new ImportService();
    }
    return ImportService.instance;
  }

  async importIntoCurrentProject(): Promise<Document | null> {
    const context = FileService.getInstance().getContext();
    if (!context) {
      return null;
    }

    try {
      const documentPicker = new picker.DocumentViewPicker(context as common.UIAbilityContext);
      const uris = await documentPicker.select({
        maxSelectNumber: 1
      });
      if (!uris || uris.length === 0) {
        return null;
      }

      const importedUri = uris[0];
      const sourceFile = new fileUri.FileUri(importedUri);
      const importer = FormatPluginRegistry.importerFor(sourceFile.name);
      if (!importer) {
        return null;
      }

      const textContent = fs.readTextSync(importedUri);
      const result = importer.import({
        fileName: sourceFile.name,
        extension: FormatDetector.extensionOf(sourceFile.name),
        textContent: textContent
      });

      return FileService.getInstance().createDocument(result.title, result.markdown);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Import failed: %{public}s', JSON.stringify(error));
      return null;
    }
  }
}
