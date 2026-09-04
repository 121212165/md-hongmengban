import { Project, ProjectTemplate } from '../models/ProjectModel';
import { FileService } from './FileService';

export class ProjectService {
  private static instance: ProjectService;

  private constructor() {
  }

  static getInstance(): ProjectService {
    if (!ProjectService.instance) {
      ProjectService.instance = new ProjectService();
    }
    return ProjectService.instance;
  }

  getProjects(): Project[] {
    return FileService.getInstance().getProjects();
  }

  getCurrentProject(): Project | null {
    return FileService.getInstance().getCurrentProject();
  }

  createProject(name: string, description: string = '', template: ProjectTemplate = ProjectTemplate.QUICK_CAPTURE): Project {
    return FileService.getInstance().createProject(name, description, template);
  }

  createQuickCaptureProject(name: string, description: string = ''): Project {
    return this.createProject(name, description, ProjectTemplate.QUICK_CAPTURE);
  }

  switchProject(projectId: string): void {
    FileService.getInstance().setCurrentProject(projectId);
  }
}
