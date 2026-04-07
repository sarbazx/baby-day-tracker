import { relationalStore } from '@kit.ArkData';

export type RdbResultSet = relationalStore.ResultSet;

export function readDate(resultSet: RdbResultSet, columnName: string): Date {
  try {
    const value = resultSet.getLong(resultSet.getColumnIndex(columnName));
    const date = new Date();
    date.setTime(value);
    return date;
  } catch (error) {
    console.error(`[readDate] ${error.code} ${error.message}`)
  }

  return new Date();
}

export function readOptionalDate(resultSet: RdbResultSet, columnName: string): Date | undefined {
  try {
    const value = resultSet.getLong(resultSet.getColumnIndex(columnName));
    if (value <= 0) {
      return undefined;
    }
    const date = new Date();
    date.setTime(value);
    return date;
  } catch (error) {
    console.error(`[readDate] ${error.code} ${error.message}`)
  }
  return undefined;
}

export function readOptionalString(resultSet: RdbResultSet, columnName: string): string | undefined {
  try {
    const value = resultSet.getString(resultSet.getColumnIndex(columnName));
    return value ? value : undefined;
  } catch (error) {
    console.error(`[readDate] ${error.code} ${error.message}`)
  }
  return undefined;
}

export function readBoolean(resultSet: RdbResultSet, columnName: string): boolean {
  try {
    return resultSet.getLong(resultSet.getColumnIndex(columnName)) !== 0;
  } catch (error) {
    console.error(`[readDate] ${error.code} ${error.message}`)
  }
  return false;
}