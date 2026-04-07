import { RDBTable } from './RDBTable';

export const DIAPER_TABLE: RDBTable = {
  tableName: 'Diaper',
  createQuery: `CREATE TABLE IF NOT EXISTS Diaper (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL,
      type TEXT NULL,
      timestamp INTEGER NOT NULL,
      note TEXT NULL,
      intensity TEXT NULL,
      condition TEXT NULL,
      manual_timestamp INTEGER NULL,
      FOREIGN KEY (baby_id) REFERENCES Baby(id)
    );`,
  columns: ['id', 'baby_id', 'type', 'timestamp', 'note', 'intensity', 'condition', 'manual_timestamp']
};
