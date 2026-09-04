import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import fileUri from '@ohos.file.fileuri';
import wantConstant from '@ohos.ability.wantConstant';
import { FormatPluginRegistry } from '../format-plugin/FormatPluginRegistry';
import { createExportTask, ExportFormat, ExportStatus, ExportTask } from '../models/ExportTaskModel';
import { FileService } from './FileService';

const DOMAIN = 0x0001;
const TAG = 'ExportService';
const SHARE_DIR = 'shared';

export class ExportService {
  private static instance: ExportService;

  private constructor() {
  }

  static getInstance(): ExportService {
    if (!ExportService.instance) {
      ExportService.instance = new ExportService();
    }
    return ExportService.instance;
  }

  async exportCurrentDocument(format: ExportFormat): Promise<ExportTask | null> {
    const context = FileService.getInstance().getContext();
    const currentDoc = FileService.getInstance().getCurrentDocument();
    if (!context || !currentDoc) {
      return null;
    }

    const exporter = this.exporterForFormat(format);
    if (!exporter) {
      return null;
    }

    const result = exporter.export({
      title: currentDoc.name,
      markdown: currentDoc.content
    });
    const task = createExportTask(currentDoc.id, format, result.fileName);

    try {
      const savePicker = new picker.DocumentViewPicker(context as common.UIAbilityContext);
      const uris = await savePicker.save({
        newFileNames: [result.fileName]
      });
      if (!uris || uris.length === 0) {
        return null;
      }

      const targetUri = uris[0];
      this.writeTextFile(targetUri, result.textContent);
      task.outputPath = targetUri;
      task.outputName = new fileUri.FileUri(targetUri).name;
      task.status = ExportStatus.SUCCEEDED;
      task.updatedAt = Date.now();
      FileService.getInstance().saveExportTask(task);
      return task;
    } catch (error) {
      task.status = ExportStatus.FAILED;
      task.errorMessage = JSON.stringify(error);
      task.updatedAt = Date.now();
      FileService.getInstance().saveExportTask(task);
      hilog.error(DOMAIN, TAG, 'Export failed: %{public}s', task.errorMessage ?? 'unknown');
      return task;
    }
  }

  async shareCurrentDocument(): Promise<boolean> {
    const context = FileService.getInstance().getContext();
    const currentDoc = FileService.getInstance().getCurrentDocument();
    if (!context || !currentDoc || !context.filesDir) {
      return false;
    }

    try {
      const exporter = this.exporterForFormat(ExportFormat.MARKDOWN);
      if (!exporter) {
        return false;
      }
      const result = exporter.export({
        title: currentDoc.name,
        markdown: currentDoc.content
      });

      const exportDir = `${context.filesDir}/${SHARE_DIR}`;
      this.ensureDirectory(exportDir);
      const targetPath = `${exportDir}/${result.fileName}`;
      this.writeTextFile(targetPath, result.textContent);
      const targetUri = fileUri.getUriFromPath(targetPath);

      await context.startAbility({
        action: wantConstant.Action.ACTION_SEND_DATA,
        type: result.mimeType,
        parameters: {
          [wantConstant.Action.PARAMS_STREAM]: [targetUri]
        }
      });
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Share failed: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  getLatestTask(documentId?: string): ExportTask | null {
    return FileService.getInstance().getLatestExportTask(documentId);
  }

  getTasksForCurrentDocument(): ExportTask[] {
    return FileService.getInstance().getExportTasksForCurrentDocument();
  }

  private exporterForFormat(format: ExportFormat) {
    if (format === ExportFormat.TEXT) {
      return FormatPluginRegistry.exporterFor('text');
    }
    return FormatPluginRegistry.exporterFor('markdown');
  }

  private writeTextFile(target: string, content: string): void {
    const file = fs.openSync(target, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
    fs.writeSync(file.fd, content);
    fs.closeSync(file);
  }

  private ensureDirectory(path: string): void {
    try {
      fs.statSync(path);
    } catch (_error) {
      fs.mkdirSync(path);
    }
  }
}
