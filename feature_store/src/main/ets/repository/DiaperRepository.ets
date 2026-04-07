import { Context } from '@kit.AbilityKit';
import { Database } from '../Database';
import { IDiaper } from '../Interfaces';

export class DiaperRepository {
  private static instance?: DiaperRepository;
  private readonly database: Database;

  private constructor(database: Database) {
    this.database = database;
  }

  static async getInstance(context: Context): Promise<DiaperRepository> {
    if (!DiaperRepository.instance) {
      const database = await Database.getInstance(context);
      await database.init();
      DiaperRepository.instance = new DiaperRepository(database);
    }

    return DiaperRepository.instance;
  }

  async getDiaperListByBabyId(babyId: number, isOne: boolean = false): Promise<IDiaper[]> {
    return this.database.getDiaperListByBabyId(babyId, isOne);
  }

  async getDiaperListByBabyIdFiltered(
    babyId: number,
    startTime?: number,
    endTime?: number,
    typeFilter?: string,
  ): Promise<IDiaper[]> {
    return this.database.getDiaperListByBabyIdFiltered(babyId, startTime, endTime, typeFilter);
  }

  async addDiaper(
    babyId: number,
    type: string,
    note?: string,
    intensity?: string,
    condition?: string,
    manualTimestamp?: Date,
  ): Promise<number | null> {
    return this.database.insertBabyDiaper(babyId, type, note, intensity, condition, manualTimestamp);
  }

  async updateDiaper(
    id: number,
    babyId: number,
    type: string,
    note?: string | null,
    intensity?: string | null,
    condition?: string | null,
    manualTimestamp?: Date | null,
  ): Promise<number | null> {
    return this.database.updateDiaper(id, babyId, type, note, intensity, condition, manualTimestamp);
  }

  async deleteDiaper(diaper: IDiaper): Promise<void> {
    await this.database.deleteDiaper(diaper);
  }
}
