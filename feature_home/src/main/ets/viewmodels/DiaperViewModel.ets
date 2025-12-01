import { Database, GlobalContext } from 'feature_store';
import { Diaper, DiaperType } from '../models/Diaper';
import ListDataSource from './ListDataSource';

@Observed
export default class DiaperViewModel {
  private appDatabase?: Database;

  constructor() {
    const context = GlobalContext.getInstance().getSavedContext();
    if (context) {
      Database.getInstance(context).then((database) => {
        this.appDatabase = database;
      })
    }
  }

  @Track
  isEmptyData: boolean = true;
  @Track
  datasource: ListDataSource<Diaper> = new ListDataSource<Diaper>();

  async addDiaper(id: number, type: DiaperType = DiaperType.pee): Promise<boolean> {
    const diaperType = type === DiaperType.pee ? 'pee' : 'poo';
    const babyId = parseInt(`${id}`);
    const result = await this.appDatabase?.insertBabyDiaper(babyId, diaperType);

    if (result) {
      return true;
    }
    return false;
  }

  async loadLatestDiaper(id: number): Promise<Diaper | null> {
    const babyId = parseInt(`${id}`);
    const iDiapers = await this.appDatabase?.getDiaperListByBabyId(babyId, true);
    if (iDiapers && iDiapers.length > 0) {
      const type = iDiapers[0].type === 'pee' ? DiaperType.pee : DiaperType.poo;
      return new Diaper(iDiapers[0].babyId, type, iDiapers[0].id, iDiapers[0].timestamp)
    }
    return null;
  }

  async loadDiapers(id: number): Promise<Diaper[]> {
    const babyId = parseInt(`${id}`);
    const iDiapers = await this.appDatabase?.getDiaperListByBabyId(babyId);
    return (iDiapers ?? []).map((diaper) => {
      const type = diaper.type === 'pee' ? DiaperType.pee : DiaperType.poo;
      return new Diaper(diaper.babyId, type, diaper.id, diaper.timestamp);
    });
  }
}