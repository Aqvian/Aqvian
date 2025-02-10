import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component

export  struct me {
  private images: Resource[] = [
    $r('app.media.head1'),
    $r('app.media.head2'),
    $r('app.media.head3'),
    $r('app.media.head4'),
    $r('app.media.head5'),
    $r('app.media.head6'),
  ];

  private images1: Resource[] = [
    $r('app.media.bj1'),
    $r('app.media.bj2'),
    $r('app.media.bj3'),
    $r('app.media.bj4'),
    $r('app.media.bj5'),
    $r('app.media.bj6'),
    $r('app.media.bj7'),
    $r('app.media.bj8'),
    $r('app.media.bj9'),
    $r('app.media.bj10'),
  ];

  // 当前显示的图片索引
  @State currentIndex: number = 0;
  @State currentIndex1: number = 0;
  @StorageLink('isLogin') isLogin:boolean=false
  build() {
    RelativeContainer() {
      // 背景图片：占据整个屏幕
      Image(this.images1[this.currentIndex1])
        .objectFit(ImageFit.Cover) // 背景图像保持比例，覆盖整个容器
        .height('100%')
        .width('100%')
        .zIndex(0)
        .borderRadius(0) // 背景图像不使用圆角
        .margin({top: 0, left: 0, right: 0, bottom: 0})
        .onClick(() => {
          // 点击后切换到下一张图片，并保持循环
          this.currentIndex1 = (this.currentIndex1 + 1) % this.images1.length;
        })

      // 顶部：标题和头像
      Column() {
        // 标题
        Text('爱做饭')
          .fontSize(40) // 设置标题字体大小
          .fontWeight(FontWeight.Bold)
          .fontColor('黑色') // 白色字体以便和背景对比
          .align(Alignment.Center)
          .margin({top: 10,left: 100,right:100}) // 顶部空隙，使标题有间距

        // 头像
        Image(this.images[this.currentIndex])
          .width(100) // 设置头像大小稍微小一点
          .height(100)
          .borderRadius(40) // 圆形头像
          .margin({top: 10,left: 125,right:125}) // 头像与标题之间的间距
          .onClick(() => {
            // 点击后切换到下一张图片，并保持循环
            this.currentIndex = (this.currentIndex + 1) % this.images.length;
          })
      }
      .align(Alignment.Center) // 居中显示
      .margin({top: 50}) // 增加顶部空间，避免与背景图重叠

      // 按钮区域
      Column() {
        // 第一按钮：定义菜谱
        Row() {
          Image($r('app.media.zidingyi_1'))
            .width(30)
            .height(30)
            .margin({right: 10})
          Text('做菜笔记')
            .fontSize(22)
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor('#FF99FF')
        .padding({top: 20, bottom: 20,left:40,right:40})
        .justifyContent(FlexAlign.Center)
        .margin({bottom: 15,left: 80,right:80,top:20})
        .align(Alignment.Center)
        .borderRadius(20)
        .onClick(() => {
          console.info(`成功跳转.`)
          // 跳转到第二页
          router.pushUrl({ url: 'pages/NoteBook' }).then(() => {
            console.info('Succeeded in jumping to the second page.')
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the second page.Code is ${err.code}, message is ${err.message}`)
          })
        })

        // 第二按钮：收藏菜谱
        Row() {
          Image($r('app.media.shoucang_1'))
            .width(30)
            .height(30)
            .margin({right: 10})
          Text('厨房宝典')
            .fontSize(22)
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor('#66FF66')
        .padding({top: 20, bottom: 20,left:40,right:40})
        .justifyContent(FlexAlign.Center)
        .align(Alignment.Center)
        .borderRadius(20)
        .margin({bottom: 15,left: 80,right:80})
        .onClick(() => {
          console.info(`成功跳转.`)
          // 跳转到第二页
          router.pushUrl({ url: 'pages/Kitchen' }).then(() => {
            console.info('Succeeded in jumping to the second page.')
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the second page.Code is ${err.code}, message is ${err.message}`)
          })
        })

        // 第三按钮：设置通知
        Row() {
          Image($r('app.media.tongzhi_1'))
            .width(30)
            .height(30)
            .margin({right: 10})
          Text('设置通知')
            .fontSize(22)
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor('#FF6666')
        .padding({top: 20, bottom: 20,left:40,right:40})
        .justifyContent(FlexAlign.Center)
        .align(Alignment.Center)
        .borderRadius(20)
        .margin({bottom: 15,left: 80,right:80})
        .onClick(() => {
          console.info(`成功跳转.`)
          // 跳转到第二页
          router.pushUrl({ url: 'pages/Reminder' }).then(() => {
            console.info('Succeeded in jumping to the second page.')
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the second page.Code is ${err.code}, message is ${err.message}`)
          })
        })


        // 第四按钮：个人信息
        Row() {
          Image($r('app.media.person_1'))
            .width(30) // 缩小图标尺寸
            .height(30)
            .margin({right: 10}) // 图标和文字之间的间距
          Text('个人信息')
            .fontSize(22) // 调整文字大小
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor('#FFCC00')
        .padding({top: 20, bottom: 20,left:40,right:40}) // 增加内边距使按钮更大
        .justifyContent(FlexAlign.Center)
        .align(Alignment.Center)
        .borderRadius(20)
        .margin({bottom: 15,left: 80,right:80}) // 按钮之间的间距
        .onClick(() => {
          console.info(`成功跳转.`)
          // 跳转到第二页
          router.pushUrl({ url: 'pages/PersonalInformation' }).then(() => {
            console.info('Succeeded in jumping to the second page.')
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the second page.Code is ${err.code}, message is ${err.message}`)
          })
        })

        Row() {
          Image($r('app.media.Logout'))
            .width(30) // 缩小图标尺寸
            .height(30)
            .margin({right: 10}) // 图标和文字之间的间距
          Text('退出登录')
            .fontSize(22) // 调整文字大小
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor('#FFAA11')
        .padding({top: 20, bottom: 20,left:40,right:40}) // 增加内边距使按钮更大
        .justifyContent(FlexAlign.Center)
        .align(Alignment.Center)
        .borderRadius(20)
        .margin({bottom: 15,left: 80,right:80}) // 按钮之间的间距
        .onClick(() => {
          this.isLogin=false
          AlertDialog.show({
            title:"退出登录",
            message: '已成功退出'
          })
        })
      }
      .margin({top: 220}) // 按钮区域从屏幕顶部下方 220px 开始
    }
    .height('100%') // 保证整个页面占满屏幕
  }
}
