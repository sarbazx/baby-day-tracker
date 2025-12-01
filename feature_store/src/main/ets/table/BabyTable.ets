import { RDBTable } from './RDBTable';

export const BABY_TABLE: RDBTable = {
  tableName: 'Baby',
  createQuery: `CREATE TABLE IF NOT EXISTS Baby (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date_of_birth INTEGER NULL,
      image TEXT NULL
    );`,
  columns: ['id', 'name', 'date_of_birth', 'image']
};