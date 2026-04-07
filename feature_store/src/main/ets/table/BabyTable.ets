import { RDBTable } from './RDBTable';

export const BABY_TABLE: RDBTable = {
  tableName: 'Baby',
  createQuery: `CREATE TABLE IF NOT EXISTS Baby (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date_of_birth INTEGER NULL,
      image TEXT NULL,
      gender TEXT NULL,
      is_archived INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER NULL
    );`,
  columns: ['id', 'name', 'date_of_birth', 'image', 'gender', 'is_archived', 'archived_at']
};
