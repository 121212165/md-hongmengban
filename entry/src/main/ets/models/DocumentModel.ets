export enum DocumentKind {
  MARKDOWN = 'markdown',
  MEETING = 'meeting',
  ARTICLE = 'article',
  IDEA = 'idea'
}

export enum DraftStatus {
  ACTIVE = 'active',
  PAUSED = 'paused',
  ARCHIVED = 'archived'
}

export interface DocumentStats {
  wordCount: number;
  lineCount: number;
}

export interface Document {
  id: string;
  projectId: string;
  name: string;
  content: string;
  kind: DocumentKind;
  status: DraftStatus;
  summary: string;
  tags: string[];
  createdAt: number;
  updatedAt: number;
  lastOpenedAt: number;
  stats: DocumentStats;
}

export interface DraftSnapshot {
  id: string;
  documentId: string;
  title: string;
  excerpt: string;
  createdAt: number;
}

export function buildDocumentStats(content: string): DocumentStats {
  const lines: string[] = content.length > 0 ? content.split('\n') : [];
  const compact = content.replace(/\s/g, '');
  return {
    wordCount: compact.length,
    lineCount: lines.length
  };
}

let _docSeq = 0;

export function createDocument(name: string, content: string = '', projectId: string = 'inbox'): Document {
  const now = Date.now();
  const safeName = name.endsWith('.md') ? name : `${name}.md`;
  return {
    id: `doc_${now}_${++_docSeq}`,
    projectId: projectId,
    name: safeName,
    content: content,
    kind: DocumentKind.MARKDOWN,
    status: DraftStatus.ACTIVE,
    summary: '',
    tags: [],
    createdAt: now,
    updatedAt: now,
    lastOpenedAt: now,
    stats: buildDocumentStats(content)
  };
}

export function touchDocument(document: Document, content: string, name?: string): Document {
  const nextName = name ? (name.endsWith('.md') ? name : `${name}.md`) : document.name;
  return {
    id: document.id,
    projectId: document.projectId,
    name: nextName,
    content: content,
    kind: document.kind,
    status: document.status,
    summary: document.summary,
    tags: document.tags,
    createdAt: document.createdAt,
    updatedAt: Date.now(),
    lastOpenedAt: Date.now(),
    stats: buildDocumentStats(content)
  };
}

export function createSnapshot(document: Document): DraftSnapshot {
  return {
    id: `snapshot_${Date.now()}`,
    documentId: document.id,
    title: document.name,
    excerpt: document.content.slice(0, 120),
    createdAt: Date.now()
  };
}

export const DOCUMENTS_KEY = 'harmony_md_documents';
export const CURRENT_DOC_KEY = 'harmony_md_current';
export const SNAPSHOTS_KEY = 'harmony_md_snapshots';
