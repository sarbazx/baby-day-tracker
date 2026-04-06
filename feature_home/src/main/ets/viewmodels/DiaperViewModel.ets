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

  async loadDiapers(id: number) {
    const babyId = parseInt(`${id}`);
    const iDiapers = await this.appDatabase?.getDiaperListByBabyId(babyId);
    (iDiapers ?? []).forEach((diaper) => {
      const type = diaper.type === 'pee' ? DiaperType.pee : DiaperType.poo;
      const iDiaper = new Diaper(diaper.babyId, type, diaper.id, diaper.timestamp);
      this.datasource.pushData(iDiaper);
    });
  }
}