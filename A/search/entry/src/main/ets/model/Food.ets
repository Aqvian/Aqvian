

export interface IValueBucket {
  id: number; // 唯一ID
  name: string; // 食物名称
  calories: number; // 卡路里
  protein: number; // 蛋白质（克）
  fat: number; // 脂肪（克）
  carbohydrates: number; // 碳水化合物（克）
  fiber: number; // 纤维（克）
  vitamin: string; // 维生素信息
  minerals: string; // 矿物质信息
  quantity: number; // 食物的数量（单位：克）
}

@Sendable
export class SharedValuesBucket implements IValueBucket {
  id: number=0// 唯一ID
  name: string=''; // 食物名称
  calories: number=0; // 卡路里
  protein: number=0; // 蛋白质（克）
  fat: number=0; // 脂肪（克）
  carbohydrates: number=0; // 碳水化合物（克）
  fiber: number=0; // 纤维（克）
  vitamin: string='无'; // 维生素信息
  minerals: string='无'; // 矿物质信息
  quantity: number=100; // 食物的数量（单位：克）
  constructor(v: IValueBucket) {
    this.id = v.id;
    this.name = v.name;
    this.calories = v.calories;
    this.protein = v.protein
    this.fat = v.fat;
    this.carbohydrates = v.carbohydrates;
    this.fiber = v.fiber;
    this.vitamin = v.vitamin
    this.minerals = v.minerals;
    this.quantity = v.quantity;
  }
}

