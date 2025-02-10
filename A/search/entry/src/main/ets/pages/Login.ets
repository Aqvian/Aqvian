import { promptAction } from '@kit.ArkUI'

interface GeneratedTypeLiteralInterface_1 {
  username: string;
  password: string;
}

interface GeneratedObjectLiteralInterface_1 {
  username: string;
  password: string;
}

PersistentStorage.PersistProp<boolean>('isLogin', false);
PersistentStorage.PersistProp<GeneratedTypeLiteralInterface_1>('credentials', null);

@Entry
@Component
export struct LoginPage {
  @State username: string = '' // 存储用户名
  @State password: string = '' // 存储密码
  @State errorMessage: string = '' // 错误提示信息
  @StorageLink('isLogin') isLogin: boolean = false
  @StorageLink('credentials') storedCredentials: GeneratedTypeLiteralInterface_1 | null = null // 本地存储的用户凭证
  private registerDialogId: number = 0

  // 注册弹窗布局
  @Builder
  registerDialog() {
    Column() {
      Text('注册')
        .fontSize(30)
        .fontWeight('bold')
        .textAlign(TextAlign.Center)
        .fontColor('#007BFF') // 更加醒目的蓝色字体
        .margin({ bottom: 10 })

      Column() {
        // 错误提示
        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontColor('#FF6347')
            .fontSize(14)
            .margin({ bottom: 10 })
        }

        // 用户名输入框
        TextInput({
          placeholder: '请输入账号'
        })
          .onChange((val: string) => this.username = val)
          .width(250)
          .margin({ top: 10 })
          .borderRadius(12)
          .padding({ left: 15, right: 15 })
          .backgroundColor('#FFFFFF')
          .borderColor('#007BFF')
          .borderWidth(2)

        // 密码输入框
        TextInput({
          placeholder: '请输入密码'
        })
          .onChange((val: string) => this.password = val)
          .width(250)
          .type(InputType.Password)
          .margin({ top: 10, bottom: 30 })
          .borderRadius(12)
          .padding({ left: 15, right: 15 })
          .backgroundColor('#FFFFFF')
          .borderColor('#007BFF')
          .borderWidth(2)

        Row({ space: 25 }) {
          // 注册按钮
          Button('注册')
            .width(100)
            .height(50)
            .borderRadius(25)
            .backgroundColor('#007BFF')
            .fontColor('#FFF')
            .onClick(() => this.handleRegister())

          // 取消按钮
          Button('取消')
            .width(100)
            .height(50)
            .borderRadius(25)
            .backgroundColor('#888888')
            .fontColor('#FFF')
            .onClick(() => {
              promptAction.closeCustomDialog(this.registerDialogId)
            })
        }
      }
    }
    .height(300)
    .padding(20)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
  }

  build() {
    RelativeContainer() {
      // 背景图片：占据整个屏幕
      Image($r("app.media.bj1"))
        .objectFit(ImageFit.Cover)
        .height('100%')
        .width('100%')
        .zIndex(0)
        .borderRadius(0)
        .margin({ top: 0, left: 0, right: 0, bottom: 0 });

      Column() {
        //页面标题
        Text('爱做饭')
          .fontSize(50)
          .fontWeight('bold')
          .fontColor('linear-gradient(45deg, #1E90FF, #FFFFFF)')  // 渐变色文字（蓝白渐变）
          .textAlign(TextAlign.Center)
          .margin({ top: 150, bottom: 50, left: 80, right: 80 })



        // 登录表单
        Column() {
          // 错误提示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontColor('#FF6347')
              .fontSize(14)
              .margin({ bottom: 10 })
          }

          // 用户名输入框
          TextInput({
            placeholder: '请输入账号'
          })
            .onChange((val: string) => this.username = val)
            .width(250)
            .margin({ top: 20, left: 80, right: 80 })
            .borderRadius(12)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#FFFFFF')
            .borderColor('#007BFF')
            .borderWidth(2)

          // 密码输入框
          TextInput({
            placeholder: '请输入密码'
          })
            .onChange((val: string) => this.password = val)
            .width(250)
            .type(InputType.Password)
            .margin({ top: 20 })
            .borderRadius(12)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#FFFFFF')
            .borderColor('#007BFF')
            .borderWidth(2)

          // 登录按钮
          Button('登录')
            .width(180)
            .margin({ top: 30 })
            .borderRadius(25)
            .height(50)
            .backgroundColor('#FF6347')
            .fontColor('#FFF')
            .onClick(() => this.handleLogin())
        }

        // 注册按钮弹窗
        Button('没有账号？点击注册')
          .margin({ top: 20 })
          .fontSize(14)
          .fontColor('#007BFF')
          .backgroundColor('transparent')
          .onClick(() => {
            promptAction.openCustomDialog({
              builder: () => {
                this.registerDialog()
              },
              onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                console.info("reason" + JSON.stringify(dismissDialogAction.reason))
              }
            }).then((dialogId: number) => {
              this.registerDialogId = dialogId
            })
          })
      }
    }
  }

  // 验证用户名
  validateUsername(username: string): boolean {
    if (!username) {
      this.showErrorDialog('用户名不能为空');
      return false;
    }
    if (username.length < 3) {
      this.showErrorDialog('用户名至少需要3个字符');
      return false;
    }
    return true;
  }

  // 验证密码
  validatePassword(password: string): boolean {
    if (!password) {
      this.showErrorDialog('密码不能为空');
      return false;
    }
    if (password.length < 6) {
      this.showErrorDialog('密码至少需要6个字符');
      return false;
    }
    return true;
  }

  // 处理登录逻辑
  handleLogin() {
    if (this.validateUsername(this.username) && this.validatePassword(this.password)) {
      if (this.storedCredentials) {
        const username = this.storedCredentials.username;
        const password = this.storedCredentials.password;

        if (this.username === username && this.password === password) {
          console.info('登录成功');
          this.errorMessage = '';
          promptAction.showDialog({
            title: '登录成功',
            message: '欢迎回来！',
            buttons: [{ text: '确认', color: '#FF6347' }],
          });
          this.isLogin = true;
        } else {
          this.showErrorDialog('用户名或密码错误');
        }
      } else {
        this.showErrorDialog('没有找到已注册的账号');
      }
    } else {
      console.info('登录失败');
    }
  }

  // 处理注册逻辑
  handleRegister() {
    if (this.validateUsername(this.username) && this.validatePassword(this.password)) {
      const credentials: GeneratedObjectLiteralInterface_1 = { username: this.username, password: this.password };
      // 保存用户信息到本地存储
      AppStorage.set('credentials', credentials);
      console.info('注册成功');
      this.errorMessage = '';
      promptAction.showDialog({
        title: '注册成功',
        message: '您已成功注册!',
        buttons: [{ text: '确认', color: '#007BFF' }],
      });
      promptAction.closeCustomDialog(this.registerDialogId); // 关闭注册弹窗
    } else {
      console.info('注册失败');
    }
  }

  // 显示错误弹窗
  showErrorDialog(message: string) {
    promptAction.showDialog({
      title: '错误',
      message: message,
      buttons: [{ text: '确认', color: '#FF6347' }],
    });
  }
}
