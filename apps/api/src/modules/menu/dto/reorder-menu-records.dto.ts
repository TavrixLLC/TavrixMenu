import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsInt,
  IsNotEmpty,
  IsString,
  Min,
  ValidateNested
} from 'class-validator';

export class ReorderMenuRecordDto {
  @ApiProperty({ example: 'cat_123' })
  @IsString()
  @IsNotEmpty()
  id: string;

  @ApiProperty({ example: 0, minimum: 0 })
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder: number;
}

export class ReorderMenuRecordsDto {
  @ApiProperty({
    type: [ReorderMenuRecordDto],
    example: [
      {
        id: 'cat_123',
        sortOrder: 0
      },
      {
        id: 'cat_456',
        sortOrder: 1
      }
    ]
  })
  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => ReorderMenuRecordDto)
  orders: ReorderMenuRecordDto[];
}
