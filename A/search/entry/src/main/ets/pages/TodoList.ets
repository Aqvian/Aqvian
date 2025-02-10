import { promptAction } from '@kit.ArkUI';
import router from '@ohos.router';
import { JSON } from '@kit.ArkTS';

interface IStep {
  index: number;
  image: string;
  content: string;
}

interface IIngredient {
  name: string;  // 食材名称
  quantity: string;  // 食材数量（单位：克、个等）
}

interface IRecipe {
  intro: string;
  image: string;
  steps: IStep[];
  tags: string[]; // 标签数组
  notice: string;
  level: string; // 难度级别
  craft: string; // 烹饪方式
  duration: string; // 烹饪时长
  flavor: string; // 味道
  _id: string;
  id: string | number; // id可以是字符串或数字
  title: string; // 食谱标题
  ingredients: IIngredient[]; // 食材数组
}


PersistentStorage.PersistProp<IRecipe[]>('RList',[]);
@Entry
@Component
export struct RList {
  @State itemt: IRecipe = {
    intro: "",  // 食谱简介
    image: "",  // 食谱图片URL
    steps: [],  // 步骤数组，初始化为空
    tags: [],  // 标签数组，初始化为空
    notice: "",  // 备注，初始化为空
    level: "未知",  // 难度级别，初始化为“未知”
    craft: "",  // 烹饪方式，初始化为空
    duration: "",  // 烹饪时长，初始化为空
    flavor: "",  // 味道，初始化为空
    _id: "",  // 唯一ID，初始化为空
    id: "",  // 食谱ID，初始化为空
    title: "",  // 食谱标题，初始化为空
    ingredients: []  as  IIngredient[]// 食材数组，初始化为空
  };
  @StorageLink('RList') RList: IRecipe[] = []
  @State selectedNoteIndex: number = -1 // 编辑选中的记事本页面
  @State editingTitle: string = '标题' // 页面标题
  @State editingContent: string = '' // 页面内容
  @State EditTitle: string = '添加记事本' // 窗口标题
  @State changeValue: string = '' // 搜索框输入的值
  @State ingredients:IIngredient[] = [{name:'',quantity:''}]
  @State Task:boolean[] = [false]


  aboutToAppear(): void {
    this.CountIngredients()
  }

  build() {
    Column() {
      // 使用 Scroller 来包裹需要滚动的区域
      Scroll() {
        Column() {
          // 记事本页面列表
          List({ space: 10 }) {
            ForEach(this.RList, (item: IRecipe, index: number) => {
              ListItem() {
                Row(){
                  Image($r('app.media.recipe_0'))
                    .width(90)
                    .height(90)
                    .margin(0)
                  Column() {
                    Text((item as object)?.['title'])
                      .fontSize(18)
                      .fontWeight(700)
                      .padding(10)
                      .maxLines(1)
                      .fontStyle(FontStyle.Italic)
                    Text('标签: ' + (item as object)?.['tags'])
                      .fontSize(14)
                      .padding({ left: 10, top: 5 })
                      .maxLines(1)
                    Text('简介: ' + (item as object)?.['intro'])
                      .fontSize(14)
                      .padding(10)
                      .maxLines(3)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width("60%")
                  .backgroundColor('#FFFAE1')
                  .onClick(() => {
                    router.pushUrl({
                      url: "pages/RecipeDetail",
                      params: item
                    })
                    promptAction.showToast({ message: '查看菜谱详情' });
                  })
                  .alignItems(HorizontalAlign.Start)
                  Button({ type: ButtonType.Circle }) {
                    Text('-')
                      .fontColor(Color.White)
                      .fontWeight(800)
                  }
                  .backgroundColor("red")
                  .width('100%')
                  .height(40)
                  .borderRadius(8)
                  .onClick(async () => {
                    //dialog
                    this.itemt = item as IRecipe
                    this.DeleteFromList()
                    this.CountIngredients()
                  });
                }
                .backgroundColor('#FFFAE1')
                .width("100%")
                .borderRadius(10)
              }
            })
          }
          .divider({
            strokeWidth: 1,
            startMargin: 10,
            endMargin: 100,
            color: '#ECF0F1'  // 柔和的灰白色
          })
          .width('100%') // 设置 List 宽度为 100%
          .padding({ top: 20 }) // 增加顶部内边距，确保与顶部间隔
          .height('100%') // 保证整个页面占满屏幕

        }
      }.height("40%")

      Column(){
        Row(){
          Text("购物清单")
            .maxLines(1)
            .fontSize(24)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .alignSelf(ItemAlign.Center)
          Blank()
          Button({ type: ButtonType.Normal }) {
            Text('统计食材')
              .fontColor(Color.White)
              .fontWeight(800)
          }
          .borderRadius(8)
          .onClick(()=>{
            this.CountIngredients()
          })
        }

        Scroll() {
          List(){
            ForEach(this.ingredients,(item:IIngredient,index)=>{
              ListItem(){
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Row({ space: 4 }) {
                      Circle()
                        .width(24)
                        .height(24)
                        .fill(Color.White)
                        .borderWidth(3)
                        .borderRadius(30)
                        .borderColor('#ffdcdfdf')
                        .foregroundColor(this.Task[index]==true? "green":"white")
                        .margin({ right: 10 })
                        .onClick(()=>{
                          this.Task[index]=!this.Task[index]
                          this.Task=[...this.Task]
                      })
                      Text(item.name +item.quantity)
                        .maxLines(1)
                        .fontSize(15)
                        .decoration({type:this.Task[index]==true? TextDecorationType.LineThrough:TextDecorationType.None, color: Color.Black})
                    }
                  }
                }
                .padding({bottom:3})
            })
          }
          .divider({
            strokeWidth: 1,
            startMargin: 10,
            endMargin: 100,
            color: '#ECF0F1'  // 柔和的灰白色
          })
          }.height("80%")
      }.height("60%")
    }
    .backgroundImage($r("app.media.bj13"))
  }

  DeleteFromList(){
    this.RList.forEach((item:IRecipe,index)=>{
      if(item.id == this.itemt.id) {
        this.RList.splice(index, 1);
        promptAction.showToast({ message: '删除成功！' });
      }
    })
  }
  //统计整合原料
  CountIngredients() {
    this.ingredients=[]
    this.RList.forEach((item: IRecipe) => {
      console.info("item.ingredients:" +JSON.stringify(typeof item.ingredients))
      let ingredientsArray: IIngredient[] = Object.entries(item.ingredients as object).map((entry: [string, string]) => {
        const name = entry[0];       // 第一个元素是食材名称
        const quantity = entry[1];   // 第二个元素是食材数量
        return { name, quantity } as IIngredient;   // 返回一个符合 IIngredient 接口的对象
      });console.info("ingredientsArray:" +JSON.stringify(ingredientsArray))
      ingredientsArray.forEach((ingre1: IIngredient) => {
        let same = false;
        this.ingredients.forEach((ingre2: IIngredient) => {
          // 检查两者的原料名称是否相同
          if (ingre1.name === ingre2.name) {
            same = true;
            // 尝试从数量中匹配数字和单位
            let match1 = ingre1.quantity.match(/(\d+)(\D+)?/);
            let match2 = ingre2.quantity.match(/(\d+)(\D+)?/);

            // 如果两个原料的数量都能匹配到数字和单位
            if (match1 && match2) {
              // 数字相加
              let totalQuantity = parseInt(match1[1]) + parseInt(match2[1]);
              let unit = match1[2] || match2[2]; // 默认取第一个的单位
              ingre2.quantity = totalQuantity.toString() + (unit || ''); // 合并数量和单位
            } else {
              // 如果没有数字和单位的匹配，设置为“适量”
              ingre2.quantity = '适量';
            }
          }
        });
        // 如果没有找到相同的原料，就添加一个新的原料
        if (!same) {
          this.ingredients.push({ name: ingre1.name, quantity: ingre1.quantity });
        }
      });
    });
    this.ingredients=[...this.ingredients]
  }

}

