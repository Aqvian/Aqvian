import { search } from './SearchRecipe'
import { rbd } from './NutritionAnalyze'
import {me} from './Me'
import { LoginPage } from './Login'
import { RList } from './TodoList'

PersistentStorage.PersistProp<boolean>('isLogin',false);
@Entry
@Component
struct MainPage{
  @State index: number = 0;
  @StorageLink('isLogin') isLogin:boolean=false
  @Builder toolbarWidget() {// 通过builder自定义toolbar
    Row() {
      Column() {
        Image(this.index == 0 ? $r("app.media.search_1") : $r("app.media.search_0"))          .size({width: 25, height: 25}).margin({bottom:4,top:4})
        Text('主页')
          .fontSize(16)
          .fontColor(this.index == 0 ? Color.Orange : null)
      }
      .alignItems(HorizontalAlign.Center)
      .height('100%')
      .layoutWeight(1)
      .onClick(() => {
        this.index = 0;
      })

      Column() {
        Image(this.index == 1 ? $r("app.media.nutrition_1") : $r("app.media.nutrition_0"))
          .size({width: 25, height: 25}).margin({bottom:4,top:4})
        Text('营养')
          .fontSize(16)
          .fontColor(this.index == 1 ? Color.Orange : null)
      }
      .alignItems(HorizontalAlign.Center)
      .height('100%')
      .layoutWeight(1)
      .onClick(() => {
        this.index = 1;
      })

      Column() {
        Image(this.index == 2 ? $r("app.media.list_1") : $r("app.media.list_0"))
          .size({width: 25, height: 25}).margin({bottom:4,top:4})
        Text('清单')
          .fontSize(16)
          .fontColor(this.index == 2 ? Color.Orange : null)
      }
      .alignItems(HorizontalAlign.Center)
      .height('100%')
      .layoutWeight(1)
      .onClick(() => {
        this.index = 2;
      })

      Column() {
        Image(this.index == 3 ? $r('app.media.me_1') : $r('app.media.me_0'))
          .size({width: 25, height: 25}).margin({bottom:4,top:4})
        Text('我的')
          .fontSize(16)
          .fontColor(this.index == 3 ? Color.Orange : null)
      }
      .alignItems(HorizontalAlign.Center)
      .height('100%')
      .layoutWeight(1)
      .onClick(() => {
        this.index = 3;
      })
    }
    .width('100%')
    .height(60)
    .visibility(this.isLogin? Visibility.Visible:Visibility.Hidden)
  }

  build() {
    Navigation(){
          LoginPage()
            .visibility(!this.isLogin? Visibility.Visible:Visibility.Hidden)
            .displayPriority(!this.isLogin? 3:1)
          search()
            .visibility(this.index==0? Visibility.Visible:Visibility.Hidden)
            .displayPriority(this.index==0? 2:1)
          rbd()
            .visibility(this.index==1? Visibility.Visible:Visibility.Hidden)
            .displayPriority(this.index==1? 2:1)
          RList()
            .visibility(this.index==2? Visibility.Visible:Visibility.Hidden)
            .displayPriority(this.index==2? 2:1)
          me()
            .visibility(this.index==3? Visibility.Visible:Visibility.Hidden)
            .displayPriority(this.index==3? 2:1)
    }
    .toolBar(this.toolbarWidget)
  }

}