import tkinter as tk
from PIL import ImageTk, Image
global KEYWORD
import pandas as pd
import time
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pyquery import PyQuery as pq
from urllib.parse import quote
import jieba
from jieba import analyse
import matplotlib.pyplot as plt
from wordcloud import WordCloud

global KEYWORD
PAGE_NUM=3            #爬取页数
global product_all
product_all = pd.DataFrame()

browser = webdriver.Chrome()
wait=WebDriverWait(browser, 10)
class MainWindow(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("界面切换示例")

        self.frame1 = Frame1(self)
        self.frame2 = Frame2(self)
        self.frame_wordcloud = FrameWordCloud(self)
        self.show_frame1()

    def show_frame1(self):
        self.frame2.pack_forget()
        self.frame_wordcloud.pack_forget()
        self.frame1.pack()

    def show_frame2(self):
        self.frame1.pack_forget()
        self.frame_wordcloud.pack_forget()
        self.frame2.pack()

    def show_frame_wordcloud(self):
        self.frame_wordcloud = FrameWordCloud(self)
        self.frame1.pack_forget()
        self.frame2.pack_forget()
        self.frame_wordcloud.pack()


class Frame1(tk.Frame):
    def __init__(self, master):
        super().__init__(master)

        self.label = tk.Label(self, text="这是第一个界面")
        self.label.pack()

        self.text = tk.Text(self)
        self.text.pack()

        def getGoodsName():
            global KEYWORD
            KEYWORD = self.text.get('0.0',"end")
            print(KEYWORD)

        self.button = tk.Button(self, text="确认", command=lambda: (getGoodsName(), main(), file_construct(), generate_wordcloud(
            'output1.txt'), master.show_frame2()))
        self.button.pack()


class Frame2(tk.Frame):
    def __init__(self, master):
        super().__init__(master)

        self.label = tk.Label(self, text="这是第二个界面")
        self.label.pack()

        self.button_wordCloud = tk.Button(self, text="显示词云", command=master.show_frame_wordcloud)
        self.button_wordCloud.pack()

        self.button_title = tk.Button(self, text="标题和销量的关系", command=chart1)
        self.button_title.pack()

        self.button_shopName = tk.Button(self, text="店名和销量的关系", command=chart2)
        self.button_shopName.pack()

        self.button_price = tk.Button(self, text="定价和销量的关系", command=master.show_frame1)
        self.button_wordCloud.pack()

        self.button = tk.Button(self, text="返回上一级", command=master.show_frame1)
        self.button.pack()


class FrameWordCloud(tk.Frame):
    def __init__(self, master):
        super().__init__(master)

        self.label = tk.Label(self, text="这是第显示词云界面")
        self.label.pack()

        self.image = Image.open("wordcloud.png")
        self.image_tk = ImageTk.PhotoImage(self.image)

        self.label_wordcloud = tk.Label(self, image=self.image_tk)
        self.label_wordcloud.pack()

        self.button = tk.Button(self, text="返回上一级", command=master.show_frame2)
        self.button.pack()

def get_products():
    # 判断元素是否已经加载下来
    global product_all
    print(product_all)
    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-itemlist .items .item')))
    html=browser.page_source
    doc=pq(html)
    items=doc("#mainsrp-itemlist .items .item").items()
    for item in items:
        data=[]
        data.append({
            # 'image': item.find('.pic .img').attr('src'),
            'title': item.find('.title').text(),
            'price': item.find('.price').text(),
            'deal': item.find('.deal-cnt').text()[:-3],
            'location': item.find('.location').text(),
            'shop': item.find('.shop').text()
        })
        product=pd.DataFrame(data)
        product_all=product_all._append(product,ignore_index=True)

def search():

    print('正在搜素...')
    try:
        #browser.get('https://s.taobao.com/search?commend=all&ie=utf8&initiative_id=tbindexz_20170306&page=1&q={}&search_type=item&sourceId=tb.index&spm=a21bo.jianhua.201856-taobao-item.2&ssid=s5-e'.format(quote(KEYWORD)))
        browser.get('https://s.taobao.com/search?q={}&commend=all&ssid=s5-e&search_type=item&sourceId=tb.index&spm=a21bo.jianhua.201856-taobao-item.2&ie=utf8&initiative_id=tbindexz_20210306&page=bilibili'.format(quote(KEYWORD)))
                    #'https://s.taobao.com/search?commend=all&ie=utf8&initiative_id=tbindexz_20210306&page=1&q=%E7%8E%A9%E5%85%B7&search_type=item&sourceId=tb.index&spm=a21bo.jianhua.201856-taobao-item.2&ssid=s5-e'
        page_num=PAGE_NUM

        get_products()      # 获取页面详情
        return page_num
    except TimeoutException:
        return search()


# 获取下页
def next_page(page_number):

    print('正在翻页%s', page_number)
    time.sleep(3)
    try:
        input = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "#mainsrp-pager > div > div > div > div.form > input")))
        submit = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.form > span.btn.J_Submit')))
        input.clear()
        input.send_keys(page_number)
        submit.click()
        wait.until(EC.text_to_be_present_in_element((By.CSS_SELECTOR,'#mainsrp-pager > div > div > div > ul > li.item.active > span'),str(page_number)))
        get_products()
    except TimeoutException:
        next_page(page_number)

# 解析页面
def generate_wordcloud(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        text = f.read()
    words = jieba.cut(text)

    #mask = np.array(Image.open('logo.jpg'))
    wc = WordCloud(background_color=None, mode='RGBA', width=1600, height=900, font_path='方正喵呜体.ttf')
    wc.generate(' '.join(words))
    wc.to_file('wordcloud.png')

def file_construct():
    product_all.to_excel('taobao.xlsx', index=False)
    df = pd.read_excel('taobao.xlsx', sheet_name='Sheet1')
    column_data = df['title']
    with open('output1.txt', 'w', encoding='utf-8') as file:
        for data in column_data:
            file.write(str(data) + '\r\n')
    column_data = df['shop']
    with open('output2.txt', 'w', encoding='utf-8') as file:
        for data in column_data:
            file.write(str(data) + '\r\n')
def main():
    try:
        page_num=search()
        for i in range(2,page_num+1):
            next_page(i)
    except Exception:
        print('出错啦')



#分析关键词
def chart1():
    with open('output1.txt', 'r', encoding='utf-8') as f:
        text = f.read()
    words = jieba.cut(text)
    print("分词结果：", "/".join(words))
    keywords = analyse.extract_tags(text, topK=8)
    print("关键词：", ", ".join(keywords))
    df = pd.read_excel('taobao.xlsx')
    x=[]
    y=[]
    for i in range(0,8):
        print(keywords[i])
        x.append(keywords[i])
        filtered_df = df[df['title'].str.contains(keywords[i])]
        filtered_df['deal']=pd.to_numeric(filtered_df['deal'].str.replace('万', '0000').str.replace('+', ''))
        filtered_df.to_excel('chart.xlsx', index=False)
        print(filtered_df['deal'])
        y.append(filtered_df['deal'].sum())
    print(x)
    print(y)
    plt.rcParams['font.sans-serif'] = ['SimHei']
    plt.bar(x,y)
    plt.title('关键词与销量分析')
    plt.show()

def chart2():
    with open('output2.txt', 'r', encoding='utf-8') as f:
        text = f.read()
    words = jieba.cut(text)
    print("分词结果：", "/".join(words))
    keywords = analyse.extract_tags(text, topK=4)
    print("关键词：", ", ".join(keywords))
    df = pd.read_excel('taobao.xlsx')
    x=[]
    y=[]
    for i in range(0,4):
        print(keywords[i])
        x.append(keywords[i])
        filtered_df = df[df['shop'].str.contains(keywords[i])]
        filtered_df['deal']=pd.to_numeric(filtered_df['deal'].str.replace('万', '0000').str.replace('+', ''))
        filtered_df.to_excel('chart.xlsx', index=False)
        print(filtered_df['deal'])
        y.append(filtered_df['deal'].sum())
    print(x)
    print(y)
    plt.rcParams['font.sans-serif'] = ['SimHei']
    plt.bar(x,y)
    plt.title('定价与销量分析')
    plt.show()


if __name__ == "__main__":
    app = MainWindow()
    app.mainloop()