export interface IBaby {
  id?: number;
  name: string;
  dateOfBirth: Date;
  image: string;
}

export interface IDiaper {
  id: number;
  babyId: number;
  type: string;
  timestamp: Date;
}