import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import router from '@ohos.router';
import { EditorArea, ToolbarPanel } from '../../components/base/EditorComponents';
import { ToolbarButton, LIGHT_THEME } from '../../common/constants/CommonConstants';
import { getWordCount } from '../../common/utils/MarkdownParser';
import { Document } from '../../models/DocumentModel';
import { FileService } from '../../services/FileService';

const DOMAIN = 0x0001;
const TAG = 'EditorPage';
const EMPTY_NAME = 'Untitled';
const EDITOR_BUTTONS: ToolbarButton[] = [
  new ToolbarButton('H1', 'Heading', '# '),
  new ToolbarButton('- -', 'List', '- '),
  new ToolbarButton('[ ]', 'Task', '- [ ] '),
  new ToolbarButton('> ', 'Quote', '> '),
  new ToolbarButton('B', 'Bold', '**'),
  new ToolbarButton('`', 'Code', '`')
];

@Entry
@Component
struct EditorPage {
  @State title: string = EMPTY_NAME;
  @State content: string = '';
  @State currentDocId: string = '';
  @State saveLabel: string = 'Local autosave is ready';
  @State wordCount: number = 0;

  async aboutToAppear() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await FileService.getInstance().init(context);
      this.loadCurrentDocument();
    } catch (_error) {
      hilog.error(DOMAIN, TAG, 'editor init failed');
    }
  }

  private loadCurrentDocument(): void {
    const currentDoc = FileService.getInstance().getCurrentDocument();
    if (!currentDoc) {
      return;
    }
    this.applyDocument(currentDoc);
  }

  private applyDocument(document: Document): void {
    this.currentDocId = document.id;
    this.title = document.name.replace(/\.md$/i, '');
    this.content = document.content;
    this.wordCount = document.stats.wordCount;
    this.saveLabel = `Updated ${this.timeStr(document.updatedAt)}`;
  }

  private saveCurrentDocument(): void {
    if (!this.currentDocId) {
      return;
    }
    const nextName = this.title.trim().length > 0 ? this.title.trim() : EMPTY_NAME;
    FileService.getInstance().saveDocumentName(this.currentDocId, nextName);
    FileService.getInstance().saveDocumentContent(this.currentDocId, this.content);
    this.saveLabel = 'Saved locally';
  }

  private backToWorkspace(): void {
    router.replaceUrl({
      url: 'pages/main/WorkspacePage'
    }).catch(() => {
      hilog.error(DOMAIN, TAG, 'workspace route failed');
    });
  }

  private openPreview(): void {
    router.pushUrl({
      url: 'pages/main/PreviewPage'
    }).catch(() => {
      hilog.error(DOMAIN, TAG, 'preview route failed');
    });
  }

  build() {
    Column() {
      this.buildHeader();

      Column({ space: 12 }) {
        TextInput({ text: this.title, placeholder: 'Document title' })
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(LIGHT_THEME.surface)
          .fontColor(LIGHT_THEME.text)
          .borderRadius(18)
          .padding({ left: 14, right: 14 })
          .height(50)
          .onChange((value: string): void => {
            this.title = value;
            this.saveCurrentDocument();
          });

        ToolbarPanel({
          buttons: EDITOR_BUTTONS,
          onInsert: (text: string): void => {
            this.content += text;
            this.wordCount = getWordCount(this.content);
            this.saveCurrentDocument();
          }
        });

        EditorArea({
          content: $content,
          placeholder: 'Start writing...',
          editorBgColor: LIGHT_THEME.editorBg,
          textColor: LIGHT_THEME.text,
          onContentChange: (value: string): void => {
            this.wordCount = getWordCount(value);
            this.saveCurrentDocument();
          }
        })
          .layoutWeight(1);

        Row() {
          Text(this.saveLabel)
            .fontSize(11)
            .fontColor(LIGHT_THEME.textSecondary);
          Blank();
          Text(`Words ${this.wordCount}`)
            .fontSize(11)
            .fontColor(LIGHT_THEME.textSecondary);
        }
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
      Button('Workspace')
        .fontSize(12)
        .backgroundColor(LIGHT_THEME.surface)
        .fontColor(LIGHT_THEME.text)
        .onClick((): void => {
          this.backToWorkspace();
        });

      Blank();

      Text('Editor')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);

      Blank();

      Button('Preview')
        .fontSize(12)
        .backgroundColor(LIGHT_THEME.primary)
        .fontColor('#FFFFFF')
        .onClick((): void => {
          this.openPreview();
        });
    }
      .padding({ left: 16, right: 16, top: 14, bottom: 10 })
      .backgroundColor(LIGHT_THEME.background);
  }

  private timeStr(timestamp: number): string {
    const diff = Date.now() - timestamp;
    if (diff < 60000) {
      return 'just now';
    }
    if (diff < 3600000) {
      return `${Math.floor(diff / 60000)} min ago`;
    }
    return `${Math.floor(diff / 3600000)} hour ago`;
  }
}
