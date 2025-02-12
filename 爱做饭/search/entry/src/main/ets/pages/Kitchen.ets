import { EditableTitleBar } from '@kit.ArkUI'
import router from '@ohos.router';

@Entry
@Component
export struct InfoPage {
  build() {
    Column() {
      // 主界面导航栏
      EditableTitleBar({
        isSaveIconRequired: false,
        leftIconStyle: 3,
        title: '厨房宝典',  // 修改标题
        menuItems: [],
        onCancel:()=> {
          router.back()
        }
      })
        .height(60)
        .backgroundColor('#F3F4F6') // 浅灰色背景
        .borderRadius(10)  // 添加圆角，提升视觉效果

      // Tabs 分类容器
      Tabs() {
        // 第一个标签页 - 常见厨具使用方法
        TabContent() {
          Column() {
            Text('常见厨具使用方法')
              .fontSize(24)
              .fontWeight('bold')
              .margin({ top: 10, bottom: 10 })  // 缩小顶部间距，保持紧凑感

            // 列表渲染厨具使用方法
            List() {
              ListItemGroup({ header: this.itemHead('空气炸锅') }) {
                ListItem() { Text('适用于快速低脂炸物。优点：低油，快速，方便；缺点：食物表面可能不够脆。') }
              }
              ListItemGroup({ header: this.itemHead('电饭锅') }) {
                ListItem() { Text('用于煮米饭。优点：简单，节能，保持米饭温暖；缺点：仅限于煮饭使用。') }
              }
              ListItemGroup({ header: this.itemHead('慢炖锅') }) {
                ListItem() { Text('适用于慢炖汤或炖肉。优点：无需频繁监控，肉类更入味；缺点：需要长时间烹饪。') }
              }
              ListItemGroup({ header: this.itemHead('烤箱') }) {
                ListItem() { Text('适用于烘烤蛋糕、面包和烤肉。优点：多功能；缺点：需要预热和清洁。') }
              }
              ListItemGroup({ header: this.itemHead('搅拌机') }) {
                ListItem() { Text('用于制作奶昔和搅拌食材。优点：快速方便；缺点：清洗麻烦。') }
              }
              ListItemGroup({ header: this.itemHead('微波炉') }) {
                ListItem() { Text('用于加热食物。优点：快捷方便；缺点：可能会使食物口感变化。') }
              }
              ListItemGroup({ header: this.itemHead('食物处理机') }) {
                ListItem() { Text('用于切割、切丝、切块。优点：节省时间；缺点：体积大，存储困难。') }
              }
              ListItemGroup({ header: this.itemHead('电磁炉') }) {
                ListItem() { Text('用于快速加热和烹饪。优点：高效节能；缺点：需要配套专用锅具。') }
              }
              ListItemGroup({ header: this.itemHead('压面机') }) {
                ListItem() { Text('用于擀面。优点：省力，面皮更均匀；缺点：较占空间。') }
              }
              ListItemGroup({ header: this.itemHead('空气清新机') }) {
                ListItem() { Text('用于净化厨房空气。优点：清新空气；缺点：需要定期更换滤网。') }
              }
              ListItemGroup({ header: this.itemHead('电热水壶') }) {
                ListItem() { Text('用于快速加热水。优点：加热迅速；缺点：可能会损失水分。') }
              }
            }
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 100,
              color: '#ECF0F1'  // 柔和的灰白色
            })
            .padding({ left: 20, right: 20, top: 0, bottom: 20 })  // 增加内边距
            .backgroundColor('#FFFAE1')  // 统一背景色
            .borderRadius(15)  // 圆角效果，减小圆角
            .margin({ bottom: 20 })  // 标签间距，保持间隔清晰
            .scrollBar(BarState.Auto)
          }
        }
        .tabBar('常见厨具')
        .backgroundColor('#F9F9F9')

        // 第二个标签页 - 食材保存建议
        TabContent() {
          Column() {
            Text('食材保存建议')
              .fontSize(24)
              .fontWeight('bold')
              .margin({ top: 10 ,bottom:10})   // 缩小顶部间距，保持紧凑感

            List() {
              ListItemGroup({ header: this.itemHead('蔬菜') }) {
                ListItem() { Text('大多数蔬菜应存放在冰箱的蔬菜抽屉中，避免潮湿。') }
              }
              ListItemGroup({ header: this.itemHead('肉类') }) {
                ListItem() { Text('生肉应存放在冰箱冷藏区，若不立即食用可冷冻保存。') }
              }
              ListItemGroup({ header: this.itemHead('谷物') }) {
                ListItem() { Text('保持干燥阴凉处，密封存储防虫害。') }
              }
              ListItemGroup({ header: this.itemHead('奶制品') }) {
                ListItem() { Text('存放在冰箱冷藏区，开封后尽快食用。') }
              }
              ListItemGroup({ header: this.itemHead('水果') }) {
                ListItem() { Text('水果通常应存放在室温下，避免存放在塑料袋中。') }
              }
              ListItemGroup({ header: this.itemHead('面包') }) {
                ListItem() { Text('应存放在阴凉干燥处，保持面包的新鲜度。') }
              }
              ListItemGroup({ header: this.itemHead('坚果') }) {
                ListItem() { Text('坚果应存放在密封袋中，并保持干燥，避免潮湿。') }
              }
              ListItemGroup({ header: this.itemHead('巧克力') }) {
                ListItem() { Text('巧克力应存放在阴凉干燥处，避免高温。') }
              }
              ListItemGroup({ header: this.itemHead('调味料') }) {
                ListItem() { Text('调味料应密封存放，避免受潮影响质量。') }
              }
              ListItemGroup({ header: this.itemHead('冷冻食品') }) {
                ListItem() { Text('冷冻食品应尽量避免反复解冻，以保持其品质。') }
              }
              ListItemGroup({ header: this.itemHead('茶叶') }) {
                ListItem() { Text('茶叶应存放在干燥阴凉处，并密封保存，避免受潮。') }
              }
              ListItemGroup({ header: this.itemHead('蛋类') }) {
                ListItem() { Text('蛋类应存放在冰箱中，避免温度波动。') }
              }
            }
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 100,
              color: '#ECF0F1'  // 柔和的灰白色
            })
            .padding({ left: 20, right: 20, top: 0, bottom: 20 })
            .backgroundColor('#FFFAE1')
            .borderRadius(15)
            .margin({ bottom: 20 })
            .scrollBar(BarState.Auto)
          }
        }
        .tabBar('食材保存')

        // 第三个标签页 - 清洁小贴士
        TabContent() {
          Column() {
            Text('清洁小贴士')
              .fontSize(24)
              .fontWeight('bold')
              .margin({ top: 10 ,bottom:10})

            List() {
              ListItemGroup({ header: this.itemHead('锅具') }) {
                ListItem() { Text('使用软海绵和中性清洁剂，清洗后及时擦干。') }
              }
              ListItemGroup({ header: this.itemHead('砧板') }) {
                ListItem() { Text('木质砧板避免浸泡，塑料砧板可用洗碗机清洗。') }
              }
              ListItemGroup({ header: this.itemHead('冰箱') }) {
                ListItem() { Text('定期清理冰箱，避免食物过期。') }
              }
              ListItemGroup({ header: this.itemHead('水槽') }) {
                ListItem() { Text('水槽应定期使用白醋清洗，保持无异味。') }
              }
              ListItemGroup({ header: this.itemHead('灶台') }) {
                ListItem() { Text('灶台应保持清洁，油渍及时清理，避免积聚。') }
              }
              ListItemGroup({ header: this.itemHead('微波炉') }) {
                ListItem() { Text('微波炉可用湿布清洁内部，避免食物残留。') }
              }
              ListItemGroup({ header: this.itemHead('蒸锅') }) {
                ListItem() { Text('蒸锅应定期清洁，防止水垢积累。') }
              }
              ListItemGroup({ header: this.itemHead('烤箱') }) {
                ListItem() { Text('烤箱在使用后要及时清理食物残渣，避免油脂积累。') }
              }
              ListItemGroup({ header: this.itemHead('炊具') }) {
                ListItem() { Text('煮饭锅使用后应清洗内胆，避免米粒残留。') }
              }
              ListItemGroup({ header: this.itemHead('电饭煲') }) {
                ListItem() { Text('电饭煲使用后需定期清理，避免底部积炭。') }
              }
              ListItemGroup({ header: this.itemHead('刀具') }) {
                ListItem() { Text('刀具使用后应擦干并妥善保管，避免生锈。') }
              }
              ListItemGroup({ header: this.itemHead('厨房地面') }) {
                ListItem() { Text('地面应定期清扫，避免油渍和食物残渣堆积。') }
              }
              ListItemGroup({ header: this.itemHead('菜刀') }) {
                ListItem() { Text('菜刀应定期磨锋，保持锋利，避免刮伤食材。') }
              }
              ListItemGroup({ header: this.itemHead('厨房窗户') }) {
                ListItem() { Text('窗户应定期清洁，保持通透，避免油烟积聚。') }
              }
              ListItemGroup({ header: this.itemHead('厨房垃圾桶') }) {
                ListItem() { Text('垃圾桶应定期清洗，避免臭味和细菌滋生。') }
              }
              ListItemGroup({ header: this.itemHead('食物储藏柜') }) {
                ListItem() { Text('储藏柜应保持干燥，避免潮湿和霉菌生长。') }
              }
            }
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 100,
              color: '#ECF0F1'  // 柔和的灰白色
            })
            .padding({ left: 20, right: 20, top: 0, bottom: 20 })
            .backgroundColor('#FFFAE1')
            .borderRadius(15)
            .margin({ bottom: 20 })
            .scrollBar(BarState.Auto)
          }
          .alignSelf(ItemAlign.Start)
        }

        .tabBar('清洁贴士')

        // 第四个标签页 - 烹饪小技巧
        TabContent() {
          Column() {
            Text('烹饪小技巧')
              .fontSize(24)
              .fontWeight('bold')
              .margin({ top: 10 ,bottom:10})

            List() {
              ListItemGroup({ header: this.itemHead('炒菜') }) {
                ListItem() { Text('大火快炒，保持食材鲜脆。') }
              }
              ListItemGroup({ header: this.itemHead('煮汤') }) {
                ListItem() { Text('先大火煮沸，再小火慢炖以增加风味。') }
              }
              ListItemGroup({ header: this.itemHead('烤肉') }) {
                ListItem() { Text('提前腌制，使肉质更入味。') }
              }
              ListItemGroup({ header: this.itemHead('炒饭') }) {
                ListItem() { Text('炒饭时，米饭应事先冷藏，避免炒制过程中粘连。') }
              }
              ListItemGroup({ header: this.itemHead('蒸菜') }) {
                ListItem() { Text('蒸菜时，水温要适中，确保营养保留。') }
              }
              ListItemGroup({ header: this.itemHead('焖饭') }) {
                ListItem() { Text('用电饭锅焖饭时，加入一些配料使饭更香。') }
              }
              ListItemGroup({ header: this.itemHead('炸食') }) {
                ListItem() { Text('油温需保持在适当范围，避免食物吸油过多。') }
              }
              ListItemGroup({ header: this.itemHead('煎蛋') }) {
                ListItem() { Text('煎蛋时可以在锅中加少量水，蛋黄更嫩滑。') }
              }
              ListItemGroup({ header: this.itemHead('炖牛肉') }) {
                ListItem() { Text('炖牛肉时，加入少量啤酒可以让肉质更加鲜嫩。') }
              }
              ListItemGroup({ header: this.itemHead('煮面条') }) {
                ListItem() { Text('煮面时，加入一点盐可以让面条更加有劲道。') }
              }
              ListItemGroup({ header: this.itemHead('烤蔬菜') }) {
                ListItem() { Text('烤蔬菜时，提前撒上一层橄榄油和香料，味道更加丰富。') }
              }
              ListItemGroup({ header: this.itemHead('煮饺子') }) {
                ListItem() { Text('煮饺子时，加一点盐能保持皮薄且不破。') }
              }
            }
            .divider({
              strokeWidth: 1,
              startMargin: 10,
              endMargin: 100,
              color: '#ECF0F1'  // 柔和的灰白色
            })
            .padding({ left: 20, right: 20, top: 0, bottom: 20 })
            .backgroundColor('#FFFAE1')
            .borderRadius(15)
            .margin({ bottom: 20 })
            .scrollBar(BarState.Auto)
          }
        }
        .tabBar('烹饪技巧')
      }
    }
    .alignRules({
      center: { anchor: '__container__', align: VerticalAlign.Center },
      middle: { anchor: '__container__', align: HorizontalAlign.Center }
    })
  }

  @Builder itemHead(text: string) {
    // 列表分组的头部组件
    Text(text)
      .fontSize(16)
      .fontWeight('bold')
      .padding({ top: 10, bottom: 5 })
  }
}
