import random

# 定义地区和行业
regions = ['北京', '上海', '广州', '深圳', '杭州', '武汉', '西安', '香港', '成都', '青岛']
industries = ['金融', '科技', '制造', '医疗', '零售', '物流']

# 定义起始和结束年份
start_year = 2015
end_year = 2025

# 定义生成的SQL语句数量
num_entries_per_year = 20

# 打开文件写入生成的SQL语句
with open('insert_data.sql', 'w', encoding='utf-8') as file:
    for year in range(start_year, end_year + 1):
        file.write(f"INSERT INTO [dbo].[历史数据] ([地区], [行业], [时间]) VALUES\n")
        for i in range(num_entries_per_year):
            region = random.choice(regions)
            industry = random.choice(industries)
            # 判断是否为最后一行，不加逗号
            if i == num_entries_per_year - 1:
                file.write(f"('{region}', '{industry}', {year});\n\n")
            else:
                file.write(f"('{region}', '{industry}', {year}),\n")
