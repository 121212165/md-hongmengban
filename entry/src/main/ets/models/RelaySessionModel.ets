export enum RelayStatus {
  IDLE = 'idle',
  READY = 'ready',
  RELAYING = 'relaying',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

export interface RelaySession {
  id: string;
  documentId: string;
  sourceDeviceName: string;
  targetDeviceName: string;
  status: RelayStatus;
  handoffNote: string;
  startedAt: number;
  updatedAt: number;
}

export function createRelaySession(documentId: string, targetDeviceName: string): RelaySession {
  const now = Date.now();
  return {
    id: `relay_${now}`,
    documentId: documentId,
    sourceDeviceName: 'Phone',
    targetDeviceName: targetDeviceName,
    status: RelayStatus.COMPLETED,
    handoffNote: 'Relay snapshot saved for the target device.',
    startedAt: now,
    updatedAt: now
  };
}

export const RELAY_SESSIONS_KEY = 'hongmengmd_relay_sessions';
