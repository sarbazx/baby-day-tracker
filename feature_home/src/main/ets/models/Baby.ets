import { formatAge } from '../lib/date-utils';

export class Baby {
  constructor(id: number, name: string, birth: Date, image: string, gender?: string, isArchived: boolean = false,
    archivedAt?: Date) {
    this._name = name;
    this._dateOfBirth = birth;
    this._image = $r(image);
    this._id = id;
    this._gender = gender;
    this._isArchived = isArchived;
    this._archivedAt = archivedAt;
  }

  private _id: number;

  get id(): number {
    return this._id;
  }

  private _name: string;

  get name(): string {
    return `${this._name.charAt(0).toUpperCase()}${this._name.slice(1)}`
  }

  set name(name: string) {
    this._name = name;
  }

  private _dateOfBirth: Date;

  get dateOfBirth(): Date {
    return this._dateOfBirth;
  }

  private _image?: Resource;

  get image(): Resource {
    return this._image ?? $r('sys.media.car_fill');
  }

  set image(value: Resource) {
    this._image = value;
  }

  private _gender?: string;

  get gender(): string | undefined {
    return this._gender;
  }

  private _isArchived: boolean;

  get isArchived(): boolean {
    return this._isArchived;
  }

  private _archivedAt?: Date;

  get archivedAt(): Date | undefined {
    return this._archivedAt;
  }

  get isEmpty(): boolean {
    return this._id === -1;
  }

  get birthday(): string {
    return formatAge(this._dateOfBirth.getTime())
  }

  static empty(): Baby {
    return new Baby(-1, 'Empty', new Date(), '')
  }
}
