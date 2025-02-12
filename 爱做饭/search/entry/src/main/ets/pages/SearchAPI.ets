import http from '@ohos.net.http'
import { App, promptAction, router } from '@kit.ArkUI'
import axios,{ AxiosResponse } from '@ohos/axios'

@Entry
@Component
export struct search {

  @State appKey: string = '674bfc7413533babd66416a1'
  @State foodTitle: string = ''
  @State uid: string = 'WEzuV71733033076383CesRKAvfL1'
  @State response:string ="{\"data\":{\n" +
    "  \"code\": 0,\n" +
    "  \"msg\": \"食谱获取成功\",\n" +
    "  \"countMsg\": \"无限制套餐生效中(2025-01-8 18:43:21到期)\",\n" +
    "  \"tips\": \"如果需要获取更多会话次数或无限次数权限,请前往官网(luckycola.com.cn)“个人中心-充值中心”获取,如需帮助请联系管理员qq2293188960\",\n" +
    "  \"data\": {\n" +
    "    \"foodMenu\": [\n" +
    "      {\n" +
    "        \"intro\": \"\",\n" +
    "        \"image\": \"\",\n" +
    "        \"steps\": [\n" +
    "          {\n" +
    "            \"index\": 1,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"猪肉剁成肉末，韭菜切成细茸。把剁好的猪肉和韭菜放盘子里，加盐，酱油，胡椒粉，姜末，少许花生油， （有芝麻油就滴几滴），拌匀备用\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 2,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"锅里放清水烧开后，把包好的饺子放下锅里，水烧开后，添点冷水，如此反复三次， 把浮起来的饺子捞起来即可。\"\n" +
    "          }\n" +
    "        ],\n" +
    "        \"tags\": [],\n" +
    "        \"notice\": \"现成的饺子皮通常比较干，最好在边上粘点水再捏合，这样可以防止煮的时候漏馅。\",\n" +
    "        \"level\": \"未知\",\n" +
    "        \"craft\": \"其他\",\n" +
    "        \"duration\": \"廿分钟\",\n" +
    "        \"flavor\": \"原味\",\n" +
    "        \"_id\": \"6566088270c9786230f9fb2a\",\n" +
    "        \"id\": \"33\",\n" +
    "        \"title\": \"猪肉韭菜饺子\",\n" +
    "        \"ingredients\": {\n" +
    "          \"半肥猪肉\": \"150克\",\n" +
    "          \"韭菜\": \"100克\",\n" +
    "          \"饺子皮\": \"20张\",\n" +
    "          \"盐\": \"1茶匙\",\n" +
    "          \"酱油\": \"2茶匙\",\n" +
    "          \"生粉\": \"2茶匙\",\n" +
    "          \"姜末\": \"1茶匙\"\n" +
    "        }\n" +
    "      },\n" +
    "      {\n" +
    "        \"intro\": \"“其实很简单，包饺子而已，加了豆腐，饺子吃起来更嫩” \\n\",\n" +
    "        \"image\": \"\",\n" +
    "        \"steps\": [\n" +
    "          {\n" +
    "            \"index\": 1,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"剁肉，剁得差不多了，就放点调料：盐、鸡精、酱油、少许糖，然后，把那些个素材也切成细末：香菇、胡萝卜、芹菜、葱（留一小部分调汤）。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 2,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"馅不要太湿，要不饺子会粘住的，而且容易破。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 3,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"接着就是包饺子了，饺子一端留点小孔，好在煮饺子的时候能让水进去，味道更鲜。\"\n" +
    "          }\n" +
    "        ],\n" +
    "        \"tags\": [\"主食\", \"家常菜\"],\n" +
    "        \"notice\": \"也可以放点水，要不肉会粘刀子。\",\n" +
    "        \"level\": \"简单\",\n" +
    "        \"craft\": \"煮\",\n" +
    "        \"duration\": \"数小时\",\n" +
    "        \"flavor\": \"原味\",\n" +
    "        \"_id\": \"6566088270c9786230f9fcf0\",\n" +
    "        \"id\": \"746\",\n" +
    "        \"title\": \"什锦饺子\",\n" +
    "        \"ingredients\": {\n" +
    "          \"饺子皮\": \"适量\",\n" +
    "          \"芹菜\": \"适量\",\n" +
    "          \"豆腐\": \"适量\",\n" +
    "          \"肉\": \"适量\",\n" +
    "          \"香菇\": \"适量\",\n" +
    "          \"香菜\": \"适量\",\n" +
    "          \"酱油\": \"适量\",\n" +
    "          \"鸡精\": \"适量\",\n" +
    "          \"盐\": \"适量\",\n" +
    "          \"糖\": \"适量\"\n" +
    "        }\n" +
    "      },\n" +
    "      {\n" +
    "        \"intro\": \"“俗话说“舒服不过躺着，好吃不过饺子”，总结的真是精辟啊，每当想起这句话，就想起那香喷喷的饺子来。在外面吃饺子总是对肉馅不放心，周末为了解馋，决定自己动手，包顿萝卜馅饺子，应了另一句俗语“冬吃萝卜夏吃姜”。呵呵，有点罗嗦。” \\n\",\n" +
    "        \"image\": \"\",\n" +
    "        \"steps\": [\n" +
    "          {\n" +
    "            \"index\": 1,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"所需材料：肥瘦猪肉馅（我提前剁好的）、白萝卜、面粉、葱、姜\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 2,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"将葱、姜剁成末，白萝卜擦成丝，挤去水。与肉馅混在一起。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 3,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"放入约50克提前烧好并已放凉的花生油（一定要是放凉的）。开始不停的搅拌盆里的东西，要么顺时针，要么逆时针，随自己的习惯，别一会儿左一会儿右就行。边搅边加水，嗳，这个水要注意，是刚才萝卜里挤掉的水，这样可以最大程度地保证萝卜的营养少流失。直到把馅搅到发粘为止。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 4,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"取一小团面剂子，把它揉成细条。记住，饺子的大小很大程度上取决于面条的粗细，如果你喜欢吃大饺子，则条略粗点，如果喜欢吃小饺子，则条略细点。<br><br>切成小面团，用擀面杖擀开，要求中间厚四周薄。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 5,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"开始包喽，各有各的包法，不强求人人和我一样，但必须包紧了，别露馅了，呵呵。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 6,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"锅上水烧开，下入饺子，用漏勺轻轻地从锅边推一下，防止沉底粘锅，等到饺子全部都浮上来了再盖锅盖。锅开后加水，如此三次即可出锅喽。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 7,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"O了。啊啧啧，快尝尝吧，我的辞藻已无法修饰。只剩下一个字“香”~~~~~~~~\"\n" +
    "          }\n" +
    "        ],\n" +
    "        \"tags\": [\"主食\", \"老人\", \"家常菜\", \"冬季食谱\", \"元旦\", \"小年\"],\n" +
    "        \"notice\": \"如果想让饺子皮更筋道，不粘连，就在和饺子面是加入两个鸡蛋清。\",\n" +
    "        \"level\": \"简单\",\n" +
    "        \"craft\": \"煮\",\n" +
    "        \"duration\": \"廿分钟\",\n" +
    "        \"flavor\": \"咸鲜\",\n" +
    "        \"_id\": \"6566088270c9786230f9feea\",\n" +
    "        \"id\": \"1495\",\n" +
    "        \"title\": \"大肉萝卜馅饺子\",\n" +
    "        \"ingredients\": {\n" +
    "          \"猪肉馅\": \"适量\",\n" +
    "          \"白萝卜\": \"适量\",\n" +
    "          \"面粉\": \"适量\",\n" +
    "          \"葱\": \"适量\",\n" +
    "          \"姜\": \"适量\"\n" +
    "        }\n" +
    "      },\n" +
    "      {\n" +
    "        \"intro\": \"“饺子是北方人的传统家常小吃，各式各样的馅料，各式各样的包法，妈妈是个做饺子的行家，可惜我和妹妹在家都不喜欢吃饺子，现在与妈妈不在一起，却非常想念家里的饺子了。上次妈妈来给我和LG做的偶们觉得很香，自己也搞了一次大排场的，不过还是离不了懒人作风，买的饺子皮，包了好多好多，够我俩饱饱地吃上四五顿啦~~” \\n\",\n" +
    "        \"image\": \"\",\n" +
    "        \"steps\": [\n" +
    "          {\n" +
    "            \"index\": 1,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"调肉馅，将超市买的肥瘦肉馅放入一个大盆中，加入适量的盐、五香粉和酱油，可以加酒去腥，调制均匀。然后朝一个方向搅拌给馅上劲，这样煮饺子时即使烂了，馅儿也不会流出来。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 2,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"一切准备好后就开始包饺子了，记得包的时候要收口包紧，不然皮子会散开，漏掉馅。包好后一锅饺子放在一个大盘里。\"\n" +
    "          },\n" +
    "          {\n" +
    "            \"index\": 3,\n" +
    "            \"image\": \"\",\n" +
    "            \"content\": \"水开后，放入饺子，等饺子浮上来时，加入适量的冷水，待再次烧开后，捞出饺子。\"\n" +
    "          }\n" +
    "        ],\n" +
    "        \"tags\": [\"主食\", \"家常菜\"],\n" +
    "        \"notice\": \"饺子煮好后最好用漏勺捞出，这样不会破皮漏馅。\",\n" +
    "        \"level\": \"简单\",\n" +
    "        \"craft\": \"煮\",\n" +
    "        \"duration\": \"廿分钟\",\n" +
    "        \"flavor\": \"咸鲜\",\n" +
    "        \"_id\": \"6566088270c9786230f9f1bb\",\n" +
    "        \"id\": \"2156\",\n" +
    "        \"title\": \"猪肉馅饺子\",\n" +
    "        \"ingredients\": {\n" +
    "          \"饺子皮\": \"适量\",\n" +
    "          \"猪肉馅\": \"适量\",\n" +
    "          \"盐\": \"适量\",\n" +
    "          \"五香粉\": \"适量\",\n" +
    "          \"酱油\": \"适量\",\n" +
    "          \"酒\": \"适量\"\n" +
    "        }\n" +
    "      }\n" +
    "    ]\n" +
    "  }\n" +
    "}}\n"

  @State itemWidth: number = 0
  @State selectIndex: number = 0
  @State hoverIndex: number = -1
  addSubmit() {
    if (this.foodTitle == '') {
      promptAction.showToast({ message: '菜名不能为空！' })
      return //阻止下面代码继续执行
    }
    promptAction.showToast({ message: '获取菜谱中~~~' });

    axios.post<string, AxiosResponse<string> >('https://luckycola.com.cn/food/getFoodMenu', {
      appKey: this.appKey,
      foodTitle: this.foodTitle,
      uid: this.uid,
    })
      .then((response: AxiosResponse<string>) => {
        this.response=JSON.stringify(response)
        console.info(JSON.stringify(response));
      })
      .catch((error:Error) => {
        console.info(JSON.stringify(error));
      });
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
      List() {
        ForEach((JSON.parse(this.response) as object)?.["data"]["data"]['foodMenu'], (item: object, index) => {
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
                Text('难度: ' + (item as object)?.['level'])
                  .fontSize(14)
                  .padding({ left: 10, top: 5 })
                  .maxLines(1)
                Text('简介: ' + (item as object)?.['intro'])
                  .fontSize(14)
                  .padding(10)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width("70%")
              .backgroundColor('#FFFAE1')
              .onClick(() => {
                router.pushUrl({
                  url: "pages/RecipeDetail",
                  params: item
                })
                promptAction.showToast({ message: '查看菜谱详情' });
              })
              .alignItems(HorizontalAlign.Start)
            }
            .backgroundColor('#FFFAE1')
            .width("100%")
            .borderRadius(10)
          }
        })
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
    }
    .backgroundColor("#ffd1d6d1")
    .height('100%')
    .width('100%')
  }
}