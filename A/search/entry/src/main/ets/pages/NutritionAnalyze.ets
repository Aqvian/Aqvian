import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { collections, JSON } from '@kit.ArkTS';
import { IValueBucket, SharedValuesBucket } from '../model/Food';
import { promptAction } from '@kit.ArkUI'
import { EditableLeftIconType, EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar'
import{BarChart,BarChartModel,JArrayList, BarData,BarDataSet,IBarDataSet,BarEntry} from '@ohos/mpchart'


interface FIngredient {
  name: string;  // 食材名称
  weight: number;  // 食材数量（单位：克、个等）
}
// 创建数据库表
async function create(context: Context) {
  const CONFIG: relationalStore.StoreConfig = {
    name: "Store.db",
    securityLevel: relationalStore.SecurityLevel.S1,
  };

  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, CONFIG);
  console.info(`Create Store.db successfully!`);

  // 创建新的表结构，包含更多的字段
  const CREATE_TABLE_SQL = "CREATE TABLE IF NOT EXISTS test (" +
    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
    "name TEXT NOT NULL, " +
    "calories INTEGER, " +
    "protein REAL, " +
    "fat REAL, " +
    "carbohydrates REAL, " +
    "fiber REAL, " +
    "vitamin TEXT, " +
    "minerals TEXT, " +
    "quantity INTEGER, " +
    "isSelected INTEGER)";

  await store.executeSql(CREATE_TABLE_SQL);
  console.info(`Create table test successfully!`);
}
// 数据插入
async function insert(context: Context, valueBucketArray: collections.Array<SharedValuesBucket | undefined>) {
  const CONFIG: relationalStore.StoreConfig = {
    name: "Store.db",
    securityLevel: relationalStore.SecurityLevel.S1,
  };

  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, CONFIG);
  console.info(`Create Store.db successfully!`);

  // 数据插入
  await store.batchInsert("test", valueBucketArray as Object as Array<ValuesBucket>);
}
// 查询数据
async function query(context: Context,value:string): Promise<collections.Array<SharedValuesBucket | undefined>> {
  const CONFIG: relationalStore.StoreConfig = {
    name: "Store.db",
    securityLevel: relationalStore.SecurityLevel.S1,
  };

  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, CONFIG);
  console.info(`insert Store.db successfully!`);

  // 获取结果集
  let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates("test").like('name',value);
  let resultSet = await store.query(predicates);
  console.info(`Query data successfully! row count: ${resultSet.rowCount}`);

  let index = 0;
  let result = collections.Array.create<SharedValuesBucket | undefined>(resultSet.rowCount, undefined);
  resultSet.goToFirstRow();

  do {
    let v: IValueBucket = {
      id: resultSet.getLong(resultSet.getColumnIndex("id")),
      name: resultSet.getString(resultSet.getColumnIndex("name")),
      calories: resultSet.getLong(resultSet.getColumnIndex("calories")),
      protein: resultSet.getDouble(resultSet.getColumnIndex("protein")),
      fat: resultSet.getDouble(resultSet.getColumnIndex("fat")),
      carbohydrates: resultSet.getDouble(resultSet.getColumnIndex("carbohydrates")),
      fiber: resultSet.getDouble(resultSet.getColumnIndex("fiber")),
      vitamin: resultSet.getString(resultSet.getColumnIndex("vitamin")),
      minerals: resultSet.getString(resultSet.getColumnIndex("minerals")),
      quantity: resultSet.getLong(resultSet.getColumnIndex("quantity")),
    };

    result[index++] = new SharedValuesBucket(v);
  } while (resultSet.goToNextRow());

  resultSet.close();
  return result;
}
// 清理数据库
async function clear(context: Context) {
  const CONFIG: relationalStore.StoreConfig = {
    name: "Store.db",
    securityLevel: relationalStore.SecurityLevel.S1,
  };

  // 默认数据库文件路径为 context.databaseDir + rdb + StoreConfig.name
  await relationalStore.deleteRdbStore(context, CONFIG);
  console.info(`Delete Store.db successfully!`);
}
@CustomDialog
struct FoodDetail {
  @State FoodID: number=1; // 唯一ID
  @State name: string=''; // 食物名称
  @State calories: number=1; // 卡路里
  @State protein: number=1; // 蛋白质（克）
  @State fat: number=1; // 脂肪（克）
  @State carbohydrates: number=1; // 碳水化合物（克）
  @State fiber: number=1; // 纤维（克）
  @State vitamin: string=''; // 维生素信息
  @State minerals: string=''; // 矿物质信息
  @State quantity: number=1; // 食物的数量（单位：克）
  controller?: CustomDialogController
  build() {
    Column() {
      // 编辑界面顶部导航栏
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Cancel,
        isSaveIconRequired:false,
        title: this.name,
        menuItems: [],
        onCancel: () => {
          this.controller?.close()
        },
      })
        .height(80)
        .backgroundColor('#F3F4F6')// 浅灰色背景
        .padding({ left: 0, right: 0 })
      Column(){
        Text('卡路里：'+`${this.calories}`+ 'CAL/100g')
        Text('蛋白质：'+`${this.protein}`+'g/100g')
        Text('脂肪：'+`${this.fat}`+'g/100g')
        Text('碳水化合物：'+`${this.carbohydrates}`+'g/100g')
        Text('膳食纤维：'+`${this.fiber}`+'g/100g')
        Text('维他命：'+`${this.vitamin}`)
        Text('矿物质：'+`${this.minerals}`)
        Text('质量'+`${this.quantity}`+'g')
      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}//食物详细信息
@CustomDialog
//获取食物克重
struct Input {
  @Link weight:number
  @Link Foodall:FoodAll
  @Link item:object
  @Link Foodlist:FIngredient[]
  DrawBarChart: ()=>void = ()=>{}
  AddToList: (name:string,weight:number)=>void = ()=>{}
  controller?: CustomDialogController
  build() {
    Column() {
      // 编辑界面顶部导航栏
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Cancel,
        isSaveIconRequired:false,
        title: '请输入质量',
        menuItems: [],
        onCancel: () => {
          this.controller?.close()
        },
        onSave:()=>{
          const parsedValue = parseInt(this.weight.toString(), 10);
          // 判断是否是有效的数字
          if (!isNaN(parsedValue)) {
            // 如果是有效数字，更新 weight
            this.weight = parsedValue;
          } else {
            // 如果输入无效，可以弹出提示或设置默认值
            this.weight = 0;  // 默认值为0，或根据需求调整
            promptAction.showToast({ message: '请输入有效的数字' });  // 弹出提示框提醒用户输入有效的数字
          }
          this.Foodall.calories += this.item['calories'] * this.weight / 100;
          this.Foodall.protein += this.item['protein'] * this.weight / 100;
          this.Foodall.fat += this.item['fat'] * this.weight / 100;
          this.Foodall.carbohydrates += this.item['carbohydrates'] * this.weight / 100;
          this.DrawBarChart();
          this.AddToList(this.item['name'],this.weight)
          this.weight=0
          this.controller?.close()
        }
      })
        .height(80)
        .backgroundColor('#F3F4F6')// 浅灰色背景
        .padding({ left: 0, right: 0 })
      Column(){
        TextInput({ placeholder: '请输入质量', text: $$this.weight })

      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}//食物详细信息

interface FoodAll{
  calories:number
  protein:number
  fat:number
  carbohydrates:number
}

@Entry
@Component
export struct rbd {
  @State message: string = 'Hello World';
  @State queryResult: string = "[\n" +
    "  {\n" +
    "    \"id\": 0,\n" +
    "    \"name\": \"Food0\",\n" +
    "    \"calories\": 200,\n" +
    "    \"protein\": 5,\n" +
    "    \"fat\": 10,\n" +
    "    \"carbohydrates\": 40,\n" +
    "    \"fiber\": 5,\n" +
    "    \"vitamin\": \"Vitamin A\",\n" +
    "    \"minerals\": \"Iron\",\n" +
    "    \"quantity\": 100\n" +
    "  }\n" +
    "]\n"

  @State weight:number =0
  @State foodTitle: string = ''
  @State model:BarChartModel = new BarChartModel()
  @State itemt:object = []
  @State selectedtype:number = 0 //根据类别设置推荐值 0:male 1:female
  @State selectedplan:number = 0 //根据类别设置计划 0：维持 1：减脂 2：增肌
  @State inputweight:number = 60
  @State Foodall:FoodAll = {
    calories:0,
    protein:0,
    fat:0,
    carbohydrates:0
  }
  @State Foodlist:FIngredient[] =[]


  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  @Builder TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top:0, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .color('#007DFF')
        .opacity(this.currentIndex === index ? 1 : 0)
    }.width('100%')
  }


  async aboutToAppear(): Promise<void> {
    let context = getContext(this);
    // 数据准备
    let valueBucketArray = collections.Array.create<SharedValuesBucket | undefined>(10, undefined);
    let foodData: IValueBucket[] = [
      {
        id: 1,
        name: "苹果",
        calories: 52,
        protein: 0.3,
        fat: 0.2,
        carbohydrates: 14,
        fiber: 2.4,
        vitamin: "Vitamin C",
        minerals: "Potassium",
        quantity: 100,
      },
      {
        id: 2,
        name: "香蕉",
        calories: 89,
        protein: 1.1,
        fat: 0.3,
        carbohydrates: 23,
        fiber: 2.6,
        vitamin: "Vitamin B6",
        minerals: "Magnesium",
        quantity: 100,
      },
      {
        id: 3,
        name: "胡萝卜",
        calories: 41,
        protein: 0.9,
        fat: 0.2,
        carbohydrates: 10,
        fiber: 2.8,
        vitamin: "Vitamin A",
        minerals: "Calcium",
        quantity: 100,
      },
      {
        id: 4,
        name: "鸡胸肉",
        calories: 165,
        protein: 31,
        fat: 3.6,
        carbohydrates: 0,
        fiber: 0,
        vitamin: "Vitamin B3",
        minerals: "Phosphorus",
        quantity: 100,
      },
      {
        id: 5,
        name: "牛油果",
        calories: 160,
        protein: 2,
        fat: 15,
        carbohydrates: 9,
        fiber: 7,
        vitamin: "Vitamin E",
        minerals: "Magnesium",
        quantity: 100,
      },
      {
        id: 6,
        name: "菠菜",
        calories: 23,
        protein: 2.9,
        fat: 0.4,
        carbohydrates: 3.6,
        fiber: 2.2,
        vitamin: "Vitamin K",
        minerals: "Iron",
        quantity: 100,
      },
      {
        id: 7,
        name: "番茄",
        calories: 18,
        protein: 0.9,
        fat: 0.2,
        carbohydrates: 3.9,
        fiber: 1.2,
        vitamin: "Vitamin C",
        minerals: "Potassium",
        quantity: 100,
      },
      {
        id: 8,
        name: "橙子",
        calories: 47,
        protein: 0.9,
        fat: 0.1,
        carbohydrates: 12,
        fiber: 2.4,
        vitamin: "Vitamin C",
        minerals: "Calcium",
        quantity: 100,
      },
      {
        id: 9,
        name: "豆腐",
        calories: 70,
        protein: 8,
        fat: 4,
        carbohydrates: 2,
        fiber: 1.5,
        vitamin: "Vitamin B1",
        minerals: "Iron",
        quantity: 100,
      },
      {
        id: 10,
        name: "红薯",
        calories: 86,
        protein: 1.6,
        fat: 0.1,
        carbohydrates: 20,
        fiber: 3,
        vitamin: "Vitamin A",
        minerals: "Potassium",
        quantity: 100,
      }
    ];
    foodData.forEach((food, index) => {
      valueBucketArray[index] = new SharedValuesBucket(food);
    });
     try {
      create(context)
      insert(context, valueBucketArray);
       console.info("valueBucket:"+JSON.stringify(valueBucketArray))
      this.queryResult = JSON.stringify(await query(context,``), null, 2)
      console.info("queryResult:"+JSON.stringify(this.queryResult))
    } catch (error) {
      console.error("Operation failed", error);
      this.queryResult = "Error: " + error.message;
    }
  }



  dialogController2: CustomDialogController = new CustomDialogController({
  builder: Input({
    weight: this.weight, // 唯一ID
    Foodall:this.Foodall,
    item  :this.itemt,
    Foodlist:this.Foodlist,
    DrawBarChart: () => {
      this.DrawBarChart()
    },
    AddToList:()=>{
      this.AddToList(this.itemt['name'],this.weight)
    }
  }),
  alignment: DialogAlignment.Center,
})


  build() {
      //搜索行
      Column() {
        Row() {
          Text('查找食物:')
            .padding(10)
          TextInput({ placeholder: '请输入菜名', text: $$this.foodTitle })
            .width('60.00%')
          Button({ type: ButtonType.Circle }) {
            Text('搜索')
              .fontColor(Color.White)
              .fontWeight(800)
          }
          .width('100%')
          .height(40)
          .borderRadius(8)
          .onClick(async () => {
            let context = getContext(this);
            this.queryResult = JSON.stringify(await query(context,`${this.foodTitle}`), null, 2)
            console.info("queryResult:"+this.queryResult)
            console.table(this.queryResult );
          });
        }
        .width("100%")
        .backgroundColor("#ffffffff")
        //食物列表
        List() {
          ForEach(JSON.parse(this.queryResult) as object[] , (item: object, index) => {
            ListItem() {
              Row(){
                Column(){
                  Image($r(`app.media.recipe_${index%4}`))
                    .width("100%")
                    .height("100%")
                    .objectFit(ImageFit.Fill)
                }
                  .width(100)
                  .height(90)
                  .margin(0)
                Column() {
                  Text('名称: ' + item['name'])
                    .fontSize(18)
                    .fontWeight(700)
                    .padding(10)
                    .maxLines(1)
                    .fontStyle(FontStyle.Italic)
                  Text('卡路里: ' + item['calories']+'CAL/100g')
                    .fontSize(14)
                    .padding({ left: 10, top: 5 })
                    .maxLines(1)
                  Text('蛋白质: ' + item['protein'] + 'g/100g')
                    .fontSize(14)
                    .padding(10)
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width("50%")
                .backgroundColor('#FFFAE1')
                .alignItems(HorizontalAlign.Start)
                Button({ type: ButtonType.Circle }) {
                  Text('+')
                    .fontColor(Color.White)
                    .fontWeight(800)
                }
                .width('100%')
                .height(40)
                .borderRadius(8)
                .onClick(async () => {
                  //dialog
                  this.itemt=item
                  await this.dialogController2.open()

                });
              }
              .backgroundColor('#FFFAE1')
              .width("100%")
              .borderRadius(10)
            }
            .onClick(()=>{//弹出食物详细信息
              let dialogController: CustomDialogController = new CustomDialogController({
                builder: FoodDetail({
                  FoodID: item['id'], // 唯一ID
                  name: item['name'], // 食物名称
                  calories: item['calories'], // 卡路里
                  protein: item['protein'], // 蛋白质（克）
                  fat: item['fat'], // 脂肪（克）
                  carbohydrates: item['carbohydrates'], // 碳水化合物（克）
                  fiber: item['fiber'],// 纤维（克）
                  vitamin: item['vitamin'], // 维生素信息
                  minerals: item['minerals'],// 矿物质信息
                  quantity: item['quantity'], // 食物的数量（单位：克）
                }),
                alignment: DialogAlignment.Center,
              })
              dialogController.open()
            });
          })

        }
        .width("100%")
        .height("45%")
        .divider({
          strokeWidth: 1,
          startMargin: 10,
          endMargin: 60,
          color: '#ffe9f0f0'
        })  //ListItem间距美化
        .scrollBar(BarState.Auto)


        Tabs({ barPosition: BarPosition.Start, controller: this.controller }){
          TabContent(){
            Column(){
              Row(){
                Text("营养成分分析")
                Select([
                  { value:"男" },
                  { value:"女"},
                ])
                  .onSelect((index:number)=>{
                    this.selectedtype=index
                    this.DrawBarChart()
                  })
                  .value('男')
                Select([
                  { value:"维持" },
                  { value:"减脂" },
                  { value:"增肌" }
                ])
                  .onSelect((index:number)=>{
                    this.selectedplan=index
                    this.DrawBarChart()
                  })
                  .value('维持')
                TextInput({ placeholder: '请输入体重', text: $$this.inputweight })
                  .width('15%')
                  .onChange(()=>{
                    this.DrawBarChart()
                  })
                Text("kg")
              }

              BarChart({ model: this.model })
                .width('100%')
                .height(180)
                .backgroundColor(Color.White)
                .colorBlend(333)
              Button({ type: ButtonType.Circle }) {
                Text('清空')
                  .fontColor(Color.White)
                  .fontWeight(800)
              }
              .width('100%')
              .height(40)
              .backgroundColor('red')
              .borderRadius(8)
              .onClick(() => {
                //dialog
                this.Foodall.calories=0
                this.Foodall.protein=0
                this.Foodall.fat=0
                this.Foodall.carbohydrates=0
                this.Foodlist=[]
                this.DrawBarChart()
              });
            }
          }
          .tabBar(this.TabBuilder(0, '营养分析'))

          TabContent(){
            List(){
              ForEach(this.Foodlist,(item:FIngredient,index)=>{
                ListItem(){
                  Row(){
                    Text(item.name)
                      .maxLines(1)
                      .fontSize(15)
                    Text(item.weight.toString() +'g')
                      .maxLines(1)
                      .fontSize(15)
                  }
                }
              })
            }
            .alignListItem(ListItemAlign.Start)

          }
          .tabBar(this.TabBuilder(1, '总览'))
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barWidth("100%")
        .barHeight(56)
        .animationDuration(400)
        .onChange((index: number) => {
          this.currentIndex = index
        })
        .width(360)
        .height("50%")
        .margin({ top: 0})
        .backgroundColor('#F1F3F5')

      }
      .backgroundColor("#ffd1d6d1")
      .height('100%')
      .width('100%')
    }

  DrawBarChart():void{
    //绘制柱状图
    let values1:JArrayList<BarEntry> = new JArrayList<BarEntry>();
    let values2:JArrayList<BarEntry> = new JArrayList<BarEntry>();
    interface RecObj{
      calories:number;
      protein:number;
      fat:number;
      carbohydrates:number
    }
    let Rec:RecObj[] = [
      {calories:33 , protein:1.5, fat:1.2 ,carbohydrates:5},//基础男性
      {calories:32 , protein:1.5, fat:1 ,carbohydrates:4.5},//基础女性
    ]

    let plan:number[]=[1,0.85,1.15]
    values2.add(new BarEntry(1, Rec[this.selectedtype].calories*plan[this.selectedplan]*this.inputweight))
    values2.add(new BarEntry(2, Rec[this.selectedtype].protein*plan[this.selectedplan]*this.inputweight))
    values2.add(new BarEntry(3, Rec[this.selectedtype].fat*plan[this.selectedplan]*this.inputweight))
    values2.add(new BarEntry(4, Rec[this.selectedtype].carbohydrates*plan[this.selectedplan]*this.inputweight))

    let set1: BarDataSet,set2: BarDataSet,set3: BarDataSet,set4: BarDataSet
    let dataSets: JArrayList<IBarDataSet> =
      new JArrayList<IBarDataSet>();
    set1 = new BarDataSet(values2, "reccalories");
    set1.setColorByColor(Color.Pink);
    set2 = new BarDataSet(values2, "recprotein");
    set2.setColorByColor(Color.Pink);
    set3 = new BarDataSet(values2, "recfat");
    set3.setColorByColor(Color.Pink);
    set4 = new BarDataSet(values2, "reccarbohydrates");
    set4.setColorByColor(Color.Pink);
    dataSets.add(set1);
    dataSets.add(set2);
    dataSets.add(set3);
    dataSets.add(set4);
    values1 =  new JArrayList<BarEntry>();
    set1 = new BarDataSet(values1.add(new BarEntry(1, this.Foodall.calories)), "CAL/calories");
    set1.setColorByColor(Color.Red);
    values1 =  new JArrayList<BarEntry>();
    set2 = new BarDataSet(values1.add(new BarEntry(2, this.Foodall.protein)), "g/protein");
    set2.setColorByColor(Color.Green);
    values1 =  new JArrayList<BarEntry>();
    set3 = new BarDataSet(values1.add(new BarEntry(3, this.Foodall.fat)), "g/fat");
    set3.setColorByColor(Color.Blue);
    values1 =  new JArrayList<BarEntry>();
    set4 = new BarDataSet(values1.add(new BarEntry(4, this.Foodall.carbohydrates)), "g/carbohydrates");
    set4.setColorByColor(Color.Yellow);

    dataSets.add(set1);
    dataSets.add(set2);
    dataSets.add(set3);
    dataSets.add(set4);

    let data:BarData = new BarData(dataSets)
    this.model.setData(data)
  }

  AddToList(name:string,weight:number){
    let same = false;
    this.Foodlist.forEach((item:object,index)=>{
      if(item['name'] == name) {
        this.Foodlist[index].weight +=weight
        this.Foodlist=[...this.Foodlist]
        same=true
      }
    })
    if(!same) {
      this.Foodlist[this.Foodlist.length]=  { name:name,weight:weight }
      promptAction.showToast({ message: '添加成功！' });
    }
    console.info("Listofrecipe:" + this.Foodlist)
  }
}
