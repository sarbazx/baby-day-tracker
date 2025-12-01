import { RDBTable } from './RDBTable';

export const DIAPER_TABLE: RDBTable = {
  tableName: 'Diaper',
  createQuery: `CREATE TABLE IF NOT EXISTS Diaper (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL,
      type TEXT NULL,
      timestamp INTEGER NOT NULL,
      FOREIGN KEY (baby_id) REFERENCES Baby(id)
    );`,
  columns: ['id', 'baby_id', 'type', 'timestamp']
};