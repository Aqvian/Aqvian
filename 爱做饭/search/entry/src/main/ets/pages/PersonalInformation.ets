import { EditableLeftIconType, EditableTitleBar, promptAction } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';



PersistentStorage.PersistProp<Resource>('head',$r("app.media.head1"));
PersistentStorage.PersistProp<string>('userName',"张三");
PersistentStorage.PersistProp<string>('userEmail',"zhangsan@example.com");
PersistentStorage.PersistProp<string>('userGender',"男");
PersistentStorage.PersistProp<string>('userBirthday',"1990-01-01");
PersistentStorage.PersistProp<string>('userRegion',"北京市");


@Entry
@Component
export struct PersonalInformation {
  @StorageLink('userName') userName: string = AppStorage.Get('userName') || "张三"; // 从本地存储获取用户名
  @StorageLink('userEmail') userEmail: string = AppStorage.Get('userEmail') || "zhangsan@example.com"; // 从本地存储获取邮箱
  @StorageLink('userGender')  userGender: string = AppStorage.Get('userGender') || "男"; // 从本地存储获取性别
  @StorageLink('userBirthday') userBirthday: string = AppStorage.Get('userBirthday') || "1990-01-01"; // 从本地存储获取生日
  @StorageLink('userRegion') userRegion: string = AppStorage.Get('userRegion') || "北京市"; // 从本地存储获取地区
  @StorageLink('head') profileSrc: Resource = $r("app.media.head1"); // 默认头像
  // @State userName: string = AppStorage.Get('userName') || "张三"; // 从本地存储获取用户名
  // @State userEmail: string = AppStorage.Get('userEmail') || "zhangsan@example.com"; // 从本地存储获取邮箱
  // @State userGender: string = AppStorage.Get('userGender') || "男"; // 从本地存储获取性别
  // @State userBirthday: string = AppStorage.Get('userBirthday') || "1990-01-01"; // 从本地存储获取生日
  // @State userRegion: string = AppStorage.Get('userRegion') || "北京市"; // 从本地存储获取地区
  @State isEditMode: boolean = false; // 是否为编辑模式

  // 编辑个人信息
  toggleEditMode() {
    this.isEditMode = !this.isEditMode;
  }

  // 保存个人信息到本地存储
  saveProfile() {
    // 保存到本地存储
    AppStorage.SetOrCreate('userName', this.userName);
    AppStorage.SetOrCreate('userEmail', this.userEmail);
    AppStorage.SetOrCreate('userGender', this.userGender);
    AppStorage.SetOrCreate('userBirthday', this.userBirthday);
    AppStorage.SetOrCreate('userRegion', this.userRegion);
    // 保存后退出编辑模式
    this.toggleEditMode();
    console.log("个人信息已保存", this.userName, this.userEmail, this.userGender, this.userBirthday, this.userRegion);
  }

  build() {
    Column() {
      // 主界面导航栏
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Cancel, // 设置左侧为返回箭头
        title: '个人信息', // 修改为“个人信息”作为标题
        isSaveIconRequired: false,

        onCancel: () => {
          promptAction.showToast({ message: "返回操作" })
          router.back()
        },
      })
        .height(60)
        .backgroundColor('#F3F4F6') // 浅灰色背景
        .padding({ left: 0, right: 10 });

      // 个人信息设置界面
      NavDestination() {
        RelativeContainer() {
          // 背景图片：占据整个屏幕
          Image($r("app.media.bj13"))
            .objectFit(ImageFit.Cover) // 背景图像保持比例，覆盖整个容器
            .height('100%')
            .width('100%')
            .zIndex(0)
            .borderRadius(0) // 背景图像不使用圆角
            .margin({
              top: 0,
              left: 0,
              right: 0,
              bottom: 0
            });

          Column() {
            // 顶部导航栏

            // 头像展示（不再支持上传，直接显示默认头像）
            Image(this.profileSrc)
              .alt($r("app.media.head"))
              .width(108)
              .height(108)
              .objectFit(ImageFit.Cover)
              .borderRadius(54)
              .margin({ top: 30 });

            // 个人信息展示和编辑
            Text('用户名:')
              .fontSize(20)
              .margin({ top: 30 });

            TextInput({text: this.userName})
              .enabled(this.isEditMode)
              .backgroundColor('#FFFFFF')  // 设置背景颜色为白色
              .borderRadius(8)  // 添加圆角
              .borderColor('#CCCCCC') // 设置边框颜色
              .borderWidth(1)  // 设置边框宽度
              .padding({ top: 10, left: 10, right: 10, bottom: 10 })  // 设置内边距
              .onChange((value: string) => {
                this.userName = value; // 获取文本并更新状态
              });

            Text('邮箱:')
              .fontSize(20)
              .margin({ top: 10 });

            TextInput({text: this.userEmail})
              .enabled(this.isEditMode)
              .backgroundColor('#FFFFFF')  // 设置背景颜色为白色
              .borderRadius(8)  // 添加圆角
              .borderColor('#CCCCCC') // 设置边框颜色
              .borderWidth(1)  // 设置边框宽度
              .padding({ top: 10, left: 10, right: 10, bottom: 10 })  // 设置内边距
              .onChange((value: string) => {
                this.userEmail = value; // 获取文本并更新状态
              });

            Text('性别:')
              .fontSize(20)
              .margin({ top: 10 });

            TextInput({text: this.userGender})
              .enabled(this.isEditMode)
              .backgroundColor('#FFFFFF')  // 设置背景颜色为白色
              .borderRadius(8)  // 添加圆角
              .borderColor('#CCCCCC') // 设置边框颜色
              .borderWidth(1)  // 设置边框宽度
              .padding({ top: 10, left: 10, right: 10, bottom: 10 })  // 设置内边距
              .onChange((value: string) => {
                this.userGender = value; // 获取文本并更新状态
              });

            Text('生日:')
              .fontSize(20)
              .margin({ top: 10 });

            TextInput({text: this.userBirthday})
              .enabled(this.isEditMode)
              .backgroundColor('#FFFFFF')  // 设置背景颜色为白色
              .borderRadius(8)  // 添加圆角
              .borderColor('#CCCCCC') // 设置边框颜色
              .borderWidth(1)  // 设置边框宽度
              .padding({ top: 10, left: 10, right: 10, bottom: 10 })  // 设置内边距
              .onChange((value: string) => {
                this.userBirthday = value; // 获取文本并更新状态
              });

            // 新增地区字段
            Text('地区:')
              .fontSize(20)
              .margin({ top: 10 });

            TextInput({text: this.userRegion})
              .enabled(this.isEditMode)
              .backgroundColor('#FFFFFF')  // 设置背景颜色为白色
              .borderRadius(8)  // 添加圆角
              .borderColor('#CCCCCC') // 设置边框颜色
              .borderWidth(1)  // 设置边框宽度
              .padding({ top: 10, left: 10, right: 10, bottom: 10 })  // 设置内边距
              .onChange((value: string) => {
                this.userRegion = value; // 获取文本并更新状态
              });

            // 编辑按钮和保存按钮
            Row() {
              // 编辑按钮
              Button('编辑')
                .onClick(() => this.toggleEditMode()) // 切换编辑模式
                .margin({ right: 60 }); // 增加按钮之间的间距

              // 保存按钮
              Button('保存')
                .onClick(() => this.saveProfile()) // 保存个人信息
            }
            .margin({ top: 30 });

          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .height('100%')
          .padding({ top: 0, left: 20, right: 20 });
        }
      }
      .height('100%') // 保证整个页面占满屏幕
    }
  }
}
