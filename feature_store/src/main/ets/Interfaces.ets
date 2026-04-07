export interface IBaby {
  id?: number;
  name: string;
  dateOfBirth: Date;
  image: string;
  gender?: string;
  isArchived?: boolean;
  archivedAt?: Date;
}

export interface IDiaper {
  id: number;
  babyId: number;
  type: string;
  timestamp: Date;
  note?: string;
  intensity?: string;
  condition?: string;
  manualTimestamp?: Date;
}
