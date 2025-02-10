# 项目介绍
方向：OS应用程序开发  
所属学校：杭州电子科技大学  
队伍编号：T202410336994272   
队伍名：好好好你说的都队  
队伍成员：郑方昊 郑童瑶 吴博涵  
指导老师：贾刚勇

“爱做饭”是一款旨在满足现代人多元化美食需求的移动应用。随着生活水平的提高，用户不仅追求美味，更注重烹饪过程的乐趣、健康饮食及便捷的购物体验。该应用主要面向美食爱好者、烹饪新手、健康饮食者及家庭采买者，提供一站式服务。

应用核心功能包括：查找菜谱，涵盖从传统佳肴到创意料理，附详细步骤与食材；营养分析功能，用户录入食材后可获取营养成分数据，并与个人饮食目标比对，确保健康摄入；购物清单功能，用户可根据菜谱生成购物清单，便于高效采购；用户可以设置烹饪提醒，系统会在适当的时候通过通知提醒用户，避免忘记重要步骤或时间。提供记事本功能，用户可以随时记录与烹饪相关的想法、心得或其他重要事项，便于随时查看和编辑。提供实用的小贴士，帮助用户改进烹饪技巧，了解如何选择食材、调味和提高烹饪效率。

 
# 目录结构描述
    README.md
    search
    └── entry             
        └── src
            └── main
                └── ets  
                    ├─pages
                    │   ├─Index.ets                         //主界面
                    │   ├─Kitchen.ets                       //厨房宝典 
                    │   ├─Login.ets                         //登录界面
                    │   ├─Me.ets                            //我的界面
                    │   ├─NoteBook.ets                      //记事本界面
                    │   ├─NutritionAnalyze.ets              //营养分析界面
                    │   ├─PersonalInformation.ets           //个人信息界面
                    │   ├─RecipeDetail.ets                  //菜谱详情界面
                    │   ├─Reminder.ets                      //设置提醒界面
                    │   ├─SearchAPI.ets                     //菜谱查询界面(基于http请求API实现)  
                    │   ├─SearchRecipe.ets                  //菜谱查询界面(基于本地数据查询)
                    │   └─TodoList.ets                      //食材清单界面
                    ├─model
                    │   └─Food.ets                          //包含一些数据结构
                    ├─entrybackupability
                    │         └─EntryBackupAbility.ets
                    └─entryability
                           └─EntryAbility.ets
                    

# 文档&视频
[过程性日志(含关键代码)](/过程性日志.pdf)  
[设计文档](/设计文档.pdf)  
[演示视频](https://www.bilibili.com/video/BV1vhkRYbEJa/?vd_source=329a579498c16dcea4ea18843e014432)  
  
 
 

 
 
