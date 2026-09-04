export interface ThemeColorConfig {
  primary: string;
  background: string;
  backgroundSecondary: string;
  surface: string;
  text: string;
  textSecondary: string;
  border: string;
  editorBg: string;
  previewBg: string;
  toolbarBg: string;
  accentSoft: string;
}

export class ToolbarButton {
  icon: string;
  label: string;
  insertText: string;

  constructor(icon: string, label: string, insertText: string) {
    this.icon = icon;
    this.label = label;
    this.insertText = insertText;
  }
}

export const TOOLBAR_BUTTONS: ToolbarButton[] = [
  new ToolbarButton('H1', '\u6807\u9898', '# '),
  new ToolbarButton('B', '\u52a0\u7c97', '**'),
  new ToolbarButton('I', '\u659c\u4f53', '*'),
  new ToolbarButton('`', '\u884c\u5185\u7801', '`'),
  new ToolbarButton('{ }', '\u4ee3\u7801\u5757', '\n```\n\n```\n'),
  new ToolbarButton('- -', '\u5217\u8868', '- '),
  new ToolbarButton('> ', '\u5f15\u7528', '> '),
  new ToolbarButton('[ ]', '\u4efb\u52a1', '- [ ] '),
  new ToolbarButton('[]', '\u94fe\u63a5', '[](url)'),
  new ToolbarButton('![]', '\u56fe\u7247', '![alt](url)'),
  new ToolbarButton('| |', '\u8868\u683c', '\n| \u6807\u9898 | \u5185\u5bb9 |\n| --- | --- |\n| \u6761\u76ee | \u8bf4\u660e |\n'),
  new ToolbarButton('---', '\u5206\u9694\u7ebf', '\n---\n')
];

export const LIGHT_THEME: ThemeColorConfig = {
  primary: '#0A84FF',
  background: '#F3F6F8',
  backgroundSecondary: '#E7EDF3',
  surface: '#FFFFFF',
  text: '#18202A',
  textSecondary: '#6D7785',
  border: '#D8E0E8',
  editorBg: '#FFFFFF',
  previewBg: '#FDFEFE',
  toolbarBg: '#EAF0F5',
  accentSoft: '#DDEBFF'
};

export const DARK_THEME: ThemeColorConfig = {
  primary: '#53A7FF',
  background: '#11161C',
  backgroundSecondary: '#1A232D',
  surface: '#18212A',
  text: '#F3F6F8',
  textSecondary: '#93A0AF',
  border: '#2B3742',
  editorBg: '#18212A',
  previewBg: '#151D25',
  toolbarBg: '#11161C',
  accentSoft: '#173250'
};

export enum SyncStatus {
  SYNCED = 'synced',
  SYNCING = 'syncing',
  OFFLINE = 'offline'
}
