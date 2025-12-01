import { Database, GlobalContext } from 'feature_store';
import { IBaby } from 'feature_store/src/main/ets/Interfaces';
import { GenderType } from '../components/GenderSelect';
import { Baby } from '../models/Baby';
import ListDataSource from './ListDataSource';

@Observed
export default class BabyViewModel {
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
  datasource: ListDataSource<Baby> = new ListDataSource<Baby>();

  async deleteBaby(baby: Baby) {
    this.datasource.deleteData(baby);
    this.isEmptyData = this.datasource.totalCount() <= 0;
    await this.appDatabase?.deleteBaby(baby.id);
  }

  async addBaby(name: string, year: number, month: number, day: number,
    gender: GenderType): Promise<number | null> {
    const birthday = new Date(year, month, day)
    const baby: IBaby = {
      name,
      dateOfBirth: birthday,
      image: gender === GenderType.boy ? 'app.media.boy' : 'app.media.girl'
    }
    if (this.appDatabase) {
      return await this.appDatabase.insertBaby(baby.name, baby.dateOfBirth, baby.image);
    }
    return null;
  }

  async loadBabies() {
    if (!this.appDatabase) {
      return;
    }

    const iBabies = await this.appDatabase.getBabyList();
    this.isEmptyData = iBabies.length <= 0
    const babies = iBabies.map((baby) => new Baby(baby.id!, baby.name, baby.dateOfBirth, baby.image));
    this.datasource.resetData();
    this.datasource.addDataList(babies);
  }

  async loadBabyById(id: number): Promise<Baby> {
    const iBaby = await this.appDatabase?.getBaby(id);
    if (iBaby != null) {
      return new Baby(iBaby!.id!, iBaby?.name, iBaby.dateOfBirth, iBaby.image);
    }
    return Baby.empty();
  }
}