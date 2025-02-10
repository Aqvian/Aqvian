import { notificationManager } from '@kit.NotificationKit'
import { EditableLeftIconType, EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

import { router } from '@kit.ArkUI';

//请求通知权限
let context = getContext(this) as common.UIAbilityContext;
notificationManager.isNotificationEnabled().then((data: boolean) => {
  hilog.info(DOMAIN_NUMBER, TAG, "isNotificationEnabled success, data: " + JSON.stringify(data));
  if(!data){
    notificationManager.requestEnableNotification(context).then(() => {
      hilog.info(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification success`);
    }).catch((err : BusinessError) => {
      if(1600004 == err.code){
        hilog.error(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
      } else {
        hilog.error(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      }
    });
  }
}).catch((err : BusinessError) => {
  hilog.error(DOMAIN_NUMBER, TAG, `isNotificationEnabled fail, code is ${err.code}, message is ${err.message}`);
});


interface Alarm {
  id: number;
  time: Date;
  label: string;
  isEnabled: boolean;
  note: string;  // 添加备注
}

const TAG: string = '[PublishOperation]';
const DOMAIN_NUMBER: number = 0xFF00;

//闹钟的编辑界面
@CustomDialog
struct EditClock {
  @Link EditTitle:string
  @Link editingTime: Date
  @Link editingLabel:string
  @Link editingNote:string
  @Link selectedAlarmIndex:number
  saveEditedAlarm: ()=>void = ()=>{}
  deleteAlarm: ()=>void = ()=>{}
  controller?: CustomDialogController

  build() {
    Column() {
      // 编辑界面顶部导航栏
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Cancel,
        title: this.EditTitle,
        menuItems: [],
        onCancel: () => {
          this.controller?.close()
        },
        onSave: () => {
          this.saveEditedAlarm() // 保存编辑的闹钟
          this.controller?.close()
        }
      })
        .height(80)
        .backgroundColor('#F3F4F6')// 浅灰色背景
        .padding({ left: 0, right: 0 })

      // 选择时间按钮
      Button("选择时间")
        .margin({ top: 20, bottom: 20 })
        .padding({
          top: 8,
          bottom: 8,
          left: 12,
          right: 12
        })// 较小的内边距
        .backgroundColor('#007BFF')// 蓝色背景
        .fontColor('#FFF')// 白色字体
        .borderRadius(8)// 圆角按钮
        .onClick(() => {
          // 显示时间选择器弹窗
          TimePickerDialog.show({
            selected: this.editingTime,
            disappearTextStyle: { color: Color.Grey, font: { size: 15, weight: FontWeight.Lighter } },
            textStyle: { color: Color.Black, font: { size: 20, weight: FontWeight.Normal } },
            selectedTextStyle: { color: Color.Black, font: { size: 30, weight: FontWeight.Bolder } },
            onAccept: (value: TimePickerResult) => {
              // 设置selectTime为按下确定按钮时的时间
              if (value.hour !== undefined && value.minute !== undefined) {
                this.editingTime.setHours(value.hour, value.minute)
                console.info("TimePickerDialog:onAccept()" + JSON.stringify(value))
              }
            },
            onCancel: () => {
              console.info("TimePickerDialog:onCancel()")
            },
            onChange: (value: TimePickerResult) => {
              console.info("TimePickerDialog:onChange()" + JSON.stringify(value))
            }
          })
        })
        .width('60%')

      // 标签输入框
      Column() {
        Text('标签')
          .font({ size: 16, weight: FontWeight.Normal })
          .margin({ top: 20 })
        TextInput({
          text: $$this.editingLabel,
        })
          .padding({ top: 10 })
          .border({ color: '#E0E0E0', width: 1, radius: 8 })// 添加圆角边框
          .backgroundColor('#FFF')
          .height(40)
          .borderRadius(20)
          .fontColor('#333333') // 深灰色字体
      }

      // 备注输入框
      Column() {
        Text('备注')
          .font({ size: 16, weight: FontWeight.Normal })
          .margin({ top: 20 })
        TextInput({
          text: $$this.editingNote,
        })
          .padding({ top: 10, bottom: 10 })
          .border({ color: '#E0E0E0', width: 1, radius: 8 })// 添加圆角边框
          .backgroundColor('#FFF')
          .height(40)
          .borderRadius(20)
          .fontColor('#333333') // 深灰色字体
      }

      // 删除按钮
      if(this.EditTitle==='编辑闹钟'){
        Button('删除')
          .onClick(() => {
            this.deleteAlarm()
            this.controller?.close()
          })
          .padding({ top: 10, bottom: 10 })
          .backgroundColor('#FF5C5C')// 红色背景
          .fontColor('#FFF')// 白色字体
          .borderRadius(8)// 圆角按钮
          .width('30%')
      }
    }
    .padding({bottom: 10 })
  }
}
PersistentStorage.PersistProp<Alarm[]>('Alarms',[]);
@Entry
@Component
export  struct AlarmClockApp {
  //@StorageProp('Alarms') Alarm:Alarm[] = []
  //@State alarms: Alarm[] = AppStorage.get('Alarms') as Alarm[]// 闹钟列表
  @StorageLink('Alarms') alarms: Alarm[] = []// 闹钟列表
  @State selectedAlarmIndex: number = -1 //编辑选中的闹钟
  @State editingTime: Date = new Date()
  @State editingLabel: string = '通知吃饭' // 设置默认标签
  @State editingNote: string = '提醒您，现在是餐点时间，快来吃饭吧！' // 设置默认备注
  @State isEditEnabled: boolean = true
  @State EditTitle: string = '添加闹钟'
  dialogController: CustomDialogController = new CustomDialogController({
    builder: EditClock({
      saveEditedAlarm: () => {
        this.saveEditedAlarm()
      },
      deleteAlarm: () => {
        this.deleteAlarm()
      },
      selectedAlarmIndex: this.selectedAlarmIndex,
      EditTitle: this.EditTitle,
      editingTime: this.editingTime,
      editingLabel: this.editingLabel,
      editingNote: this.editingNote
    }),
    alignment: DialogAlignment.Bottom,
  })

  build() {
    Column() {
      // 主界面导航栏
      EditableTitleBar({
        isSaveIconRequired:false,
        leftIconStyle: 3,
        title: '设置通知',
        menuItems: [
          {
            isEnabled: true,
            value: $r("app.media.add"),
            action: () => {
              this.addNewAlarm() // 跳转到编辑闹钟界面
            }
          }
        ],
        onCancel:()=>{
          router.back()
        }
      })
        .height(60)
        .backgroundColor('#F3F4F6')// 浅灰色背景
        .padding({ left: 0, right: 10, bottom:10})

      // 闹钟列表部分
      List({ space: 10 }) {
        ForEach(this.alarms, (alarm: Alarm, index: number) => {
          ListItem() {
            Row() {
              // 显示时间和标签
              Row() {
                if (alarm.time instanceof Date) {
                  Text(`${alarm.time.getHours().toString().padStart(2, '0')}:${alarm.time.getMinutes().toString().padStart(2, '0')}`)
                    .font({ size: 26, weight: FontWeight.Normal })
                    .fontColor("#333333") // 深灰色字体
                }
                else Text(`${new Date(alarm.time).getHours().toString().padStart(2, '0')}:${new Date(alarm.time).getMinutes().toString().padStart(2, '0')}`)
                  .font({ size: 26, weight: FontWeight.Normal })
                  .fontColor("#333333") // 深灰色字体
              }
              .padding({ left: 20 })
              Blank()
              // 将开关和编辑按钮放置在右端
              Row() {
                // 闹钟开关按钮
                Toggle({ type: ToggleType.Switch, isOn: alarm.isEnabled })
                  .onChange((value: boolean) => {
                    this.alarms[index].isEnabled = value
                    AppStorage.SetOrCreate('Alarms', this.alarms)
                  })
                  .size({ width: 50, height: 30 })
                  .alignSelf(ItemAlign.End)

                // 编辑按钮
                Button('编辑')

                  .onClick(() => {
                    this.editAlarm(index) // 进入编辑页面
                  })
                  .backgroundColor('#007BFF')// 蓝色背景
                  .borderRadius(20)
                  .fontColor('#FFFFFF')// 白色字体
                  .padding({
                    top: 8,
                    bottom: 8,
                    left: 20,
                    right: 20
                  })
                  .alignSelf(ItemAlign.End)
                  .align(Alignment.End) // 调整按钮内边距
              }
              .justifyContent(FlexAlign.End)  // 将子组件排列到右端
              .align(Alignment.End) // 保证开关和按钮垂直居中
              .alignItems(VerticalAlign.Bottom)
              .alignSelf(ItemAlign.End)
            }
            .padding({ top: 10, bottom: 10 }) // 为每个 ListItem 增加上下内边距
            .border({ color: '#E0E0E0', width: 1, radius: 8 }) // 圆角边框
            .borderRadius(20)
            .shadow({
              radius: 10,
              color: Color.Gray,
              offsetX: 0,
              offsetY: 2
            }) // 增加阴影
            .justifyContent(FlexAlign.End)
            .width('100%') // 确保 ListItem 宽度为 100%，填满父容器
            .backgroundColor('#FFF')
            .alignSelf(ItemAlign.End) // 白色背景
          }
        }, (item: Alarm) => JSON.stringify(item)) // 确保每项的唯一性
      }
      .divider({
        strokeWidth: 1,
        startMargin: 10,
        endMargin: 60,
        color: '#ffe9f0f0'
      })
      .width('100%') // 设置 List 宽度为 100%
    }
  }

  // 添加新的闹钟，跳转到编辑页面
  addNewAlarm() {
    this.selectedAlarmIndex = -1 // 新增闹钟时没有选择现有闹钟

    this.EditTitle = '添加闹钟'
    this.editingTime = new Date() // 默认选择当前时间
    this.editingLabel = '通知吃饭' // 设置默认标签
    this.editingNote = '提醒您，现在是餐点时间，快来吃饭吧！' // 设置默认备注
    this.dialogController.open()
  }

  // 编辑现有闹钟，跳转到编辑页面
  editAlarm(index: number) {
    this.selectedAlarmIndex = index
    this.EditTitle = '编辑闹钟'
    const alarm = this.alarms[index]
    this.editingTime = new Date(alarm.time)
    this.editingLabel = alarm.label
    this.editingNote = alarm.note
    this.dialogController.open()
  }

  // 保存编辑后的闹钟
  saveEditedAlarm() {
    if (this.selectedAlarmIndex === -1) {
      // 新添加的闹钟
      const newAlarm: Alarm = {
        time: this.editingTime,
        label: this.editingLabel,
        isEnabled: true,
        note: this.editingNote,
        id: 0
      };
      (this.alarms as Alarm[]).push(newAlarm);
      AppStorage.SetOrCreate('Alarms', this.alarms as Alarm[])
      this.scheduleNotification(newAlarm); // 发布通知
    } else {
      // 编辑现有的闹钟
      const editedAlarm = this.alarms[this.selectedAlarmIndex];
      editedAlarm.time = this.editingTime;
      editedAlarm.label = this.editingLabel;
      editedAlarm.note = this.editingNote;
      this.alarms = [...this.alarms];
      AppStorage.SetOrCreate('Alarms', this.alarms)
      this.scheduleNotification(editedAlarm); // 更新通知
    }
  }

  // 删除闹钟
  deleteAlarm() {
    if (this.selectedAlarmIndex !== -1) this.alarms.splice(this.selectedAlarmIndex, 1);
    AppStorage.SetOrCreate('Alarms', this.alarms)
    this.selectedAlarmIndex == -1
  }

  // 发布通知
  scheduleNotification(alarm: Alarm) {
    const notifyTime = alarm.time.getTime() - new Date().getTime(); // 计算到通知时间的毫秒数

    if (notifyTime > 0) { // 检查时间是否在未来
      // 使用 setTimeout 在指定的时间发布通知
      setTimeout(() => {
        const notificationTitle = `闹钟提醒: ${alarm.label}`;
        const notificationContent = alarm.note;
        // 设置通知的内容类型
        let publishCallback = (err: BusinessError): void => {
          if (err) {
            console.error(`publish failed, code is ${err.code}, message is ${err.message}`);
          } else {
            console.info("publish success");
          }
        }
        let notificationRequest: notificationManager.NotificationRequest = {
          id: alarm.id as number, // 使用传入的 alarm.id 作为通知 ID
          content: {
            notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
            normal: {
              title: notificationTitle,
              text: notificationContent, // 这里用 alarm.note 作为通知的具体内容
            }
          }
        };
        notificationManager.publish(notificationRequest, publishCallback);
        alarm.isEnabled=false
        // 发布通知
      }, notifyTime);
    } else {
      console.warn("设置的时间已经过去");
    }
  }

}