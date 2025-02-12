import sys
import tkinter as tk
from tkinter import ttk
import os
import numpy as np
from PIL import ImageTk, Image
import pandas as pd
import time
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.options import Options #设置代理
from pyquery import PyQuery as pq
from urllib.parse import quote
import jieba
from jieba import analyse
import matplotlib.pyplot as plt
from wordcloud import WordCloud


global KEYWORD
global COLOUR
global SHAPE
global HIDEWORD

PAGE_NUM = 3            # 爬取页数
global product_all
product_all = pd.DataFrame()
#设置代理
chrome_options = Options()
chrome_options.add_argument('--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36')
browser = webdriver.Chrome(options=chrome_options)
#browser = webdriver.Chrome()
wait=WebDriverWait(browser, 10)

class MainWindow(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("淘宝商品信息爬取与可视化分析")
        self.frame1 = Frame1(self)
        self.frame2 = Frame2(self)
        self.frame3 = Frame3(self)
        self.frame_wordcloud = FrameWordCloud(self)
        self.show_frame1()

    def show_frame1(self):
        self.geometry("1000x900")
        self.frame2.place_forget()
        self.frame3.place_forget()
        self.frame_wordcloud.pack_forget()
        self.frame1.place(x=0, y=0, height=250, width=250)

    def show_frame2(self):
        self.geometry("1000x900")
        self.frame1.place_forget()
        self.frame3.place_forget()
        self.frame_wordcloud.pack_forget()
        self.frame2.place(x=0, y=0, height=250, width=250)

    def show_frame3(self):
        self.geometry("1000x900")
        self.frame1.place_forget()
        self.frame2.place_forget()
        self.frame_wordcloud.pack_forget()
        self.frame3.place(x=0, y=0, height=250, width=250)

    def show_frame_wordcloud(self):
        self.geometry("1000x900")
        self.frame_wordcloud = FrameWordCloud(self)
        self.frame1.place_forget()
        self.frame2.place_forget()
        self.frame3.place_forget()
        self.frame_wordcloud.pack()
class Frame1(tk.Frame):
    def __init__(self, master):
        super().__init__(master)

        self.label = tk.Label(self, text="请输入您要搜索的商品：", font="黑体，80")
        self.label.place(x=1, y=1, height=50, width=220)

        self.text = tk.Text(self, font="黑体，80")
        self.text.place(x=1, y=50, height=25, width=600)

        def getGoodsName():
            global KEYWORD
            KEYWORD = self.text.get('0.0', "end")
            print(KEYWORD)

        self.button_1 = tk.Button(self, text="确认", command=lambda: (getGoodsName(), main(), file_generate(), master.show_frame2()))
        self.button_1.place(x=100, y=110, height=30, width=40)

        self.button_2 = tk.Button(self, text="退出", command=lambda: (browser.close(), sys.exit()))
        self.button_2.place(x=420, y=110, height=30, width=40)
class Frame2(tk.Frame):
    def __init__(self, master):
        super().__init__(master)

        self.label = tk.Label(self, text="请选择您要执行的操作", font="黑体，80")
        self.label.place(x=0, y=0, height=50, width=200)

        self.button_wordCloud = tk.Button(self, text="bilibili、显示词云", font="黑体，50", command=master.show_frame3)
        self.button_wordCloud.place(x=20, y=50, height=30, width=180)

        self.button_title = tk.Button(self, text="2、标题和销量的关系", font="黑体，50", command=chart1)
        self.button_title.place(x=20, y=80, height=30, width=180)

        self.button_shopName = tk.Button(self, text="3、店名和销量的关系", font="黑体，50", command=chart2)
        self.button_shopName.place(x=20, y=110, height=30, width=180)

        self.button = tk.Button(self, text="返回上一级", font="黑体，80", command=master.show_frame1)
        self.button.place(x=58, y=150, height=30, width=100)
class Frame3(tk.Frame):
    def __init__(self, master):
        super().__init__(master)

        self.label = tk.Label(self, text="这是个性化词云界面")
        self.label.pack()

        self.label = tk.Label(self, text="请输入您要隐藏的关键词:", font="黑体，80")
        self.label.place(x=0, y=0, height=50, width=200)

        self.text = tk.Text(self, font="黑体，80")
        self.text.place(x=0, y=40, height=25, width=200)

        colourOption = ["红色", "蓝色", "绿色"]
        shapeOption = ["圆形", "爱心", "矩形"]
        self.combobox1 = ttk.Combobox(self, values=colourOption, font="黑体，80")
        self.combobox1.place(x=30, y=80, height=30, width=60)

        self.combobox2 = ttk.Combobox(self, values=shapeOption, font="黑体，80")
        self.combobox2.place(x=120, y=80, height=30, width=60)

        def getsData():
            global HIDEWORD, COLOUR, SHAPE
            HIDEWORD = self.text.get("0.0", "end").split()
            COLOUR = self.combobox1.get()
            SHAPE = self.combobox2.get()

        self.button_1 = tk.Button(self, text="生成云图", command=lambda: (getsData(), generate_wordcloud('output1.txt'), master.show_frame_wordcloud()))
        self.button_1.place(x=30, y=130, height=30, width=60)

        self.button_2 = tk.Button(self, text="返回上一级", command=master.show_frame2)
        self.button_2.place(x=120, y=130, height=30, width=60)
class FrameWordCloud(tk.Frame):
    def __init__(self, master):
        super().__init__(master)

        self.label = tk.Label(self, text="这是显示词云界面")
        self.label.pack()
        if os.path.isfile("wordcloud.png"):
            self.image = Image.open("wordcloud.png")
            self.image_tk = ImageTk.PhotoImage(self.image)
        else:
            self.image =  None
            self.image_tk = None

        self.label_wordcloud = tk.Label(self, image=self.image_tk)
        self.label_wordcloud.pack()

        self.button = tk.Button(self, text="返回上一级", command=master.show_frame3)
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
        url='https://s.taobao.com/search?q={}'
        #browser.get('https://s.taobao.com/search?commend=all&ie=utf8&initiative_id=tbindexz_20170306&page=1&q={}&search_type=item&sourceId=tb.index&spm=a21bo.jianhua.201856-taobao-item.2&ssid=s5-e'.format(quote(KEYWORD)))
        browser.get(url.format(quote(KEYWORD)))
                    #'https://s.taobao.com/search?q={}&commend=all&ssid=s5-e&search_type=item&sourceId=tb.index&spm=a21bo.jianhua.201856-taobao-item.2&ie=utf8&initiative_id=tbindexz_20210306&page=bilibili'
                    #'https://s.taobao.com/search?commend=all&ie=utf8&initiative_id=tbindexz_20210306&page=1&q=&search_type=item&sourceId=tb.index&spm=a21bo.jianhua.201856-taobao-item.2&ssid=s5-e'
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
    with open('output1.txt', 'r', encoding='utf-8') as f:
        text = f.read()
    words = jieba.cut(text)
    if COLOUR == "红色":
        r = 255
        g = 0
        b = 0
    if COLOUR == "蓝色":
        r = 0
        g = 0
        b = 255
    if COLOUR == "绿色":
        r = 0
        g = 255
        b = 0
    if SHAPE == "圆形":
        mask = np.array(Image.open('circle.png'))
    if SHAPE == "爱心":
        mask = np.array(Image.open('love.png'))
    if SHAPE == "矩形":
        mask = np.array(Image.open('rectangle.png'))

    keywords = HIDEWORD
    words = [word for word in words if word not in keywords]

    def color_func(word, font_size, position, orientation, random_state=None, **kwargs):
        return "rgb({}, {}, {})".format(r, g, b)

    wc = WordCloud(background_color=None, mode='RGBA', width=1600, height=900, color_func=color_func,
                   font_path='方正喵呜体.ttf', mask=mask)
    wc.generate(' '.join(words))
    wc.to_file('wordcloud.png')
def file_generate():
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
    for i in range(0, 4):
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
    plt.bar(x, y)
    plt.title('定价与销量分析')
    plt.show()


if __name__ == "__main__":
    app = MainWindow()
    app.mainloop()