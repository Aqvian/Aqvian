from flask import Flask, request, jsonify, send_from_directory, \
    redirect, url_for, session, url_for, render_template
import pyodbc
import os
from datetime import datetime
import matplotlib.pyplot as plt
from io import BytesIO
import base64
import uuid


app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'fallback_secret_key')


plt.rcParams['font.sans-serif'] = ['SimHei']  # 黑体
plt.rcParams['axes.unicode_minus'] = False
# 配置数据库连接
conn_str = (
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=WBH;'
    'DATABASE=WY;'
    'UID=test;'
    'PWD=111111'
)
# 提供静态文件服务
@app.route('/')
def index():
    return send_from_directory('static', 'hdulogin.html')
@app.route('/query.html')
def query():
    return send_from_directory('static', 'query.html')
# 登录路由
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'success': False, 'message': '用户名和密码不能为空'}), 400

    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Users WHERE username = ? AND password = ?", (username, password))
        user = cursor.fetchone()

    if user:
        session['username'] = user[0]  # user[0] 是 username
        session['role'] = user[1]  # user[1] 是 role
        return jsonify({'success': True, 'redirect_url': '/query.html'}), 200
    else:
        return jsonify({'success': False, 'message': '登录失败，请检查用户名和密码'}), 401
# 查询客户信息路由
@app.route('/query', methods=['POST'])
def query_client():
    data = request.json
    client_name = data.get('clientName', '')

    query = """
        SELECT ci.客户名 AS clientName,
               ci.行业 AS industry,
               ci.地区 AS region,
               CASE WHEN wykh.违约客户 IS NOT NULL THEN '是' ELSE '否' END AS isViolated
        FROM CustomerInfo ci
        LEFT JOIN wykh ON ci.客户名 = wykh.违约客户
        WHERE ci.客户名 LIKE ?
    """

    params = [f'%{client_name}%']

    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        cursor.execute(query, params)
        rows = cursor.fetchall()

    result = []
    for row in rows:
        result.append({
            'clientName': row.clientName,
            'industry': row.industry,
            'region': row.region,
            'isViolated': row.isViolated
        })

    if result:
        return jsonify(result), 200
    else:
        return jsonify([]), 200  # 返回空数组表示未找到
#查找所有违约客户
@app.route('/wykh', methods=['GET'])
def get_all_clients():
    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT 违约客户, 认定违约原因, 严重程度, 认定人, 认定申请时间 FROM wykh")
        rows = cursor.fetchall()

    # 构造返回的数据结构
    client_data = []
    for row in rows:
        # 直接使用 datetime 对象，不需要解码
        formatted_time = row[4].strftime('%Y-%m-%d %H:%M:%S') if row[4] else None

        client_data.append({
            '违约客户': row[0],
            '认定违约原因': row[1],
            '严重程度': row[2],
            '认定人': row[3],
            '认定申请时间': formatted_time
        })

    return jsonify(client_data)
@app.route('/getAuditData', methods=['POST'])
def get_audit_data():
    data = request.json
    client_name = data.get('clientName')
    audit_status = data.get('auditStatus')

    # 更新 SQL 查询语句以包含“审核结果”字段
    query = """
        SELECT 客户名称, 最新外部等级, 违约原因, 违约严重性, 备注信息, 审核状态, 审核结果 
        FROM rdsh 
        WHERE 1=1
    """
    params = []

    if client_name:
        query += " AND 客户名称 LIKE ?"
        params.append('%' + client_name + '%')
    if audit_status and audit_status != 'all':
        query += " AND 审核状态 = ?"
        params.append(audit_status)

    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        cursor.execute(query, params)
        rows = cursor.fetchall()

    result = []
    for row in rows:
        result.append({
            'clientName': row[0],
            'externalRating': row[1],
            'violationReason': row[2],
            'severity': row[3],
            'remarks': row[4],
            'auditStatus': row[5],
            'auditResult': row[6]  # 添加审核结果到结果中
        })

    return jsonify(result)
# 更新审核状态的API
@app.route('/auditClient', methods=['POST'])
def audit_client():
    data = request.json
    client_name = data.get('clientName')
    action = data.get('action')

    # 修正 SQL 查询语句，使用参数占位符
    query = """
        UPDATE rdsh 
        SET 审核状态 = '已审核', 审核结果 = ? 
        WHERE 客户名称 = ?
    """

    try:
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()
            cursor.execute(query, (action, client_name))
            conn.commit()

        if cursor.rowcount > 0:
            return jsonify({'success': True})
        else:
            return jsonify({'success': False}), 400
    except Exception as e:
        print(f"错误：{e}")
        return jsonify({'success': False, 'error': str(e)}), 500
#认定审核的撤回操作
@app.route('/revokeAudit', methods=['POST'])
def revoke_audit():
    data = request.json
    client_name = data.get('clientName')

    # 更新审核状态为“未审核”，并清空审核结果
    query = """
        UPDATE rdsh 
        SET 审核状态 = '未审核', 审核结果 = NULL
        WHERE 客户名称 = ?
    """

    try:
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()
            cursor.execute(query, (client_name,))
            conn.commit()

        if cursor.rowcount > 0:
            return jsonify({'success': True})
        else:
            return jsonify({'success': False}), 400
    except Exception as e:
        print(f"错误：{e}")
        return jsonify({'success': False, 'error': str(e)}), 500
#上传认定申请
@app.route('/submitApplication', methods=['POST'])
def submit_application():
    data = request.form
    client_name = data.get('clientName')
    external_rating = data.get('externalRating')
    violation_reason = data.get('violationReason')
    severity = data.get('severity')
    remarks = data.get('remarks')

    # 处理附件
    attachment = request.files.get('attachment')
    attachment_path = None
    if attachment:
        # 生成唯一文件夹名称（使用时间戳或者UUID）
        folder_name = datetime.now().strftime('%Y%m%d_%H%M%S') + '_' + str(uuid.uuid4())
        folder_path = os.path.join('.attachment', folder_name)

        # 创建文件夹
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)

        # 设置文件保存路径
        attachment_path = os.path.join(folder_path, attachment.filename)

        # 保存文件
        attachment.save(attachment_path)
    # 获取当前时间
    application_time = datetime.now()

    try:
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()

            # 检查是否已存在相同客户名称
            cursor.execute("SELECT COUNT(*) FROM rdsh WHERE 客户名称 = ?", (client_name,))
            exists = cursor.fetchone()[0]

            if exists > 0:
                return jsonify({'success': False, 'message': '该客户名称已存在，不能提交新的申请。'}), 400

            # 插入数据到数据库
            query = """
                INSERT INTO rdsh (客户名称, 最新外部等级, 违约原因, 违约严重性, 备注信息, 审核状态, 审核结果, 附件地址, 认定申请时间)
                VALUES (?, ?, ?, ?, ?, '未审核', NULL, ?, ?)
            """
            params = (client_name, external_rating, violation_reason, severity, remarks, attachment_path, application_time)
            cursor.execute(query, params)
            conn.commit()

        return jsonify({'success': True})
    except Exception as e:
        print(f"错误：{e}")
        return jsonify({'success': False, 'error': str(e)}), 500
#上传重生申请
@app.route('/submitResurrection', methods=['POST'])
def submit_resurrection():
    data = request.form
    customer_name = data.get('customerName')
    default_reason = data.get('defaultReason')
    severity = data.get('severity')
    recognition_person = data.get('recognitionPerson')
    rating = data.get('externalRating')
    resurrection_reason = data.get('resurrectionReason')

    # 获取当前时间
    from datetime import datetime
    application_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    print(f"接收到的数据: {customer_name}, {default_reason}, {severity}, {recognition_person}, {application_date}, {rating}, {resurrection_reason}")

    # 检查客户名称是否已存在
    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM wycs WHERE 违约客户 = ?", (customer_name,))
        count = cursor.fetchone()[0]

    if count > 0:
        return jsonify({'success': False, 'message': '客户名称已存在，请更换客户名称。'}), 400

    # 插入数据到数据库
    query = """
        INSERT INTO wycs (违约客户, 审核状态, 认定违约原因, 严重程度, 认定人, 认定申请时间, 认定审核时间, 最新外部等级, 审核结果, 重生原因)
        VALUES (?, '未审核', ?, ?, ?, ?, NULL, ?, NULL, ?)
    """
    params = (customer_name, default_reason, severity, recognition_person, application_date, rating, resurrection_reason)

    try:
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            conn.commit()

        return jsonify({'success': True})
    except Exception as e:
        print(f"错误：{e}")
        return jsonify({'success': False, 'message': str(e)}), 500
#查询重生申请
@app.route('/getResurrectionData', methods=['POST'])
def get_resurrection_data():
    data = request.json
    client_name = data.get('clientName', '')
    audit_status = data.get('auditStatus', 'all')

    query = """
        SELECT 违约客户 AS clientName,
               最新外部等级 AS externalRating,
               认定违约原因 AS violationReason,
               严重程度 AS severity,
               审核状态 AS auditStatus,
               审核结果 AS auditResult,
               重生原因 AS resurrectionReason
        FROM wycs
        WHERE 1=1
    """

    params = []
    if client_name:
        query += " AND 违约客户 LIKE ?"
        params.append(f'%{client_name}%')
    if audit_status != 'all':
        query += " AND 审核状态 = ?"
        params.append(audit_status)

    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        cursor.execute(query, params)
        rows = cursor.fetchall()

    result = []
    for row in rows:
        result.append({
            'clientName': row.clientName,
            'externalRating': row.externalRating,
            'violationReason': row.violationReason,
            'severity': row.severity,
            'auditStatus': row.auditStatus,
            'auditResult': row.auditResult,
            'resurrectionReason': row.resurrectionReason
        })

    return jsonify(result)
#更新重生操作
@app.route('/resurrectClient', methods=['POST'])
def resurrect_client():
    data = request.json
    client_name = data.get('clientName')
    action = data.get('action')

    if action not in ['通过', '不通过']:
        return jsonify({'success': False, 'message': '无效的操作'}), 400

    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        if action == '通过':
            audit_result = '通过'
        else:
            audit_result = '不通过'

        query = """
            UPDATE wycs
            SET 审核状态 = '已审核',
                审核结果 = ?,
                认定审核时间 = ?
            WHERE 违约客户 = ? AND 审核状态 = '未审核'
        """
        try:
            cursor.execute(query, (audit_result, current_time, client_name))
            conn.commit()

            # 检查是否更新成功
            if cursor.rowcount > 0:
                return jsonify({'success': True})
            else:
                return jsonify({'success': False, 'message': '更新失败或客户信息不匹配'}), 400
        except Exception as e:
            print(f"错误：{e}")
            return jsonify({'success': False, 'message': str(e)}), 500
#撤回重生操作
@app.route('/revokeResurrection', methods=['POST'])
def revoke_resurrection():
    data = request.json
    client_name = data.get('clientName')

    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        query = """
            UPDATE wycs
            SET 审核状态 = '未审核',
                审核结果 = NULL
            WHERE 违约客户 = ? AND 审核状态 = '已审核'
        """
        try:
            cursor.execute(query, (client_name,))
            conn.commit()

            # 检查是否更新成功
            if cursor.rowcount > 0:
                return jsonify({'success': True})
            else:
                return jsonify({'success': False, 'message': '撤回失败或客户信息不匹配'}), 400
        except Exception as e:
            print(f"错误：{e}")
            return jsonify({'success': False, 'message': str(e)}), 500
#统计
@app.route('/stats', methods=['GET'])
def get_stats():
    try:
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()

            # 查找所有审核结果为“通过”的违约客户
            cursor.execute("SELECT 违约客户 FROM wykh")
            default_clients = [row[0] for row in cursor.fetchall()]

            if not default_clients:
                return jsonify({'error': 'No default clients found'}), 404

            # 使用占位符动态生成 SQL 查询
            query = """
                SELECT 客户名, 行业, 地区 
                FROM CustomerInfo 
                WHERE 客户名 IN ({})
            """.format(', '.join('?' for _ in default_clients))

            cursor.execute(query, default_clients)
            rows = cursor.fetchall()

            # 统计行业和地区的违约数
            industry_counts = {}
            region_counts = {}
            for row in rows:
                _, industry, region = row
                if industry:
                    industry_counts[industry] = industry_counts.get(industry, 0) + 1
                if region:
                    region_counts[region] = region_counts.get(region, 0) + 1

            # 生成柱状图（行业违约数）
            fig, ax = plt.subplots()
            industries = list(industry_counts.keys())
            counts = list(industry_counts.values())
            colors = plt.cm.get_cmap('tab10', len(industries))  # 使用不同的颜色
            ax.bar(industries, counts, color=[colors(i) for i in range(len(industries))])
            ax.set_xlabel('行业')
            ax.set_ylabel('违约数')
            ax.set_title('行业违约数')
            fig.tight_layout()
            industry_chart = BytesIO()
            plt.savefig(industry_chart, format='png')
            industry_chart.seek(0)
            industry_chart_base64 = base64.b64encode(industry_chart.getvalue()).decode('utf-8')

            # 生成饼状图（地区违约数）
            fig, ax = plt.subplots()
            regions = list(region_counts.keys())
            region_counts_list = list(region_counts.values())
            ax.pie(region_counts_list, labels=regions, autopct='%1.1f%%', startangle=90,
                   colors=plt.cm.Paired(range(len(regions))))
            ax.set_title('地区违约数')
            fig.tight_layout()
            region_chart = BytesIO()
            plt.savefig(region_chart, format='png')
            region_chart.seek(0)
            region_chart_base64 = base64.b64encode(region_chart.getvalue()).decode('utf-8')

            # 生成折线图（不同地区的违约总数）
            # 执行 SQL 查询并获取数据
            cursor.execute("SELECT 时间, 地区, COUNT(*) FROM 历史数据 GROUP BY 时间, 地区")
            data = cursor.fetchall()

            # 处理数据
            years = sorted(set(row[0] for row in data))
            region_data = {}
            for row in data:
                year, region, count = row
                if region not in region_data:
                    region_data[region] = [0] * len(years)
                region_data[region][years.index(year)] = count

            # 创建图像和坐标轴，设置图像大小
            fig, ax = plt.subplots(figsize=(15, 4))  # 设置图像大小为 1500x400 像素

            # 绘制折线图
            for region, counts in region_data.items():
                ax.plot(years, counts, label=region)

            # 设置坐标轴标签
            ax.set_xlabel('年份')
            ax.set_ylabel('违约数')

            # 去掉标题
            # ax.set_title('不同地区违约总数')  # 标题被移除

            # 显示图例
            ax.legend()

            # 自动调整布局
            fig.tight_layout()

            # 保存图像到 BytesIO 对象
            region_trend_chart = BytesIO()
            plt.savefig(region_trend_chart, format='png')
            region_trend_chart.seek(0)

            # 将图像转换为 base64 编码
            region_trend_chart_base64 = base64.b64encode(region_trend_chart.getvalue()).decode('utf-8')

            # 生成折线图（不同行业的违约总数）
            # 执行 SQL 查询并获取数据
            cursor.execute("SELECT 时间, 行业, COUNT(*) FROM 历史数据 GROUP BY 时间, 行业")
            data = cursor.fetchall()

            # 处理数据
            years = sorted(set(row[0] for row in data))
            industry_data = {}
            for row in data:
                year, industry, count = row
                if industry not in industry_data:
                    industry_data[industry] = [0] * len(years)
                industry_data[industry][years.index(year)] = count

            # 创建图像和坐标轴，设置图像大小
            fig, ax = plt.subplots(figsize=(15, 4))  # 设置图像大小为 1500x400 像素

            # 绘制折线图
            for industry, counts in industry_data.items():
                ax.plot(years, counts, label=industry)

            # 设置坐标轴标签
            ax.set_xlabel('年份')
            ax.set_ylabel('违约数')

            # 去掉标题
            # ax.set_title('不同行业违约总数')  # 标题被移除

            # 显示图例
            ax.legend()

            # 自动调整布局
            fig.tight_layout()

            # 保存图像到 BytesIO 对象
            industry_trend_chart = BytesIO()
            plt.savefig(industry_trend_chart, format='png')
            industry_trend_chart.seek(0)

            # 将图像转换为 base64 编码
            industry_trend_chart_base64 = base64.b64encode(industry_trend_chart.getvalue()).decode('utf-8')

            return jsonify({
                'industry_chart': industry_chart_base64,
                'region_chart': region_chart_base64,
                'region_trend_chart': region_trend_chart_base64,
                'industry_trend_chart': industry_trend_chart_base64
            })
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
