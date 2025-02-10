import { EditableLeftIconType, EditableTitleBar, } from '@ohos.arkui.advanced.EditableTitleBar'
import { promptAction } from '@kit.ArkUI';
import router from '@ohos.router';

@CustomDialog
struct EditNote {
  @Link EditTitle: string
  @Link editingTitle: string
  @Link editingContent: string
  @Link selectedNoteIndex: number
  saveEditedNote: () => void = () => {}
  deleteNote: () => void = () => {}
  controller?: CustomDialogController

  private scrollerForScroll: Scroller = new Scroller()

  build() {
    Column() {
      // 编辑界面顶部导航栏
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Cancel,
        title: this.EditTitle,
        menuItems: [
          {
            isEnabled: true,
            value: $r("app.media.delete"),
            action: () => {
              // 在删除按钮点击时，弹出确认删除对话框
              this.showDeleteConfirmationDialog();
            }
          }
        ],

        onCancel: () => {
          this.controller?.close()
        },
        onSave: () => {
          this.saveEditedNote() // 保存编辑的记事本
          this.controller?.close()
        }
      })
        .height(80)
        .backgroundColor('#F3F4F6') // 浅灰色背景

      // 包裹整个内容区域的滚动容器
      Scroll(this.scrollerForScroll) {
        Column() {
          // 标题输入框
          Column() {
            TextInput({
              text: $$this.editingTitle,
            })
              .padding({ top: 10, bottom: 10 })
              .backgroundColor('#FFF')
              .height(70)
              .borderRadius(20)
              .fontColor('#333333') // 深灰色字体
              .fontSize(30)
          }

          // 内容输入框
          Column() {
            Text('内容')
              .font({ size: 16, weight: FontWeight.Normal })
              .margin({ top: 20 })
            TextArea({
              text: $$this.editingContent,
            })
              .padding({ top: 10, bottom: 20 }) // 增加底部内边距
              .backgroundColor('#FFF')
              .height(450) // 调整为更大的高度（例如：250）
              .borderRadius(20)
              .fontColor('#333333') // 深灰色字体
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .padding({ bottom: 0 })
    .height('100%') // 设置高度为100%，确保占满整个页面
  }

  // 显示删除确认弹窗
  private async showDeleteConfirmationDialog() {
    try {
      const result = await promptAction.showDialog({
        title: '确认删除',
        message: '您确定要删除这个笔记吗？',
        buttons: [
          {
            text: '取消',
            color: '#888888',
          },
          {
            text: '确认删除',
            color: '#FF0000',
          },
        ],
      });

      // 判断用户点击的按钮索引，如果是确认删除则执行删除操作
      if (result.index === 1) { // 如果用户点击的是 "确认删除"
        this.deleteNote(); // 执行删除操作
        this.controller?.close(); // 关闭对话框
      }
    } catch (err) {
      console.error('Dialog error: ', err);
    }
  }
}

interface NotebookPage {
  title: string;
  content: string;
  createdAt: string;  // 记录创建时间
}

PersistentStorage.PersistProp<NotebookPage[]>('notebookPages',[]);
@Entry
@Component
export struct NotebookApp {
  @StorageLink('notebookPages') notebookPages: NotebookPage[] = [] // 记事本页面列表
  @State selectedNoteIndex: number = -1 // 编辑选中的记事本页面
  @State editingTitle: string = '标题' // 页面标题
  @State editingContent: string = '' // 页面内容
  @State EditTitle: string = '添加笔记' // 窗口标题
  @State changeValue: string = '' // 搜索框输入的值
  @State filteredNotes: NotebookPage[] = [] // 存储过滤后的记事本列表
  dialogController: CustomDialogController = new CustomDialogController({
    builder: EditNote({
      saveEditedNote: () => {
        this.saveEditedNote()
      },
      deleteNote: () => {
        this.deleteNote()
      },
      selectedNoteIndex: this.selectedNoteIndex,
      EditTitle: this.EditTitle,
      editingTitle: this.editingTitle,
      editingContent: this.editingContent
    }),
    alignment: DialogAlignment.Bottom,
  })

  // 根据标题或时间进行搜索
  handleSearch() {
    const query = this.changeValue.toLowerCase(); // 将输入转换为小写
    this.filteredNotes = this.notebookPages.filter(note => {
      // 检查标题是否包含查询字符串，或者创建时间的字符串是否包含查询字符串
      return (
        note.title.toLowerCase().includes(query) ||
        new Date(note.createdAt).toLocaleString().includes(query)
      );
    });
  }

  build() {
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

      // 使用 Scroller 来包裹需要滚动的区域
      Scroll() {
        Column() {
          // 主界面导航栏
          EditableTitleBar({
            isSaveIconRequired: false,
            leftIconStyle: 3,
            title: '做菜笔记',
            menuItems: [
              {
                isEnabled: true,
                value: $r("app.media.add"),
                action: () => {
                  this.addNewNote() // 跳转到编辑记事本界面
                }
              }
            ],
            onCancel:()=>{
              router.back()
            }
          })
            .height(60)
            .backgroundColor('#F3F4F6') // 浅灰色背景

          // 搜索框
          Search({
            value: this.changeValue,  // 绑定搜索框的值
            placeholder: '输入日志的标题或时间',
          })
            .searchButton('搜索')
            .searchIcon({
              src: $r('app.media.search')
            })
            .onChange((value: string) => {  // onChange 事件接收输入框的值
              this.changeValue = value;  // 更新搜索框的值
              this.handleSearch();  // 处理搜索操作
            })
            .cancelButton({
              style: CancelButtonStyle.CONSTANT,
              icon: {
                src: $r('app.media.cancel')
              }
            })
            .width('90%')
            .height(40)
            .maxLength(20)
            .backgroundColor('#F5F5F5')
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: 14, weight: 400 })
            .textFont({ size: 14, weight: 400 })

          // 记事本页面列表
          List({ space: 10 }) {
            ForEach(this.filteredNotes.length > 0 ? this.filteredNotes : this.notebookPages, (note: NotebookPage, index: number) => {
              ListItem() {
                Row() {
                  Column() {
                    // 显示页面标题
                    Text(note.title || '无标题')
                      .font({ size: 24, weight: FontWeight.Medium }) // 字体更合适，视觉更舒适
                      .fontColor('#2C3E50') // 深灰色，略带蓝色调，提升可读性
                      .margin({ left: 0 })
                      .padding({ left: 10, top: 5, bottom: 5 }) // 增加上下内边距，使标题不拥挤

                    // 显示前十个字（右对齐）
                    Text(note.content?.slice(0, 10) || '暂无内容')
                      .font({ size: 12, weight: FontWeight.Normal })
                      .fontColor('#7F8C8D') // 浅灰色字体
                      .padding({ top: 5, left: 10 })
                      .alignSelf(ItemAlign.Start); // 内容右对齐
                  }
                  // 显示创建时间
                  Text(` ${new Date(note.createdAt).toLocaleString()}`)
                    .font({ size: 12, weight: FontWeight.Normal })
                    .fontColor('#7F8C8D')  // 浅灰色字体
                    .padding({ top: 0, bottom: 20, left: 10 })
                }
                .padding({ top: 10, bottom: 10 }) // 为每个 ListItem 增加上下内边距
                .shadow({
                  radius: 6,
                  color: Color.Gray,
                  offsetX: 0,
                  offsetY: 2
                }) // 微调阴影，避免过于突兀
                .justifyContent(FlexAlign.Start) // 保持标题对齐方式
                .width('100%') // 确保 ListItem 宽度为 100%，填满父容器
                .backgroundColor('#FFF') // 白色背景
                .alignSelf(ItemAlign.Start) // 保持左对齐，避免多余的空白
                .onClick(() => {
                  this.editNote(index); // 点击进入编辑页面
                })
              }
            }, (item: NotebookPage) => JSON.stringify(item)) // 确保每项的唯一性
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
      }
    }
  }

  // 添加新的记事本页面
  addNewNote() {
    this.selectedNoteIndex = -1 // 新增页面时没有选择现有页面
    this.EditTitle = '添加笔记'
    this.editingTitle = '标题' // 设置默认标题
    this.editingContent = '今天又是美好的一天，有什么想要记录的吗？' // 设置默认内容
    this.dialogController.open()
  }

  // 编辑记事本页面
  editNote(index: number) {
    this.selectedNoteIndex = index
    const selectedNote = this.notebookPages[index]
    this.editingTitle = selectedNote.title || '新页面'
    this.editingContent = selectedNote.content || ''
    this.EditTitle = '编辑笔记'
    this.dialogController.open()
  }

  // 保存编辑的记事本
  saveEditedNote() {
    const currentTime = new Date().toISOString();  // 获取当前时间并转化为 ISO 格式字符串
    if (this.selectedNoteIndex === -1) {
      // 新增的记事本
      const newNote: NotebookPage = {
        title: this.editingTitle,
        content: this.editingContent,
        createdAt: currentTime,
      };
      this.notebookPages.push(newNote);
    } else {
      // 编辑现有的记事本
      this.notebookPages[this.selectedNoteIndex].title = this.editingTitle;
      this.notebookPages[this.selectedNoteIndex].content = this.editingContent;
      this.notebookPages = [...this.notebookPages];
    }
    AppStorage.SetOrCreate('notebookPages', this.notebookPages); // 保存数据到本地存储
  }

  // 删除记事本页面
  deleteNote() {
    if (this.selectedNoteIndex !== -1) {
      this.notebookPages.splice(this.selectedNoteIndex, 1);
    }
    AppStorage.SetOrCreate('notebookPages', this.notebookPages); // 保存数据到本地存储
  }
}

