import { router } from '@kit.ArkUI'
import { JSON } from '@kit.ArkTS'
@Entry
@Component
struct RecipeDetail {

  @State ingredients:object = new Object
  //response示例
  @State response:string = " "

  aboutToAppear(){
    const params:object = router.getParams()//获取上页传来的菜谱信息
    const parsedResponse = params
    this.ingredients = (parsedResponse as object)?.["ingredients"];//提取原料信息
    if (this.ingredients && typeof this.ingredients === 'object') {
      this.ingredients = Object.entries(this.ingredients) as [string, string][];
    } else {
      console.error("Ingredients is not a valid object:", this.ingredients);
    }
    if(params) this.response = JSON.stringify(params)//若param为空会报错
    console.log('testTag', JSON.stringify(params))
  }
  build() {
    Navigation() {
      List() {
        ListItem(){
          Text("原料：")
            .fontSize(18)
            .fontWeight(700)
            .padding(10)
        }
          ForEach(this.ingredients as object[]
            , (item:object,index) => {
            ListItem() {
              Row() {
                Column() {
                  if(item[1] !== "删除")
                  Text(item[0] + ": " + item[1])
                    .fontSize(18)
                    .fontWeight(700)
                    .padding(10)
                }
              }
              .width("100%")
            }
          })
        ForEach((JSON.parse(this.response) as object)?.["steps"], (item: object, index) => {
          ListItem() {
            Row() {
              Column() {
                Text('步骤'+(index+1)+":")
                  .fontSize(18)
                  .fontWeight(700)
                  .padding(10)
                Text((item as object)?.['content'])
                  .fontSize(18)
                  .fontWeight(700)
                  .padding(10)
              }
              //.backgroundColor("#ff3fdb78")
              .alignItems(HorizontalAlign.Start)
            }
            .width("100%")
          }
        })
      }
      .width("100%")
      .height("100%")
    }
    .hideTitleBar(false)
    .title((JSON.parse(this.response) as object)?.["title"])
    .hideBackButton(false)
    .width("100%")
    .height("100%")
    .titleMode(NavigationTitleMode.Mini)
    .backgroundImage($r('app.media.bj13'))
  }
} 