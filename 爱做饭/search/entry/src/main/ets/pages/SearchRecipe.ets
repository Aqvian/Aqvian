import { promptAction, router } from '@kit.ArkUI'
import { JSON } from '@kit.ArkTS';
import json from '@ohos.util.json';
import util from '@ohos.util';
//菜谱步骤
interface IStep {
  index: number;
  image: string;
  content: string;
}
//菜谱原料
interface IIngredient {
  name: string;  // 食材名称
  quantity: string;  // 食材数量（单位：克、个等）
}
//菜谱
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
export struct search {

  @State appKey: string = '674bfc7413533babd66416a1'
  @State foodTitle: string = ''
  @State uid: string = 'WEzuV71733033076383CesRKAvfL1'//
  @State response:string =  ''

  @State itemWidth: number = 0
  @State selectIndex: number = 0
  @State hoverIndex: number = -1
  @State result:string = ""
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
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
    ingredients: []  // 食材数组，初始化为空
  };
  @StorageLink('RList') RList: IRecipe[] = []

  private controller: TabsController = new TabsController()
  @Builder TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .color('#007DFF')
        .opacity(this.currentIndex === index ? 1 : 0)
    }.width('100%')
  }


  aboutToAppear(): void {
    console.info("result foodtitle"+this.response)
    let context = getContext(this)
    let fileDir = context.filesDir
    try {
      context.resourceManager.getRawFileContent("food_menu_results.json").then(value => {
        console.info('rawFile_utf: '+ value )
        let rawFile:string = this.convertUint8ArrToStr(value);
        console.info('rawFile: '+ json.stringify(rawFile) )
        this.response = rawFile
        this.result= this.response
      })
    } catch (error) {
      console.error(`promise getRawFileContent failed, error code: ${error.code}, message: ${error.message}.`)
    }

  }

  build() {
      //搜索行
      Column() {
        Row() {
          Text('查找菜谱:')
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
          .onClick(() => {
            this.addSubmit()
          })
        }
        .width("100%")
        .backgroundColor("#ffffffff")
        //菜谱列表
        Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
          TabContent() {
            List() {
              ForEach( json.parse(this.result) as object[], (item: object, index) => {
                if(item['level']== '简单')ListItem() {
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
                    .onClick(() => {
                      router.pushUrl({
                        url: "pages/RecipeDetail",
                        params: item
                      })
                      promptAction.showToast({ message: '查看菜谱详情' });
                    })
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
                      this.itemt = item as IRecipe
                      this.AddToList()
                    });
                  }
                  .backgroundColor('#FFFAE1')
                  .width("100%")
                  .borderRadius(10)
                }
              })
              ListItem(){
                Text("再翻也没有了QwQ")
                  .fontColor(Color.Gray)
              }
            }
            .width("100%")
            .height("100%")
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 60,
              color: '#ffe9f0f0'
            })  //ListItem间距美化
            .scrollBar(BarState.Auto)
          }.tabBar(this.TabBuilder(0, '简单'))
          TabContent() {
            List() {
              ForEach( json.parse(this.result) as object[], (item: object, index) => {
                if(item['level']== '普通')ListItem() {
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
                    .onClick(() => {
                      router.pushUrl({
                        url: "pages/RecipeDetail",
                        params: item
                      })
                      promptAction.showToast({ message: '查看菜谱详情' });
                    })
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
                      this.itemt = item as IRecipe
                      this.AddToList()
                    });
                  }
                  .backgroundColor('#FFFAE1')
                  .width("100%")
                  .borderRadius(10)
                }
              })
              ListItem(){
                Text("再翻也没有了QwQ")
                  .fontColor(Color.Gray)
              }
            }
            .width("100%")
            .height("100%")
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 60,
              color: '#ffe9f0f0'
            })  //ListItem间距美化
            .scrollBar(BarState.Auto)
          }.tabBar(this.TabBuilder(1, '普通'))
          TabContent() {
            List() {
              ForEach( json.parse(this.result) as object[], (item: object, index) => {
                if(item['level']== '困难')ListItem() {
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
                    .onClick(() => {
                      router.pushUrl({
                        url: "pages/RecipeDetail",
                        params: item
                      })
                      promptAction.showToast({ message: '查看菜谱详情' });
                    })
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
                      this.itemt = item as IRecipe
                      this.AddToList()
                    });
                  }
                  .backgroundColor('#FFFAE1')
                  .width("100%")
                  .borderRadius(10)
                }
              })
              ListItem(){
                Text("再翻也没有了QwQ")
                  .fontColor(Color.Gray)
              }
            }
            .width("100%")
            .height("100%")
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 60,
              color: '#ffe9f0f0'
            })  //ListItem间距美化
            .scrollBar(BarState.Auto)

          }.tabBar(this.TabBuilder(2, '困难'))
          TabContent() {
            List() {
              ForEach( json.parse(this.result) as object[], (item: object, index) => {
                if(item['level']== '特色')ListItem() {
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
                      Text('+')
                        .fontColor(Color.White)
                        .fontWeight(800)
                    }
                    .width('100%')
                    .height(40)
                    .borderRadius(8)
                    .onClick(async () => {
                      //dialog
                      this.itemt = item as IRecipe
                      this.AddToList()
                    });
                  }
                  .backgroundColor('#FFFAE1')
                  .width("100%")
                  .borderRadius(10)
                }
              })
              ListItem(){
                Text("再翻也没有了QwQ")
                  .fontColor(Color.Gray)
              }
            }
            .width("100%")
            .height("100%")
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 60,
              color: '#ffe9f0f0'
            })  //ListItem间距美化
            .scrollBar(BarState.Auto)
          }.tabBar(this.TabBuilder(3, '特色'))
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barWidth("100%")
        .barHeight(56)
        .animationDuration(400)
        .onChange((index: number) => {
          this.currentIndex = index
        })
        .width("100%")
        .height("100%")
        .margin({ top: 0})
        .backgroundColor('#F1F3F5')

      }
      .backgroundColor("#ffd1d6d1")
      .height('100%')
      .width('100%')
    }


  addSubmit() {
    promptAction.showToast({ message: '获取菜谱中~~~' });
    let res:object[] = [];
    (JSON.parse(this.response)as object[])?.forEach(item => {
      if (item['title'] && item['title'].includes(this.foodTitle)) {  // 检查 title 是否包含关键词
        res.push(item);  // 如果找到匹配项，将元素添加到 result 数组
      }
    });
    this.result = JSON.stringify(res)
    console.info("result foodtitle"+JSON.stringify( (JSON.parse(this.response))))
    console.info("result foodtitle"+this.foodTitle)
    console.info("get result "+this.result)
  }

  AddToList(){
    let same = false;
    this.RList.forEach((item:IRecipe,index)=>{
      if(item.id == this.itemt.id) {
        same=true
      }
    })
    if(same) promptAction.showToast({ message: '菜谱已存在！' });
    else {
      this.RList[this.RList.length]=this.itemt
      promptAction.showToast({ message: '添加成功！' });
    }
    console.info("Listofrecipe:" + this.RList)
  }

  convertUint8ArrToStr(arr: Uint8Array | object): string {
    //创建了一个 TextDecoder 对象，用于解码 Uint8Array 数组为字符串。这里指定了字符编码为 UTF-8
    //ignoreBOM:是否忽略BOM（byte order marker）标记，默认值为false ，表示解码结果包含BOM标记。
    let textDecoder = new util.TextDecoder("utf-8",{ignoreBOM: true});
    // 使用 typeChecker.isUint8Array(arr) 来检查参数 arr 是否为 Uint8Array 类型的数组。如果是，则使用 TextDecoder 对象将数组解码为字符串并返回；否则返回空字符串。
    return textDecoder.decode(arr as Uint8Array, {stream: false});
  }
}
