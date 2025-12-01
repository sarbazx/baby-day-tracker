import { formatDate } from "../lib/date-utils";

export enum DiaperType {
  pee,
  poo
}

export class Diaper {
  private _id?: number;
  private _babyId: number;
  private _type: DiaperType;
  private _timestamp: Date;

  constructor(babyId: number, type: DiaperType = DiaperType.pee, id?: number, timestamp?: Date) {
    this._id = id;
    this._babyId = babyId;
    this._type = type;
    this._timestamp = timestamp ?? new Date();
  }

  get type(): DiaperType {
    return this._type;
  }

  get id(): number | undefined {
    return this._id;
  }

  get babyId(): number {
    return this._babyId;
  }

  get date(): string {
    return formatDate(this._timestamp);
  }
}