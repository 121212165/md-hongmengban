import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import fileIo from '@ohos.fileio';
import {
  createDocument,
  createSnapshot,
  CURRENT_DOC_KEY,
  Document,
  DOCUMENTS_KEY,
  DraftSnapshot,
  SNAPSHOTS_KEY,
  touchDocument
} from '../models/DocumentModel';
import {
  createProject,
  CURRENT_PROJECT_KEY,
  Project,
  PROJECTS_KEY,
  ProjectTemplate
} from '../models/ProjectModel';
import {
  createRelaySession,
  RelaySession,
  RELAY_SESSIONS_KEY
} from '../models/RelaySessionModel';
import {
  createExportTask,
  ExportFormat,
  ExportStatus,
  ExportTask,
  EXPORT_TASKS_KEY
} from '../models/ExportTaskModel';

const TAG = 'FileService';
const DOMAIN = 0x0001;
const STORE_NAME = 'hongmengmd_store';
const EXPORT_DIR_NAME = 'exports';
const TEXT_INBOX = '\u6536\u4ef6\u7bb1';
const TEXT_UNTITLED = '\u672a\u547d\u540d.md';

export class FileService {
  private static instance: FileService;
  private context: common.UIAbilityContext | null = null;
  private store: preferences.Preferences | null = null;
  private documents: Document[] = [];
  private projects: Project[] = [];
  private relaySessions: RelaySession[] = [];
  private exportTasks: ExportTask[] = [];
  private snapshots: DraftSnapshot[] = [];
  private currentDocId: string | null = null;
  private currentProjectId: string | null = null;

  private constructor() {
  }

  static getInstance(): FileService {
    if (!FileService.instance) {
      FileService.instance = new FileService();
    }
    return FileService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return;
    }
    try {
      this.context = context;
      this.store = await preferences.getPreferences(context, STORE_NAME);
      this.loadState();
      hilog.info(DOMAIN, TAG, 'FileService initialized');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to init FileService: %{public}s', JSON.stringify(error));
    }
  }

  getContext(): common.UIAbilityContext | null {
    return this.context;
  }

  private loadState(): void {
    try {
      const store = this.getStore();
      this.documents = this.parseList<Document>(store.getSync(DOCUMENTS_KEY, '[]') as string);
      this.projects = this.parseList<Project>(store.getSync(PROJECTS_KEY, '[]') as string);
      this.relaySessions = this.parseList<RelaySession>(store.getSync(RELAY_SESSIONS_KEY, '[]') as string);
      this.exportTasks = this.parseList<ExportTask>(store.getSync(EXPORT_TASKS_KEY, '[]') as string);
      this.snapshots = this.parseList<DraftSnapshot>(store.getSync(SNAPSHOTS_KEY, '[]') as string);
      this.currentDocId = (store.getSync(CURRENT_DOC_KEY, '') as string) || null;
      this.currentProjectId = (store.getSync(CURRENT_PROJECT_KEY, '') as string) || null;
      this.ensureSeedData();
      this.persistState();
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load data: %{public}s', JSON.stringify(error));
      this.resetToSeed();
      this.persistState();
    }
  }

  private parseList<T>(raw: string): T[] {
    if (!raw) {
      return [];
    }
    return JSON.parse(raw) as T[];
  }

  private ensureSeedData(): void {
    if (this.projects.length === 0) {
      const inbox = createProject(
        TEXT_INBOX,
        '\u5728\u624b\u673a\u5feb\u901f\u6355\u6349\u5185\u5bb9\uff0c\u5e76\u5728\u66f4\u5927\u8bbe\u5907\u7ee7\u7eed\u5b8c\u6210\u3002',
        ProjectTemplate.QUICK_CAPTURE
      );
      const article = createProject(
        '\u6587\u7ae0\u8349\u7a3f',
        '\u9762\u5411\u53d1\u5e03\u7684\u7ed3\u6784\u5316\u5185\u5bb9\u3002',
        ProjectTemplate.ARTICLE
      );
      const meeting = createProject(
        '\u4f1a\u8bae\u7eaa\u8981',
        '\u5feb\u901f\u8bb0\u5f55\u4f1a\u8bae\u8981\u70b9\u4e0e\u5f85\u529e\u3002',
        ProjectTemplate.MEETING
      );
      this.projects = [inbox, article, meeting];
      this.currentProjectId = inbox.id;
    }

    if (!this.currentProjectId) {
      this.currentProjectId = this.projects[0].id;
    }

    if (this.documents.length === 0) {
      const inboxId = this.projects[0].id;
      const articleProject = this.projects.find((project: Project) => project.template === ProjectTemplate.ARTICLE);
      const meetingProject = this.projects.find((project: Project) => project.template === ProjectTemplate.MEETING);
      const welcome = createDocument(
        '\u6b22\u8fce\u4f7f\u7528.md',
        '# \u5185\u5bb9\u63a5\u529b\u5de5\u4f5c\u53f0\n\n- \u5feb\u901f\u8bb0\u5f55\u7075\u611f\n- \u5207\u6362\u8bbe\u5907\u7ee7\u7eed\u7f16\u8f91\n- \u5bfc\u51fa Markdown / Text / PDF / Long Image\n',
        inboxId
      );
      welcome.summary = this.buildSummary(welcome.content);
      const articleDoc = createDocument(
        '\u53d1\u5e03\u8ba1\u5212.md',
        '# \u56db\u6708\u53d1\u5e03\u8ba1\u5212\n\n## \u4e3b\u9898\n- MVP \u529f\u80fd\u6536\u53e3\n- \u6d4b\u8bd5\u7ed3\u679c\u6574\u7406\n- \u5bfc\u51fa\u793a\u4f8b\u51c6\u5907\n',
        articleProject ? articleProject.id : inboxId
      );
      articleDoc.summary = this.buildSummary(articleDoc.content);
      const meetingDoc = createDocument(
        '\u7ad9\u4f1a\u7eaa\u8981.md',
        '# \u4eca\u65e5\u7ad9\u4f1a\n\n- [x] \u4fee\u590d\u4e3b\u7f16\u8f91\u9875\n- [x] \u8865\u9f50\u5bfc\u51fa\u8bb0\u5f55\n- [ ] \u5b8c\u6210 MVP \u81ea\u6d4b\n',
        meetingProject ? meetingProject.id : inboxId
      );
      meetingDoc.summary = this.buildSummary(meetingDoc.content);

      this.documents = [welcome, articleDoc, meetingDoc];
      this.currentDocId = welcome.id;
      this.snapshots = [
        createSnapshot(welcome),
        createSnapshot(articleDoc),
        createSnapshot(meetingDoc)
      ];
    }

    if (!this.currentDocId || !this.documents.some((doc: Document) => doc.id === this.currentDocId)) {
      const current = this.getDocumentsByProject(this.currentProjectId)[0] || this.documents[0];
      this.currentDocId = current ? current.id : null;
    }
  }

  private resetToSeed(): void {
    this.projects = [];
    this.documents = [];
    this.relaySessions = [];
    this.exportTasks = [];
    this.snapshots = [];
    this.currentProjectId = null;
    this.currentDocId = null;
    this.ensureSeedData();
  }

  private persistState(): void {
    try {
      const store = this.getStore();
      store.putSync(DOCUMENTS_KEY, JSON.stringify(this.documents));
      store.putSync(PROJECTS_KEY, JSON.stringify(this.projects));
      store.putSync(RELAY_SESSIONS_KEY, JSON.stringify(this.relaySessions));
      store.putSync(EXPORT_TASKS_KEY, JSON.stringify(this.exportTasks));
      store.putSync(SNAPSHOTS_KEY, JSON.stringify(this.snapshots.slice(0, 12)));
      store.putSync(CURRENT_DOC_KEY, this.currentDocId ?? '');
      store.putSync(CURRENT_PROJECT_KEY, this.currentProjectId ?? '');
      store.flushSync();
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to persist data: %{public}s', JSON.stringify(error));
    }
  }

  private getStore(): preferences.Preferences {
    if (!this.store) {
      throw new Error('Preferences store is not initialized');
    }
    return this.store;
  }

  getProjects(): Project[] {
    return [...this.projects].sort((a: Project, b: Project) => b.updatedAt - a.updatedAt);
  }

  getCurrentProject(): Project | null {
    if (!this.currentProjectId) {
      return this.projects.length > 0 ? this.projects[0] : null;
    }
    return this.projects.find((project: Project) => project.id === this.currentProjectId) || null;
  }

  setCurrentProject(projectId: string): void {
    this.currentProjectId = projectId;
    const firstDoc = this.getDocumentsByProject(projectId)[0];
    if (firstDoc) {
      this.currentDocId = firstDoc.id;
    }
    this.persistState();
  }

  createProject(name: string, description: string = '', template: ProjectTemplate = ProjectTemplate.QUICK_CAPTURE): Project {
    const project = createProject(name, description, template);
    this.projects.unshift(project);
    this.currentProjectId = project.id;
    const firstDocName = this.defaultDocumentName(template, name);
    const firstDocContent = this.defaultDocumentContent(template, name);
    const document = createDocument(firstDocName, firstDocContent, project.id);
    document.summary = this.buildSummary(document.content);
    this.documents.unshift(document);
    this.currentDocId = document.id;
    this.pushSnapshot(document);
    this.persistState();
    return project;
  }

  getDocuments(): Document[] {
    return [...this.documents];
  }

  getDocumentsByProject(projectId: string | null): Document[] {
    if (!projectId) {
      return [...this.documents].sort((a: Document, b: Document) => b.updatedAt - a.updatedAt);
    }
    return this.documents
      .filter((doc: Document) => doc.projectId === projectId)
      .sort((a: Document, b: Document) => b.updatedAt - a.updatedAt);
  }

  getCurrentDocument(): Document | null {
    if (!this.currentDocId) {
      return this.documents.length > 0 ? this.documents[0] : null;
    }
    return this.documents.find((doc: Document) => doc.id === this.currentDocId) || null;
  }

  getCurrentDocId(): string | null {
    return this.currentDocId;
  }

  setCurrentDocument(docId: string): void {
    const doc = this.documents.find((item: Document) => item.id === docId);
    if (!doc) {
      return;
    }
    doc.lastOpenedAt = Date.now();
    this.currentDocId = docId;
    this.currentProjectId = doc.projectId;
    this.persistState();
  }

  createDocument(name: string, content: string = '', projectId?: string): Document {
    const nextProjectId = projectId ?? this.currentProjectId ?? this.projects[0].id;
    const doc = createDocument(name, content, nextProjectId);
    doc.summary = this.buildSummary(content);
    this.documents.unshift(doc);
    this.currentProjectId = nextProjectId;
    this.currentDocId = doc.id;
    this.pushSnapshot(doc);
    this.persistState();
    return doc;
  }

  saveDocumentContent(docId: string, content: string): boolean {
    const index = this.documents.findIndex((item: Document) => item.id === docId);
    if (index === -1) {
      return false;
    }
    const updated = touchDocument(this.documents[index], content);
    updated.summary = this.buildSummary(content);
    this.documents[index] = updated;
    this.touchProject(updated.projectId);
    this.pushSnapshot(updated);
    this.persistState();
    return true;
  }

  saveDocumentName(docId: string, name: string): boolean {
    const index = this.documents.findIndex((item: Document) => item.id === docId);
    if (index === -1) {
      return false;
    }
    const updated = touchDocument(this.documents[index], this.documents[index].content, name);
    updated.summary = this.documents[index].summary;
    this.documents[index] = updated;
    this.touchProject(updated.projectId);
    this.persistState();
    return true;
  }

  getSnapshots(documentId: string): DraftSnapshot[] {
    return this.snapshots.filter((item: DraftSnapshot) => item.documentId === documentId);
  }

  startRelayForCurrentDocument(targetDeviceName: string): RelaySession | null {
    const doc = this.getCurrentDocument();
    if (!doc) {
      return null;
    }
    const session = createRelaySession(doc.id, targetDeviceName);
    this.relaySessions.unshift(session);
    this.persistState();
    return session;
  }

  getLatestRelaySession(documentId?: string): RelaySession | null {
    const session = documentId
      ? this.relaySessions.find((item: RelaySession) => item.documentId === documentId)
      : this.relaySessions[0];
    return session || null;
  }

  getRelaySessionsForCurrentDocument(): RelaySession[] {
    const currentDocId = this.getCurrentDocId();
    if (!currentDocId) {
      return [];
    }
    return this.relaySessions
      .filter((item: RelaySession) => item.documentId === currentDocId)
      .sort((a: RelaySession, b: RelaySession) => b.updatedAt - a.updatedAt);
  }

  createExportForCurrentDocument(format: ExportFormat): ExportTask | null {
    const doc = this.getCurrentDocument();
    if (!doc) {
      hilog.warn(DOMAIN, TAG, 'Export skipped: no current document');
      return null;
    }
    const outputName = this.buildExportFileName(doc.name, format);
    const task = createExportTask(doc.id, format, outputName);
    this.executeExport(task, doc.content, doc.name);
    this.exportTasks.unshift(task);
    this.persistState();
    return task;
  }

  getLatestExportTask(documentId?: string): ExportTask | null {
    const task = documentId
      ? this.exportTasks.find((item: ExportTask) => item.documentId === documentId)
      : this.exportTasks[0];
    return task || null;
  }

  getExportTasksForCurrentDocument(): ExportTask[] {
    const currentDocId = this.getCurrentDocId();
    if (!currentDocId) {
      return [];
    }
    return this.exportTasks
      .filter((item: ExportTask) => item.documentId === currentDocId)
      .sort((a: ExportTask, b: ExportTask) => b.updatedAt - a.updatedAt);
  }

  saveExportTask(task: ExportTask): void {
    const index = this.exportTasks.findIndex((item: ExportTask) => item.id === task.id);
    if (index >= 0) {
      this.exportTasks[index] = task;
    } else {
      this.exportTasks.unshift(task);
    }
    this.persistState();
  }

  private buildSummary(content: string): string {
    const oneLine = content.replace(/\n+/g, ' ').trim();
    return oneLine.slice(0, 80);
  }

  private pushSnapshot(document: Document): void {
    this.snapshots.unshift(createSnapshot(document));
    this.snapshots = this.snapshots.slice(0, 20);
  }

  private touchProject(projectId: string): void {
    const project = this.projects.find((item: Project) => item.id === projectId);
    if (project) {
      project.updatedAt = Date.now();
    }
  }

  private defaultDocumentName(template: ProjectTemplate, projectName: string): string {
    if (template === ProjectTemplate.ARTICLE) {
      return `${projectName}.md`;
    }
    if (template === ProjectTemplate.MEETING) {
      return '\u4f1a\u8bae\u7eaa\u8981.md';
    }
    if (template === ProjectTemplate.LEARNING) {
      return '\u5b66\u4e60\u7b14\u8bb0.md';
    }
    if (template === ProjectTemplate.README) {
      return 'README.md';
    }
    return TEXT_UNTITLED;
  }

  private defaultDocumentContent(template: ProjectTemplate, projectName: string): string {
    if (template === ProjectTemplate.ARTICLE) {
      return `# ${projectName}\n\n## \u6458\u8981\n\n## \u6b63\u6587\n`;
    }
    if (template === ProjectTemplate.MEETING) {
      return '# \u4f1a\u8bae\u7eaa\u8981\n\n## \u8bae\u9898\n\n## \u7ed3\u8bba\n\n## \u5f85\u529e\n- [ ] ';
    }
    if (template === ProjectTemplate.LEARNING) {
      return '# \u5b66\u4e60\u7b14\u8bb0\n\n## \u5173\u952e\u8981\u70b9\n\n## \u5f85\u590d\u4e60\n';
    }
    if (template === ProjectTemplate.README) {
      return `# ${projectName}\n\n## Overview\n\n## Usage\n`;
    }
    return '';
  }

  private executeExport(task: ExportTask, content: string, docName: string): void {
    if (!this.context || !this.context.filesDir) {
      task.status = ExportStatus.FAILED;
      task.errorMessage = 'UIAbilityContext.filesDir is unavailable';
      task.updatedAt = Date.now();
      return;
    }

    const exportDir = `${this.context.filesDir}/${EXPORT_DIR_NAME}`;
    const outputPath = `${exportDir}/${task.outputName}`;

    try {
      this.ensureDirectory(exportDir);
      const stream = fileIo.createStreamSync(outputPath, 'w+');
      stream.writeSync(this.normalizeExportContent(content, task.format, docName), { encoding: 'utf-8' });
      stream.flushSync();
      stream.closeSync();
      task.outputPath = outputPath;
      task.status = ExportStatus.SUCCEEDED;
      task.updatedAt = Date.now();
    } catch (error) {
      task.status = ExportStatus.FAILED;
      task.errorMessage = JSON.stringify(error);
      task.updatedAt = Date.now();
      hilog.error(DOMAIN, TAG, 'Export failed: %{public}s', task.errorMessage ?? 'unknown');
    }
  }

  private ensureDirectory(path: string): void {
    try {
      fileIo.accessSync(path);
    } catch (_error) {
      fileIo.mkdirSync(path);
    }
  }

  private buildExportFileName(name: string, format: ExportFormat): string {
    const timestamp = Date.now();
    let extension = 'md';
    if (format === ExportFormat.TEXT) {
      extension = 'txt';
    } else if (format === ExportFormat.PDF) {
      extension = 'pdf';
    } else if (format === ExportFormat.LONG_IMAGE || format === ExportFormat.SHARE_CARD) {
      extension = 'txt';
    }

    const normalized = name.replace(/\.[^.]+$/, '');
    const safeBase = normalized
      .replace(/[\\/:*?"<>|]/g, '_')
      .replace(/\s+/g, '_')
      .trim();
    const finalBase = safeBase.length > 0 ? safeBase : 'draft';
    return `${finalBase}_${timestamp}.${extension}`;
  }

  private normalizeExportContent(content: string, format: ExportFormat, docName: string): string {
    if (format === ExportFormat.TEXT) {
      return content.replace(/[#>*_`\-\[\]]/g, '').trim();
    }
    if (format === ExportFormat.PDF) {
      return `PDF EXPORT\nTitle: ${docName}\n\n${content}`;
    }
    if (format === ExportFormat.LONG_IMAGE) {
      return `LONG IMAGE EXPORT\nTitle: ${docName}\n\n${content}`;
    }
    if (format === ExportFormat.SHARE_CARD) {
      return `SHARE CARD\nTitle: ${docName}\nSummary: ${this.buildSummary(content)}`;
    }
    return content;
  }
}
