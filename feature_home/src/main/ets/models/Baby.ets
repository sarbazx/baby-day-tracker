import { formatAge } from '../lib/date-utils';

export class Baby {
  private _id: number;
  private _name: string;
  private _dateOfBirth: Date;
  private _image?: Resource;

  constructor(id: number, name: string, birth: Date, image: string) {
    this._name = name;
    this._dateOfBirth = birth;
    this._image = $r(image);
    this._id = id;
  }

  static empty(): Baby {
    return new Baby(-1, 'Empty', new Date(), '')
  }

  get name(): string {
    return `${this._name.charAt(0).toUpperCase()}${this._name.slice(1)}`
  }

  set name(name: string) {
    this._name = name;
  }

  get id(): number {
    return this._id;
  }

  get image(): Resource {
    return this._image ?? $r('sys.media.car_fill');
  }

  set image(value: Resource) {
    this._image = value;
  }

  get birthday(): string {
    return formatAge(this._dateOfBirth.getTime())
  }

}