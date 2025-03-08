import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class SavedFilter {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: string;

  @Column('json')
  filters: Record<string, any>;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
} 