import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { BABY_TABLE } from './table/BabyTable';
import { IBaby, IDiaper } from './Interfaces';
import { DIAPER_TABLE } from './table/DiaperTable';
import { RdbResultSet, readBoolean, readDate, readOptionalDate, readOptionalString } from './table/RelationalStore';

const DATABASE_VERSION = 2;

export class Database {
  private static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'BabyDayTracker.db',
    securityLevel: relationalStore.SecurityLevel.S3
  };
  private static instance: Database;
  private _store: relationalStore.RdbStore;
  private initPromise?: Promise<void>;

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

  /** @throws */
  async init(): Promise<void> {
    if (!this.initPromise) {
      this.initPromise = this.initializeSchema();
    }

    return this.initPromise;
  }

  public async getBaby(id: number): Promise<IBaby | null> {
    try {
      const predicate = new relationalStore.RdbPredicates(BABY_TABLE.tableName).equalTo('id', id).limitAs(1);
      const resultSet = await this._store.query(predicate, BABY_TABLE.columns);
      if (!resultSet || resultSet.rowCount === 0) {
        return null;
      }
      let iBaby: IBaby | null = null;
      try {
        while (resultSet.goToNextRow()) {
          iBaby = this.mapBaby(resultSet);
        }
      } finally {
        resultSet.close();
      }
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
      if (!resultSet || resultSet.rowCount === 0) {
        return [];
      }
      const results: IBaby[] = []
      try {
        while (resultSet.goToNextRow()) {
          results.push(this.mapBaby(resultSet));
        }
      } finally {
        resultSet.close();
      }
      return results;
    } catch (err) {
      return [];
    }
  }

  public async getDiaperListByBabyId(babyId: number, isOne: boolean = false): Promise<IDiaper[]> {
    const predicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName)
    predicates.equalTo('baby_id', babyId).orderByDesc('timestamp');
    if (isOne) {
      predicates.limitAs(1)
    }
    try {
      const resultSet = await this._store.query(predicates, DIAPER_TABLE.columns);
      if (!resultSet || resultSet.rowCount === 0) {
        return [];
      }
      const results: IDiaper[] = []
      try {
        while (resultSet.goToNextRow()) {
          results.push(this.mapDiaper(resultSet, babyId));
        }
      } finally {
        resultSet.close();
      }
      return results;
    } catch (err) {
      return [];
    }
  }

  public async getDiaperListByBabyIdFiltered(babyId: number, startTime?: number, endTime?: number,
    typeFilter?: string): Promise<IDiaper[]> {
    let sql = `SELECT * FROM ${DIAPER_TABLE.tableName} WHERE baby_id = ?`;
    const args: (number | string)[] = [babyId];
    if (startTime !== undefined) {
      sql += ` AND timestamp >= ?`;
      args.push(startTime);
    }
    if (endTime !== undefined) {
      sql += ` AND timestamp <= ?`;
      args.push(endTime);
    }
    if (typeFilter !== undefined) {
      sql += ` AND type = ?`;
      args.push(typeFilter);
    }
    sql += ` ORDER BY timestamp DESC`;
    try {
      const resultSet = await this._store.querySql(sql, args);
      if (!resultSet || resultSet.rowCount === 0) {
        return [];
      }
      const results: IDiaper[] = [];
      try {
        while (resultSet.goToNextRow()) {
          results.push(this.mapDiaper(resultSet, babyId));
        }
      } finally {
        resultSet.close();
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  async insertBaby(name: string, dateOfBirth: Date, image: string, gender?: string, isArchived: boolean = false,
    archivedAt?: Date): Promise<number | null> {
    const resolvedArchivedAt = isArchived ? (archivedAt ?? new Date()) : archivedAt;
    const valueBucket: relationalStore.ValuesBucket = {
      name,
      'date_of_birth': dateOfBirth.getTime(),
      image,
      is_archived: isArchived ? 1 : 0,
      archived_at: resolvedArchivedAt ? resolvedArchivedAt.getTime() : null
    }
    if (gender !== undefined) {
      valueBucket.gender = gender;
    }
    try {
      const babyId = await this._store.insert(BABY_TABLE.tableName, valueBucket);
      if (babyId === -1) {
        throw new Error(`Baby id: ${babyId}`)
      }
      return babyId;
    } catch (_) {
      return null;
    }
  }

  async insertBabyDiaper(babyId: number, type: string, note?: string, intensity?: string, condition?: string,
    manualTimestamp?: Date): Promise<number | null> {
    const timestamp = manualTimestamp ?? new Date();

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        'baby_id': babyId,
        'timestamp': timestamp.getTime(),
        type,
        manual_timestamp: manualTimestamp ? manualTimestamp.getTime() : null
      }
      if (note !== undefined) {
        valueBucket.note = note;
      }
      if (intensity !== undefined) {
        valueBucket.intensity = intensity;
      }
      if (condition !== undefined) {
        valueBucket.condition = condition;
      }
      const diaperId = await this._store.insert(DIAPER_TABLE.tableName, valueBucket);
      if (diaperId === -1) {
        throw new Error(`Failed to insert baby diaper, id: ${diaperId}`)
      }
      return diaperId;
    } catch (_) {
      return null;
    }
  }

  async updateBaby(id: number, name: string, dateOfBirth: Date, image: string, gender?: string | null,
    isArchived?: boolean | null, archivedAt?: Date | null): Promise<number | null> {
    if (!(await this.getBaby(id))) {
      return null;
    }
    const valueBucket: relationalStore.ValuesBucket = {
      id,
      name,
      'date_of_birth': dateOfBirth.getTime(),
      image
    }
    if (gender !== undefined) {
      valueBucket.gender = gender;
    }
    if (isArchived !== undefined) {
      valueBucket.is_archived = isArchived ? 1 : 0;
      valueBucket.archived_at = isArchived ? (archivedAt?.getTime() ?? new Date().getTime()) : null;
    } else if (archivedAt !== undefined) {
      valueBucket.archived_at = archivedAt ? archivedAt.getTime() : null;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(BABY_TABLE.tableName).equalTo('id', id)
      const babyId = await this._store.update(valueBucket, predicates);
      if (babyId === -1) {
        throw new Error(`Failed to update baby, id: ${id}`);
      }
      return babyId;
    } catch (_) {
      return null;
    }
  }

  async updateDiaper(id: number, babyId: number, type: string, note?: string | null, intensity?: string | null,
    condition?: string | null, manualTimestamp?: Date | null): Promise<number | null> {
    if (!(await this.getDiaper(id))) {
      return null;
    }
    const valueBucket: relationalStore.ValuesBucket = { id, 'baby_id': babyId, type }
    if (note !== undefined) {
      valueBucket.note = note;
    }
    if (intensity !== undefined) {
      valueBucket.intensity = intensity;
    }
    if (condition !== undefined) {
      valueBucket.condition = condition;
    }
    if (manualTimestamp !== undefined) {
      valueBucket.manual_timestamp = manualTimestamp ? manualTimestamp.getTime() : null;
      if (manualTimestamp) {
        valueBucket['timestamp'] = manualTimestamp.getTime();
      }
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName).equalTo('id', id)
      const diaperId = await this._store.update(valueBucket, predicates);
      if (diaperId === -1) {
        throw new Error(`Failed to update diaper, id: ${id}`)
      }
      return diaperId;
    } catch (_) {
      return null;
    }
  }

  async deleteBaby(babyId: number): Promise<void> {
    const diaperPredicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName).equalTo('baby_id', babyId);
    const babyPredicates = new relationalStore.RdbPredicates(BABY_TABLE.tableName).equalTo('id', babyId);
    try {
      await this._store.delete(diaperPredicates);
      await this._store.delete(babyPredicates);
    } catch (_) {
    }
  }

  async deleteDiaper(diaper: IDiaper): Promise<void> {
    const diaperPredicates = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName).equalTo('id', diaper.id);
    try {
      await this._store.delete(diaperPredicates);
    } catch (_) {
    }
  }

  /** @throws */
  async onDispose(): Promise<void> {
    this._store.close();
  }

  /** @throws */
  private async initializeSchema(): Promise<void> {
    await this._store.executeSql(BABY_TABLE.createQuery);
    await this._store.executeSql(DIAPER_TABLE.createQuery);

    if (this._store.version < DATABASE_VERSION) {
      await this.applyAdditiveMigrations(this._store.version);
    }
  }

  private async applyAdditiveMigrations(currentVersion: number): Promise<void> {
    if (currentVersion < 2) {
      await this.addColumnIfMissing(BABY_TABLE.tableName, 'gender', 'gender TEXT NULL');
      await this.addColumnIfMissing(BABY_TABLE.tableName, 'is_archived', 'is_archived INTEGER NOT NULL DEFAULT 0');
      await this.addColumnIfMissing(BABY_TABLE.tableName, 'archived_at', 'archived_at INTEGER NULL');
      await this.addColumnIfMissing(DIAPER_TABLE.tableName, 'note', 'note TEXT NULL');
      await this.addColumnIfMissing(DIAPER_TABLE.tableName, 'intensity', 'intensity TEXT NULL');
      await this.addColumnIfMissing(DIAPER_TABLE.tableName, 'condition', 'condition TEXT NULL');
      await this.addColumnIfMissing(DIAPER_TABLE.tableName, 'manual_timestamp', 'manual_timestamp INTEGER NULL');
    }
  }

  private async addColumnIfMissing(tableName: string, columnName: string, columnDefinition: string): Promise<void> {
    if (await this.hasColumn(tableName, columnName)) {
      return;
    }
    await this._store.executeSql(`ALTER TABLE ${tableName} ADD COLUMN ${columnDefinition}`);
  }

  private async hasColumn(tableName: string, columnName: string): Promise<boolean> {
    const resultSet = await this._store.querySql(`PRAGMA table_info(${tableName})`);
    try {
      while (resultSet.goToNextRow()) {
        const name = resultSet.getString(resultSet.getColumnIndex('name'));
        if (name === columnName) {
          return true;
        }
      }
      return false;
    } finally {
      resultSet.close();
    }
  }

  private mapBaby(resultSet: RdbResultSet): IBaby {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      dateOfBirth: readDate(resultSet, 'date_of_birth'),
      image: resultSet.getString(resultSet.getColumnIndex('image')),
      gender: readOptionalString(resultSet, 'gender'),
      isArchived: readBoolean(resultSet, 'is_archived'),
      archivedAt: readOptionalDate(resultSet, 'archived_at')
    };
  }

  private mapDiaper(resultSet: RdbResultSet, babyId: number): IDiaper {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      babyId,
      type: resultSet.getString(resultSet.getColumnIndex('type')),
      timestamp: readDate(resultSet, 'timestamp'),
      note: readOptionalString(resultSet, 'note'),
      intensity: readOptionalString(resultSet, 'intensity'),
      condition: readOptionalString(resultSet, 'condition'),
      manualTimestamp: readOptionalDate(resultSet, 'manual_timestamp')
    };
  }

  private async getDiaper(id: number): Promise<IDiaper | null> {
    try {
      const predicate = new relationalStore.RdbPredicates(DIAPER_TABLE.tableName).equalTo('id', id).limitAs(1);
      const resultSet = await this._store.query(predicate, DIAPER_TABLE.columns);
      if (!resultSet || resultSet.rowCount === 0) {
        return null;
      }
      let iDiaper: IDiaper | null = null;
      try {
        while (resultSet.goToNextRow()) {
          iDiaper = this.mapDiaper(resultSet, resultSet.getLong(resultSet.getColumnIndex('baby_id')));
        }
      } finally {
        resultSet.close();
      }
      return iDiaper;
    } catch (_) {
      return null;
    }
  }
}