export enum ProjectTemplate {
  QUICK_CAPTURE = 'quick_capture',
  ARTICLE = 'article',
  MEETING = 'meeting',
  LEARNING = 'learning',
  README = 'readme'
}

export interface Project {
  id: string;
  name: string;
  description: string;
  template: ProjectTemplate;
  colorToken: string;
  createdAt: number;
  updatedAt: number;
}

function colorForTemplate(template: ProjectTemplate): string {
  if (template === ProjectTemplate.ARTICLE) {
    return '#0A84FF';
  }
  if (template === ProjectTemplate.MEETING) {
    return '#F59E0B';
  }
  if (template === ProjectTemplate.LEARNING) {
    return '#10B981';
  }
  if (template === ProjectTemplate.README) {
    return '#8B5CF6';
  }
  return '#0A84FF';
}

let _projectSeq = 0;

export function createProject(
  name: string,
  description: string = '',
  template: ProjectTemplate = ProjectTemplate.QUICK_CAPTURE
): Project {
  const now = Date.now();
  return {
    id: `project_${now}_${++_projectSeq}`,
    name: name,
    description: description,
    template: template,
    colorToken: colorForTemplate(template),
    createdAt: now,
    updatedAt: now
  };
}

export const PROJECTS_KEY = 'hongmengmd_projects';
export const CURRENT_PROJECT_KEY = 'hongmengmd_current_project';
