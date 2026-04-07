import { Context } from '@kit.AbilityKit';
import { BabyRepository } from '../repository/BabyRepository';
import { DiaperRepository } from '../repository/DiaperRepository';
import { AppPreferencesService } from '../preferences/AppPreferencesService';
import GlobalContext from '../lib/GlobalContext';

export interface ExportedBaby {
  id: number;
  name: string;
  dateOfBirth: string;
  image: string;
  gender: string;
  isArchived: boolean;
  archivedAt: string | null;
}

export interface ExportedDiaper {
  id: number;
  babyId: number;
  type: string;
  timestamp: string;
  note: string | null;
  intensity: string | null;
  condition: string | null;
}

export interface BackupPreferences {
  homeSortMode: string;
  archiveVisible: boolean;
  insightPeriod: string;
  reminderDefaults: object;
}

export interface BackupData {
  version: number;
  exportedAt: string;
  babies: ExportedBaby[];
  diapers: ExportedDiaper[];
  preferences: BackupPreferences;
}

export interface RestoreResult {
  babiesCount: number;
  diapersCount: number;
}

class BackupService {
  private static instance?: BackupService;

  static getInstance(): BackupService {
    if (!BackupService.instance) {
      BackupService.instance = new BackupService();
    }
    return BackupService.instance;
  }

  async buildBackupJson(): Promise<string> {
    const ctx = GlobalContext.getInstance().getSavedContext();
    if (!ctx) {
      throw new Error('No application context');
    }
    return this.generateBackupJson(ctx);
  }

  async restoreFromBackupJson(json: string): Promise<RestoreResult> {
    const ctx = GlobalContext.getInstance().getSavedContext();
    if (!ctx) {
      throw new Error('No application context');
    }

    let data: BackupData;
    try {
      const parsedStr: string = json;
      const parsedObj: object = JSON.parse(parsedStr);
      data = this.validateBackupData(parsedObj as BackupData);
    } catch {
      throw new Error('Invalid backup file');
    }

    const babyRepo = await BabyRepository.getInstance(ctx);
    const diaperRepo = await DiaperRepository.getInstance(ctx);

    let babiesCount = 0;
    for (let i = 0; i < data.babies.length; i++) {
      const b = data.babies[i];
      await babyRepo.addBaby(b.name, new Date(b.dateOfBirth), b.image, b.gender);
      babiesCount++;
    }

    let diapersCount = 0;
    for (let i = 0; i < data.diapers.length; i++) {
      const d = data.diapers[i];
      await diaperRepo.addDiaper(
        d.babyId,
        d.type,
        d.note ?? undefined,
        d.intensity ?? undefined,
        d.condition ?? undefined,
        d.timestamp ? new Date(d.timestamp) : undefined
      );
      diapersCount++;
    }

    const result: RestoreResult = { babiesCount: babiesCount, diapersCount: diapersCount };
    return result;
  }

  private async generateBackupJson(ctx: Context): Promise<string> {
    const babyRepo = await BabyRepository.getInstance(ctx);
    const diaperRepo = await DiaperRepository.getInstance(ctx);
    const prefsService = await AppPreferencesService.getInstance(ctx);

    const iBabies = await babyRepo.getBabyList();
    const babies: ExportedBaby[] = [];
    for (let i = 0; i < iBabies.length; i++) {
      const b = iBabies[i];
      babies.push({
        id: b.id!,
        name: b.name,
        dateOfBirth: b.dateOfBirth.toISOString(),
        image: b.image ?? '',
        gender: b.gender ?? '',
        isArchived: b.isArchived ?? false,
        archivedAt: b.archivedAt ? b.archivedAt.toISOString() : null
      });
    }

    const diapers: ExportedDiaper[] = [];
    for (let bi = 0; bi < iBabies.length; bi++) {
      const babyId = iBabies[bi].id!;
      const iDiapers = await diaperRepo.getDiaperListByBabyId(babyId);
      for (let di = 0; di < iDiapers.length; di++) {
        const diaper = iDiapers[di];
        diapers.push({
          id: diaper.id!,
          babyId: diaper.babyId!,
          type: diaper.type ?? 'pee',
          timestamp: diaper.timestamp ? diaper.timestamp.toISOString() : new Date().toISOString(),
          note: diaper.note ?? null,
          intensity: diaper.intensity ?? null,
          condition: diaper.condition ?? null
        });
      }
    }

    const prefs = await prefsService.getState();
    const prefsForBackup: BackupPreferences = {
      homeSortMode: prefs.homeSortMode,
      archiveVisible: prefs.archiveVisible,
      insightPeriod: prefs.insightPeriod,
      reminderDefaults: prefs.reminderDefaults
    };

    const backupData: BackupData = {
      version: 1,
      exportedAt: new Date().toISOString(),
      babies: babies,
      diapers: diapers,
      preferences: prefsForBackup
    };

    return JSON.stringify(backupData);
  }

  private validateBackupData(raw: BackupData): BackupData {
    if (!raw || typeof raw.version !== 'number' || !Array.isArray(raw.babies) || !Array.isArray(raw.diapers)) {
      throw new Error('Invalid backup data structure');
    }
    return raw;
  }
}

export default BackupService;
