import { DiaperRepository, GlobalContext } from 'feature_store';
import { Diaper, DiaperType } from '../models/Diaper';
import ListDataSource from './ListDataSource';

@Observed
export default class DiaperViewModel {
  @Track
  isEmptyData: boolean = true;
  @Track
  datasource: ListDataSource<Diaper> = new ListDataSource<Diaper>();
  private diaperRepository?: DiaperRepository;
  private diaperRepositoryPromise?: Promise<DiaperRepository>;

  constructor() {
    const context = GlobalContext.getInstance().getSavedContext();
    if (context) {
      this.diaperRepositoryPromise = DiaperRepository.getInstance(context).then((repository) => {
        this.diaperRepository = repository;
        return repository;
      })
    }
  }

  async getDiaperRepository(): Promise<DiaperRepository | undefined> {
    if (this.diaperRepository) {
      return this.diaperRepository;
    }
    return await this.diaperRepositoryPromise;
  }

  async deleteDiaperById(diaperId: number): Promise<void> {
    const repository = await this.getDiaperRepository();
    if (repository) {
      await repository.deleteDiaper({
        id: diaperId,
        babyId: 0,
        type: '',
        timestamp: new Date()
      });
    }
  }

  async addDiaper(
    id: number,
    type: DiaperType = DiaperType.pee,
    note?: string,
    intensity?: string,
    condition?: string,
    manualTimestamp?: Date,
  ): Promise<boolean> {
    const repository = await this.getDiaperRepository();
    if (!repository) {
      return false;
    }

    const diaperType = type === DiaperType.pee ? 'pee' : 'poo';
    const babyId = parseInt(`${id}`);
    const result = await repository.addDiaper(babyId, diaperType, note, intensity, condition, manualTimestamp);

    return result !== null;
  }

  async loadDiapers(id: number) {
    const repository = await this.getDiaperRepository();
    if (!repository) {
      return;
    }

    const babyId = parseInt(`${id}`);
    const iDiapers = await repository.getDiaperListByBabyId(babyId);
    this.datasource.resetData();
    (iDiapers ?? []).forEach((diaper) => {
      const type = diaper.type === 'pee' ? DiaperType.pee : DiaperType.poo;
      const iDiaper = new Diaper(
        diaper.babyId,
        type,
        diaper.id,
        diaper.timestamp,
        diaper.note,
        diaper.intensity,
        diaper.condition,
        diaper.manualTimestamp
      );
      this.datasource.pushData(iDiaper);
    });
  }
}
