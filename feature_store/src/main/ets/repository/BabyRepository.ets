import { Context } from '@kit.AbilityKit';
import { Database } from '../Database';
import { IBaby } from '../Interfaces';

export interface BabyDiaperSummaryResult {
  lastChange?: Date;
  todayCount: number;
}

export class BabyRepository {
  private static instance?: BabyRepository;
  private readonly database: Database;

  private constructor(database: Database) {
    this.database = database;
  }

  static async getInstance(context: Context): Promise<BabyRepository> {
    if (!BabyRepository.instance) {
      const database = await Database.getInstance(context);
      try {
        await database.init();
      } catch (error) {
        // TODO: Implement error handling.
      }
      BabyRepository.instance = new BabyRepository(database);
    }

    return BabyRepository.instance;
  }

  async getBabyById(id: number): Promise<IBaby | null> {
    return this.database.getBaby(id);
  }

  async getBabyList(): Promise<IBaby[]> {
    return this.database.getBabyList();
  }

  async addBaby(
    name: string,
    dateOfBirth: Date,
    image: string,
    gender?: string,
    isArchived: boolean = false,
    archivedAt?: Date,
  ): Promise<number | null> {
    return this.database.insertBaby(name, dateOfBirth, image, gender, isArchived, archivedAt);
  }

  async updateBaby(
    id: number,
    name: string,
    dateOfBirth: Date,
    image: string,
    gender?: string | null,
    isArchived?: boolean | null,
    archivedAt?: Date | null,
  ): Promise<number | null> {
    return this.database.updateBaby(id, name, dateOfBirth, image, gender, isArchived, archivedAt);
  }

  async deleteBaby(id: number): Promise<void> {
    await this.database.deleteBaby(id);
  }

  async getBabyDiaperSummary(babyId: number): Promise<BabyDiaperSummaryResult> {
    const diapers = await this.database.getDiaperListByBabyId(babyId);
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    let lastChange: Date | undefined;
    let todayCount = 0;

    for (const diaper of diapers) {
      if (!lastChange || diaper.timestamp.getTime() > lastChange.getTime()) {
        lastChange = diaper.timestamp;
      }
      if (diaper.timestamp.getTime() >= todayStart.getTime()) {
        todayCount++;
      }
    }

    const result: BabyDiaperSummaryResult = {
      lastChange: lastChange,
      todayCount: todayCount
    };
    return result;
  }

  async addDiaper(babyId: number, type: string): Promise<number | null> {
    return this.database.insertBabyDiaper(babyId, type);
  }
}
