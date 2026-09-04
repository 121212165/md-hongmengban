import { RelaySession } from '../models/RelaySessionModel';
import { FileService } from './FileService';

export class RelayService {
  private static instance: RelayService;

  private constructor() {
  }

  static getInstance(): RelayService {
    if (!RelayService.instance) {
      RelayService.instance = new RelayService();
    }
    return RelayService.instance;
  }

  startRelay(targetDeviceName: string): RelaySession | null {
    return FileService.getInstance().startRelayForCurrentDocument(targetDeviceName);
  }

  getLatestSession(): RelaySession | null {
    return FileService.getInstance().getLatestRelaySession();
  }

  getSessionsForCurrentDocument(): RelaySession[] {
    return FileService.getInstance().getRelaySessionsForCurrentDocument();
  }
}
