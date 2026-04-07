import { formatDate } from '../lib/date-utils';

export enum DiaperType {
  pee,
  poo
}

export enum DiaperIntensity {
  MILD = 'mild',
  MODERATE = 'moderate',
  HEAVY = 'heavy'
}

export enum DiaperCondition {
  NORMAL = 'normal',
  LOOSE = 'loose',
  WATERY = 'watery',
  CONSTIPATED = 'constipated'
}

export class Diaper {
  constructor(
    babyId: number,
    type: DiaperType = DiaperType.pee,
    id?: number,
    timestamp?: Date,
    note?: string,
    intensity?: string,
    condition?: string,
    manualTimestamp?: Date,
  ) {
    this._id = id;
    this._babyId = babyId;
    this._type = type;
    this._timestamp = timestamp ?? new Date();
    this._note = note;
    this._intensity = intensity;
    this._condition = condition;
    this._manualTimestamp = manualTimestamp;
  }

  private _id?: number;

  get id(): number | undefined {
    return this._id;
  }

  private _babyId: number;

  get babyId(): number {
    return this._babyId;
  }

  private _type: DiaperType;

  get type(): DiaperType {
    return this._type;
  }

  private _timestamp: Date;

  get timestamp(): Date {
    return this._timestamp;
  }

  private _note?: string;

  get note(): string | undefined {
    return this._note;
  }

  private _intensity?: string;

  get intensity(): string | undefined {
    return this._intensity;
  }

  private _condition?: string;

  get condition(): string | undefined {
    return this._condition;
  }

  private _manualTimestamp?: Date;

  get manualTimestamp(): Date | undefined {
    return this._manualTimestamp;
  }

  get date(): string {
    return formatDate(this._timestamp);
  }
}
