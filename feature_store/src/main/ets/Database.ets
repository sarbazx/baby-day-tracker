import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { BABY_TABLE } from './table/BabyTable';
import { IBaby, IDiaper } from './Interfaces';
import { DIAPER_TABLE } from './table/DiaperTable';

export class Database {
  private static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'BabyDayTracker.db',
    securityLevel: relationalStore.SecurityLevel.S3
  };
  private static instance: Database;
  private _store: relationalStore.RdbStore;

  constructor(store: relationalStore.RdbStore) {
    this._store = store;
  }

  public static async getInstance(context: Context): Promise<Database> {
    if (!Database.instance) {
      try {
        const store = await relationalStore.getRdbStore(context, Database.STORE_CONFIG);
        Database.instance = new Database(store);
      } catch (err) {
        throw Error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
      }
    }

    return Database.instance;
  }

  /**
   * @throws
   */
  async init() {
    if (this._store.version === 0) {
      await this._store.executeSql(BABY_TABLE.createQuery);
      await this._store.executeSql(DIAPER_TABLE.createQuery);
    }
  }

  public async getBaby(id: number): Promise<IBaby | null> {
    try {
      const predicate = new relationalStore.RdbPredicates(BABY_TABLE.tableName)
        .equalTo('id', id)
        .limitAs(1);
      const resultSet = await this._store.query(predicate, BABY_TABLE.columns);
      if (!resultSet || resultSet.rowCount == 0) {
        return null;
      }
      let iBaby: IBaby | null = null;
      let dateOfBirth = new Date();
      while (resultSet.goToNextRow()) {
        const dbDate = resultSet.getColumnIndex('date_of_birth');
        dateOfBirth.setTime(resultSet.getLong(dbDate) * 1000);
        iBaby = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          dateOfBirth,
          image: resultSet.getString(resultSet.getColumnIndex('image')),
        };
      }
      resultSet.close()
      return iBaby;
    } catch (error) {
      console.error(`Error ${error.code} ${error.message}`);
      return null;
    }
  }

  public async getBabyList(): Promise<IBaby[]> {
    const predicates = new relationalStore.RdbPredicates(BABY_TABLE.tableName);
    predicates.orderByDesc('id');
    try {
      const resultSet = await this._store.query(predicates, BABY_TABLE.columns);
      if (!resultSet || resultSet.rowCount == 0) {
        return [];
      }

      const results: IBaby[] = []

      let dateOfBirth = new Date();

      while (resultSet.goToNextRow()) {
        const dbDate = resultSet.getColumnIndex('date_of_birth');
        dateOfBirth.setTime(resultSet.getLong(dbDate) * 1000);
        const image = resultSet.getString(resultSet.getColumnIndex('image'));
        const name = resultSet.getString(resultSet.getColumnIndex('name'));
        const id = resultSet.getLong(resultSet.getColumnIndex('id'));
        const baby: IBaby = {
          id,
          name,
          dateOfBirth,
          image,
        };
        results.push(baby);
      }
      resultSet.close();
      return results;

    } catch (err) {
      return [];
    }
  }

  public async getDiaperListByBabyId(babyId: number, isOne: boolean = false): Promise<IDiaper[]> {
    const predicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName)
    predicates
      .equalTo('baby_id', babyId)
      .orderByDesc('timestamp');

    if (isOne) {
      predicates.limitAs(1)
    }

    try {
      const resultSet = await this._store.query(predicates, DIAPER_TABLE.columns);
      if (!resultSet || resultSet.rowCount == 0) {
        return [];
      }

      const results: IDiaper[] = []
      const timestamp = new Date();

      while (resultSet.goToNextRow()) {
        const timestampDb = resultSet.getLong(resultSet.getColumnIndex('timestamp'));
        timestamp.setTime(timestampDb);
        const type = resultSet.getString(resultSet.getColumnIndex('type'));
        const id = resultSet.getLong(resultSet.getColumnIndex('id'));

        const diaper: IDiaper = {
          id,
          type,
          timestamp,
          babyId
        };
        results.push(diaper);
      }
      resultSet.close();
      return results;

    } catch (err) {
      return [];
    }
  }

  async insertBaby(
    name: string,
    dateOfBirth: Date,
    image: string,
  ): Promise<number | null> {
    const valueBucket: relationalStore.ValuesBucket = {
      name,
      'date_of_birth': dateOfBirth.getTime(),
      image,
    }
    try {
      const babyId = await this._store.insert(BABY_TABLE.tableName, valueBucket);
      if (babyId === -1) {
        throw new Error(`Baby id: ${babyId}`)
      }
      return babyId;
    } catch (err) {
      console.error(`[BabyDayTracker] Failed to insert baby ${err}`)
      return null;
    }
  }

  async insertBabyDiaper(
    babyId: number,
    type: string,
  ): Promise<number | null> {

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        'baby_id': babyId,
        'timestamp': Date.now(),
        type,
      }
      const diaperId = await this._store.insert(DIAPER_TABLE.tableName, valueBucket);
      if (diaperId === -1) {
        throw new Error(`Failed to insert baby diaper, id: ${diaperId}`)
      }
      return diaperId;
    } catch (err) {
      console.error(`[BabyDayTracker] Failed to insert baby diaper ${err}`)
      return null;
    }
  }

  async updateBaby(
    id: number,
    name: string,
    dateOfBirth: Date,
    image: string,
  ): Promise<number | null> {
    const valueBucket: relationalStore.ValuesBucket = {
      id,
      name,
      'date_of_birth': dateOfBirth.getTime(),
      image,
    }

    try {
      const predicates = new relationalStore.RdbPredicates(BABY_TABLE.tableName)
        .equalTo('id', id)
      const babyId = await this._store.update(valueBucket, predicates);
      if (babyId === -1) {
        throw new Error(`Failed to insert baby, id: ${babyId}`)
      }
      return babyId;
    } catch (err) {
      console.error(`[BabyDayTracker] Failed to update baby ${err}`)
      return null;
    }
  }

  async updateDiaper(
    id: number,
    babyId: number,
    type: string,
  ): Promise<number | null> {
    const valueBucket: relationalStore.ValuesBucket = {
      id,
      'baby_id': babyId,
      'timestamp': Date.now(),
      type,
    }

    try {
      const predicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName)
        .equalTo('id', id)
      const diaperId = await this._store.update(valueBucket, predicates);
      if (diaperId === -1) {
        throw new Error(`Failed to insert baby, id: ${diaperId}`)
      }
      return diaperId;
    } catch (err) {
      console.error(`[BabyDayTracker] Failed to update diaper ${err}`)
      return null;
    }
  }

  async deleteBaby(babyId: number): Promise<void> {
    const diaperPredicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName)
      .equalTo('baby_id', babyId);
    const babyPredicates = new relationalStore.RdbPredicates(BABY_TABLE.tableName)
      .equalTo('id', babyId);
    try {
      await this._store.delete(diaperPredicates);
      await this._store.delete(babyPredicates);
    } catch (err) {
      console.error(`[BabyDayTracker] Failed to delete Baby ${err}`)
    }
  }

  async deleteDiaper(diaper: IDiaper): Promise<void> {
    const diaperPredicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName)
      .equalTo('id', diaper.id);
    try {
      await this._store.delete(diaperPredicates);
    } catch (err) {
      console.error(`[BabyDayTracker] Failed to delete diaper ${err}`)
    }
  }

  /**
   * @throws
   */
  async onDispose(): Promise<void> {
    this._store.close();
  }
}