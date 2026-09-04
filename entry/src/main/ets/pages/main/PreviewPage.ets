import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import router from '@ohos.router';
import { PreviewArea } from '../../components/base/PreviewComponents';
import { LIGHT_THEME } from '../../common/constants/CommonConstants';
import { ExportFormat, ExportStatus, ExportTask } from '../../models/ExportTaskModel';
import { ExportService } from '../../services/ExportService';
import { FileService } from '../../services/FileService';

const DOMAIN = 0x0001;
const TAG = 'PreviewPage';

@Entry
@Component
struct PreviewPage {
  @State title: string = 'Preview';
  @State content: string = '';
  @State exportTasks: ExportTask[] = [];
  @State exportTaskPreview: ExportTask[] = [];
  @State resultText: string = 'Export Markdown or Text, then share the file.';

  async aboutToAppear() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await FileService.getInstance().init(context);
      this.reload();
    } catch (_error) {
      hilog.error(DOMAIN, TAG, 'preview init failed');
    }
  }

  private reload(): void {
    const currentDoc = FileService.getInstance().getCurrentDocument();
    if (!currentDoc) {
      return;
    }
    this.title = currentDoc.name;
    this.content = currentDoc.content;
    this.exportTasks = ExportService.getInstance().getTasksForCurrentDocument();
    this.exportTaskPreview = this.exportTasks.slice(0, 3);
  }

  private async exportDocument(format: ExportFormat): Promise<void> {
    const task = await ExportService.getInstance().exportCurrentDocument(format);
    if (!task) {
      this.resultText = 'Export canceled';
      return;
    }
    this.resultText = task.status === ExportStatus.SUCCEEDED
      ? `Exported ${task.outputName}`
      : 'Export failed';
    this.reload();
  }

  private async shareDocument(): Promise<void> {
    const shared = await ExportService.getInstance().shareCurrentDocument();
    this.resultText = shared ? 'System share opened' : 'Share failed';
  }

  private backToWorkspace(): void {
    router.replaceUrl({
      url: 'pages/main/WorkspacePage'
    }).catch(() => {
      hilog.error(DOMAIN, TAG, 'workspace route failed');
    });
  }

  build() {
    Column({ space: 12 }) {
      this.buildHeader();

      Column({ space: 12 }) {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(LIGHT_THEME.text);

        PreviewArea({
          md: this.content,
          bg: LIGHT_THEME.surface,
          txt: LIGHT_THEME.text
        }).height('56%');

        this.buildActionPanel();
        this.buildExportHistory();
      }
        .layoutWeight(1)
        .padding(16);
    }
      .width('100%')
      .height('100%')
      .backgroundColor(LIGHT_THEME.background);
  }

  @Builder
  private buildHeader() {
    Row() {
      Button('Back')
        .fontSize(12)
        .backgroundColor(LIGHT_THEME.surface)
        .fontColor(LIGHT_THEME.text)
        .onClick((): void => {
          router.back();
        });

      Blank();

      Text('Preview & Export')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);

      Blank();

      Button('Workspace')
        .fontSize(12)
        .backgroundColor(LIGHT_THEME.surface)
        .fontColor(LIGHT_THEME.text)
        .onClick((): void => {
          this.backToWorkspace();
        });
    }
      .padding({ left: 16, right: 16, top: 14, bottom: 10 });
  }

  @Builder
  private buildActionPanel() {
    Column({ space: 10 }) {
      Text('Export')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);
      Row({ space: 8 }) {
        this.buildActionButton('Markdown', (): void => {
          void this.exportDocument(ExportFormat.MARKDOWN);
        });
        this.buildActionButton('Text', (): void => {
          void this.exportDocument(ExportFormat.TEXT);
        });
      }
      Row({ space: 8 }) {
        this.buildActionButton('Share', (): void => {
          void this.shareDocument();
        });
      }
      Text(this.resultText)
        .fontSize(10)
        .fontColor(LIGHT_THEME.textSecondary);
    }
      .padding(14)
      .backgroundColor(LIGHT_THEME.backgroundSecondary)
      .borderRadius(22);
  }

  @Builder
  private buildExportHistory() {
    Column({ space: 8 }) {
      Text('Recent Exports')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);
      if (this.exportTasks.length === 0) {
        Text('No export records for the current document')
          .fontSize(10)
          .fontColor(LIGHT_THEME.textSecondary);
      } else {
        ForEach(this.exportTaskPreview, (task: ExportTask) => {
          Column({ space: 4 }) {
            Text(task.outputName)
              .fontSize(11)
              .fontColor(LIGHT_THEME.text)
              .maxLines(1);
            Text(task.outputPath ?? 'Path not recorded')
              .fontSize(9)
              .fontColor(LIGHT_THEME.textSecondary)
              .maxLines(2);
          }
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor(LIGHT_THEME.surface)
            .borderRadius(16);
        }, (task: ExportTask) => task.id);
      }
    }
      .padding(14)
      .backgroundColor(LIGHT_THEME.backgroundSecondary)
      .borderRadius(22);
  }

  @Builder
  private buildActionButton(label: string, action: () => void) {
    Button(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(11)
      .backgroundColor(LIGHT_THEME.surface)
      .fontColor(LIGHT_THEME.text)
      .onClick((): void => {
        action();
      });
  }
}
