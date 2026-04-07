import { BabyDiaperSummaryResult, BabyRepository, GlobalContext } from 'feature_store';
import { GenderType } from '../components/GenderSelect';
import { Baby } from '../models/Baby';
import { DiaperType } from '../models/Diaper';
import ListDataSource from './ListDataSource';
import { isOverdue } from '../lib/date-utils';

export interface BabyDiaperSummary {
  lastChange?: Date;
  todayCount: number;
  isOverdue: boolean;
}

@Observed
export default class BabyViewModel {
  @Track
  isEmptyData: boolean = true;
  @Track
  datasource: ListDataSource<Baby> = new ListDataSource<Baby>();
  private babyRepository?: BabyRepository;
  private babyRepositoryPromise?: Promise<BabyRepository>;
  @Track
  private diaperSummaries: Map<number, BabyDiaperSummary> = new Map();

  constructor() {
    const context = GlobalContext.getInstance().getSavedContext();
    if (context) {
      this.babyRepositoryPromise = BabyRepository.getInstance(context).then((repository) => {
        this.babyRepository = repository;
        return repository;
      })
    }
  }

  getBabySummary(babyId: number): BabyDiaperSummary {
    return this.diaperSummaries.get(babyId) ?? { todayCount: 0, isOverdue: false };
  }

  async deleteBaby(baby: Baby) {
    const repository = await this.getBabyRepository();
    this.datasource.deleteData(baby);
    this.isEmptyData = this.datasource.totalCount() <= 0;
    await repository?.deleteBaby(baby.id);
  }

  async addBaby(name: string, year: number, month: number, day: number,
    gender: GenderType): Promise<number | null> {
    const birthday = new Date(year, month, day)
    const repository = await this.getBabyRepository();
    if (repository) {
      return await repository.addBaby(
        name,
        birthday,
        gender === GenderType.boy ? 'app.media.boy' : 'app.media.girl',
        gender === GenderType.boy ? 'boy' : 'girl'
      );
    }
    return null;
  }

  async loadBabies() {
    const repository = await this.getBabyRepository();
    if (!repository) {
      return;
    }

    const iBabies = await repository.getBabyList();
    this.isEmptyData = iBabies.length <= 0
    const babies = iBabies.map((baby) => new Baby(
      baby.id!,
      baby.name,
      baby.dateOfBirth,
      baby.image,
      baby.gender,
      baby.isArchived ?? false,
      baby.archivedAt
    ));
    this.datasource.resetData();
    this.datasource.addDataList(babies);

    // Compute diaper summaries for each baby
    this.diaperSummaries.clear();
    for (const baby of babies) {
      const summary = await repository.getBabyDiaperSummary(baby.id);
      const lastChange = summary.lastChange;
      this.diaperSummaries.set(baby.id, {
        lastChange,
        todayCount: summary.todayCount,
        isOverdue: isOverdue(lastChange, 4)
      });
    }
  }

  async quickLog(babyId: number, type: DiaperType): Promise<boolean> {
    const repository = await this.getBabyRepository();
    if (!repository) {
      return false;
    }
    const diaperType = type === DiaperType.pee ? 'pee' : 'poo';
    const result = await repository.addDiaper?.(babyId, diaperType);
    return result !== null && result !== undefined;
  }

  async loadBabyById(id: number): Promise<Baby> {
    const repository = await this.getBabyRepository();
    const iBaby = await repository?.getBabyById(id);
    if (iBaby != null) {
      return new Baby(
        iBaby!.id!,
        iBaby?.name,
        iBaby.dateOfBirth,
        iBaby.image,
        iBaby.gender,
        iBaby.isArchived ?? false,
        iBaby.archivedAt
      );
    }
    return Baby.empty();
  }

  async updateBaby(
    id: number,
    name: string,
    year: number,
    month: number,
    day: number,
    gender: GenderType,
    isArchived?: boolean | null,
    archivedAt?: Date | null,
  ): Promise<boolean> {
    const birthday = new Date(year, month, day);
    const repository = await this.getBabyRepository();
    if (!repository) {
      return false;
    }
    const result = await repository.updateBaby(
      id,
      name,
      birthday,
      gender === GenderType.boy ? 'app.media.boy' : 'app.media.girl',
      gender === GenderType.boy ? 'boy' : 'girl',
      isArchived,
      archivedAt,
    );
    return result !== null;
  }

  async getBabyDiaperSummary(babyId: number): Promise<BabyDiaperSummaryResult> {
    const repository = await this.getBabyRepository();
    if (!repository) {
      const fallback: BabyDiaperSummaryResult = { todayCount: 0 };
      return fallback;
    }
    return repository.getBabyDiaperSummary(babyId);
  }

  private async getBabyRepository(): Promise<BabyRepository | undefined> {
    if (this.babyRepository) {
      return this.babyRepository;
    }

    return await this.babyRepositoryPromise;
  }
}
