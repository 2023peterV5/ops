from fastapi import FastAPI
import random
import string
import subprocess
import gspread
from oauth2client.service_account import ServiceAccountCredentials


# 获取credentials.json教程：https://medium.com/@a.marenkov/how-to-get-credentials-for-google-sheets-456b7e88c430
app = FastAPI()

# 定义要追加的数据,A,B,C列用空格占位
data_to_append = [
    ["","www01.com","2024-03-12"," ", "www @", "pk-kxxz.axxx1.com","前台-1"],
    ["","wwwapp.com","2024-03-12"," ", "www @", "pk-kxxz.axxx1.com","app-1"]
]

# 将信息写入Google Sheets
def write_to_google_sheets(name: str, email_addr: str, email_passwd: str, cloudflare_passwd: str):
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name("credentials.json", scope)
    client = gspread.authorize(creds)
    

    try:
        sheet = client.open("create_email").worksheet("demo1")
        # 数据追加写入

        # 1、将邮件地址，密码，cloudflare密码写入工作表
        # sheet.append_row([name,])
        # sheet.append_row(["信箱",email_addr, email_passwd])
        # sheet.append_row(["CF",email_addr, cloudflare_passwd])
        # 2、指定单元格写入数据
        # sheet.update_cell(3, 4, name)  # 将名字写入单元格 D3
        # sheet.update_cell(3, 5, age)   # 将年龄写入单元格 E3
        # sheet.update_cell(3, 6, birthday)  # 将生日写入单元格 F3

        # sheet = client.open("create_email").worksheet("Sheet2")
        sheet.append_rows(data_to_append, value_input_option='USER_ENTERED')
        # 'value_input_option='USER_ENTERED' 用于确保数据按照用户输入的方式写入，以便保持日期格式不变。

        print("数据已成功写入到工作表")
except Exception as e:
    print("追加数据时出错:", e)

# # 根据输入的租户，创建邮箱
# @app.get("/generate/{name}")
# async def generate_name_with_random_string(name: str):
#     email_passwd,cloudflare_passwd = generate_random_string()
#     email_name = name + "@dbcnd621.com"
#     write_to_google_sheets(name,email_addr, email_passwd, cloudflare_passwd)

#     # 调用创建邮箱脚本并传递参数
#     result = subprocess.run(["./create_one_mail.sh", name,email_passwd], capture_output=True, text=True)

#     # 输出结果
#     print("stdout:", result.stdout)
#     print("stderr:", result.stderr)
#     print("Return code:", result.returncode)
    
#     return {"邮箱地址": email_addr, "邮箱密码": email_passwd, "cloudflare密码": cloudflare_passwd}

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
