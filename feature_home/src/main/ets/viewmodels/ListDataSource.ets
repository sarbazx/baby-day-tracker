export default class ListDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private dataArray: T[] = [];

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): T {
    return this.dataArray[index];
  }

  public deleteData(item: T): void {
    const index = this.dataArray.indexOf(item);
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public addDataList(data: T[]): void {
    this.dataArray.push(...data);
    this.notifyDataReload();
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  public resetData() {
    this.dataArray = [];
  }

  public pushData(data: T): void {
    this.dataArray.push(data);
    let index = this.dataArray.length - 1;
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }
}