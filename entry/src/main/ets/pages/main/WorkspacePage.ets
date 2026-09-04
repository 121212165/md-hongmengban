import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import router from '@ohos.router';
import { LIGHT_THEME } from '../../common/constants/CommonConstants';
import { Document } from '../../models/DocumentModel';
import { Project, ProjectTemplate } from '../../models/ProjectModel';
import { FileService } from '../../services/FileService';
import { ImportService } from '../../services/ImportService';
import { ProjectService } from '../../services/ProjectService';

const DOMAIN = 0x0001;
const TAG = 'WorkspacePage';

@Entry
@Component
struct WorkspacePage {
  @State projects: Project[] = [];
  @State docs: Document[] = [];
  @State currentProjectId: string = '';
  @State currentProjectName: string = 'Workspace';
  @State statusText: string = 'Local-first Markdown workspace';

  async aboutToAppear() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await FileService.getInstance().init(context);
      this.reload();
    } catch (_error) {
      hilog.error(DOMAIN, TAG, 'workspace init failed');
    }
  }

  private reload(): void {
    const currentProject = ProjectService.getInstance().getCurrentProject();
    this.projects = ProjectService.getInstance().getProjects();
    this.currentProjectId = currentProject ? currentProject.id : '';
    this.currentProjectName = currentProject ? currentProject.name : 'Workspace';
    this.docs = FileService.getInstance().getDocumentsByProject(this.currentProjectId || null);
  }

  private createProject(template: ProjectTemplate): void {
    const count = this.projects.length + 1;
    let title = `Workspace ${count}`;
    let description = 'Local drafts and structured notes';
    if (template === ProjectTemplate.ARTICLE) {
      title = `Article ${count}`;
      description = 'Article drafts and publish-ready content';
    } else if (template === ProjectTemplate.MEETING) {
      title = `Meeting ${count}`;
      description = 'Meeting notes and action items';
    }
    ProjectService.getInstance().createProject(title, description, template);
    this.statusText = `Created ${title}`;
    this.reload();
  }

  private createDocument(): void {
    const document = FileService.getInstance().createDocument('Untitled', '', this.currentProjectId);
    FileService.getInstance().setCurrentDocument(document.id);
    this.statusText = `Created ${document.name}`;
    this.reload();
    this.openEditor();
  }

  private async importDocument(): Promise<void> {
    const document = await ImportService.getInstance().importIntoCurrentProject();
    if (document) {
      this.statusText = `Imported ${document.name}`;
      this.reload();
      this.openEditor();
      return;
    }
    this.statusText = 'Import canceled';
  }

  private switchProject(projectId: string): void {
    ProjectService.getInstance().switchProject(projectId);
    this.statusText = 'Workspace switched';
    this.reload();
  }

  private openDocument(documentId: string): void {
    FileService.getInstance().setCurrentDocument(documentId);
    this.openEditor();
  }

  private openEditor(): void {
    router.pushUrl({
      url: 'pages/main/EditorPage'
    }).catch(() => {
      hilog.error(DOMAIN, TAG, 'editor route failed');
    });
  }

  build() {
    Column({ space: 14 }) {
      this.buildHero();
      this.buildTemplateRow();
      this.buildActionRow();
      this.buildProjectList();
      this.buildDocumentList();
    }
      .padding(16)
      .width('100%')
      .height('100%')
      .backgroundColor(LIGHT_THEME.background);
  }

  @Builder
  private buildHero() {
    Column({ space: 8 }) {
      Text('hongmengMD 0.0.2')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);
      Text('Create or import content, then edit, preview, export, and share.')
        .fontSize(12)
        .fontColor(LIGHT_THEME.textSecondary);
      Row() {
        Text(`Workspace: ${this.currentProjectName}`)
          .fontSize(12)
          .fontColor(LIGHT_THEME.text);
        Blank();
        Text(this.statusText)
          .fontSize(11)
          .fontColor(LIGHT_THEME.textSecondary);
      }
    }
      .padding(16)
      .backgroundColor(LIGHT_THEME.accentSoft)
      .borderRadius(24);
  }

  @Builder
  private buildTemplateRow() {
    Column({ space: 8 }) {
      Text('Templates')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);
      Row({ space: 8 }) {
        this.buildActionButton('Blank Note', (): void => {
          this.createProject(ProjectTemplate.QUICK_CAPTURE);
        });
        this.buildActionButton('Article', (): void => {
          this.createProject(ProjectTemplate.ARTICLE);
        });
        this.buildActionButton('Meeting', (): void => {
          this.createProject(ProjectTemplate.MEETING);
        });
      }
    }
      .padding(14)
      .backgroundColor(LIGHT_THEME.backgroundSecondary)
      .borderRadius(22);
  }

  @Builder
  private buildActionRow() {
    Column({ space: 8 }) {
      Text('Actions')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);
      Row({ space: 8 }) {
        this.buildActionButton('New Doc', (): void => {
          this.createDocument();
        });
        this.buildActionButton('Import File', (): void => {
          void this.importDocument();
        });
      }
    }
      .padding(14)
      .backgroundColor(LIGHT_THEME.backgroundSecondary)
      .borderRadius(22);
  }

  @Builder
  private buildProjectList() {
    Column({ space: 8 }) {
      Text('Projects')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(LIGHT_THEME.text);
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.projects, (project: Project) => {
            Column({ space: 4 }) {
              Text(project.name)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(project.id === this.currentProjectId ? '#FFFFFF' : LIGHT_THEME.text);
              Text(project.description)
                .fontSize(9)
                .maxLines(2)
                .fontColor(project.id === this.currentProjectId ? '#DDEBFF' : LIGHT_THEME.textSecondary);
            }
              .width(168)
              .padding(14)
              .backgroundColor(project.id === this.currentProjectId ? project.colorToken : LIGHT_THEME.surface)
              .borderRadius(18)
              .onClick((): void => {
                this.switchProject(project.id);
              });
          }, (project: Project) => project.id);
        }
      }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off);
    }
      .padding(14)
      .backgroundColor(LIGHT_THEME.backgroundSecondary)
      .borderRadius(22);
  }

  @Builder
  private buildDocumentList() {
    Column({ space: 10 }) {
      Row() {
        Text('Documents')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(LIGHT_THEME.text);
        Blank();
        Text(`${this.docs.length} item(s)`)
          .fontSize(10)
          .fontColor(LIGHT_THEME.textSecondary);
      }

      if (this.docs.length === 0) {
        Text('Create or import a document in this workspace.')
          .fontSize(11)
          .fontColor(LIGHT_THEME.textSecondary);
      } else {
        List({ space: 10 }) {
          ForEach(this.docs, (doc: Document) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(doc.name)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(LIGHT_THEME.text)
                  .maxLines(1);
                Text(doc.summary || 'No summary yet')
                  .fontSize(10)
                  .fontColor(LIGHT_THEME.textSecondary)
                  .maxLines(2);
                Text(this.timeStr(doc.updatedAt))
                  .fontSize(9)
                  .fontColor(LIGHT_THEME.textSecondary);
              }
                .alignItems(HorizontalAlign.Start)
                .padding(14)
                .backgroundColor(LIGHT_THEME.surface)
                .borderRadius(18)
                .onClick((): void => {
                  this.openDocument(doc.id);
                });
            }
          }, (doc: Document) => doc.id);
        }
          .layoutWeight(1)
          .divider({ strokeWidth: 0 });
      }
    }
      .layoutWeight(1)
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

  private timeStr(timestamp: number): string {
    const diff = Date.now() - timestamp;
    if (diff < 60000) {
      return 'just now';
    }
    if (diff < 3600000) {
      return `${Math.floor(diff / 60000)} min ago`;
    }
    if (diff < 86400000) {
      return `${Math.floor(diff / 3600000)} hour ago`;
    }
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}/${date.getDate()}`;
  }
}
