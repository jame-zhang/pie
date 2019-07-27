#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/11/15 11:18 AM
# @Author  : Jame
# @Site    :
# @File    : server.py
# @Software: PyCharm

"""
说明：采用异步请求方式不太好，应该将查询做个持久化链接查询，保存在服务器，然后更新json文件即可
"""

import tornado.ioloop
import tornado.web
import tornado.template
import time
import datetime
import json
import subprocess
import re
from tornado.concurrent import run_on_executor
from concurrent.futures import ThreadPoolExecutor
import tornado.gen

# jsonFile = "/home/pi/raspberry/web/json/stats.json"
jsonFile = ""
index_url = ""
login_url = ""
vpncmd_path=""
# vpncmd_path="/home/pi/Desktop/vpnserver/vpncmd"
sessionCheckFlag = 0
try:
    with open(jsonFile, encoding='utf8') as f:
        jsonData = json.load(f)
except Exception as e:
    print(e)
    jsonData = {}
    jsonData["servers"] = []
def what_time_is_now():
    return time.strftime("%Y-%m-%d %H:%M:%S",time.localtime())

def get_num_of_sessions(id):
    if type == "all":
        pass
    cmd = vpncmd_path + " " + id+".sedns.cn"+':1194 /SERVER /Hub:VPN /PASSWORD:"22abcd" /CMD ServerStatusGet'
    try:
        output = subprocess.check_output(cmd, shell=True, timeout=5)
        # print(type(output))
        num_sessions = re.search(r"会话数.*", output.decode('utf-8')).group(0).split('|')[1]
        return num_sessions
    except Exception as e:
        print(e)
        return "检测失败"

def jsonDump():
    with open(jsonFile, 'w', encoding='utf-8') as f:
        f.write(json.dumps(jsonData, ensure_ascii=False))

def sessionDefault():
    for idx in range(len(jsonData['servers'])):
        jsonData['servers'][idx]["session"] = "待检测"

class MainHandler(tornado.web.RequestHandler):

    def get(self):
        id = self.get_argument("id")
        id = id.replace("raspi-","rpie")
        ipaddr = self.get_argument("ipaddr")
        updatedTime = self.get_argument("updatedTime")
        # updated = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
        updated = int(time.time())
        flag = 0
        for i in range(len(jsonData["servers"])):
            if jsonData["servers"][i]["id"] == id:
                # print("i:"+str(i))
                jsonData["servers"][i]["id"] = id
                jsonData["servers"][i]["ipaddr"] = ipaddr
                jsonData["servers"][i]["updatedTime"] = updatedTime
                flag = 1
        if flag == 0:
            newJsonData = {}
            newJsonData["id"] = id
            newJsonData["ipaddr"] = ipaddr
            newJsonData["updatedTime"] = updatedTime
            jsonData["servers"].append(newJsonData)
        jsonData['updated'] = updated

        # with open(jsonFile, 'w', encoding='utf-8') as f:
        #     f.write(json.dumps(jsonData, ensure_ascii=False))
        jsonDump()


    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        # print("pause received!")
        id = self.get_argument("id")
        id = id.replace("raspie","rpie")
        id = id.replace("raspi-","rpie")
        id = id.replace("raspi","rpie")
        #ipaddr = self.get_argument("ipaddr")
        ipaddr = self.request.remote_ip
        updatedTime = self.get_argument("updatedTime")
        #hours_updated = int(updatedTime[11:13])
        #hours_now = int(time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())[11:13])
        #if hours_now - hours_updated == 8:
        #    updatedTime = updatedTime[:11] + str(hours_now) + updatedTime[13:]
        #updated = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
        updatedTime = datetime.datetime.strptime(updatedTime, "%Y-%m-%d %H:%M:%S") + datetime.timedelta(hours=8)
        updatedTime = updatedTime.strftime("%Y-%m-%d %H:%M:%S")
        updated = int(time.time())
        flag = 0
        for i in range(len(jsonData["servers"])):
            if jsonData["servers"][i]["id"] == id:
                # print("i:"+str(i))
                jsonData["servers"][i]["id"] = id
                if ipaddr != "" and jsonData["servers"][i]["ipaddr"] != ipaddr:
                    jsonData["servers"][i]["ipaddr"] = ipaddr
                jsonData["servers"][i]["updatedTime"] = updatedTime
                flag = 1
        if flag == 0:
            newJsonData = {}
            newJsonData["id"] = id
            newJsonData["ipaddr"] = ipaddr
            newJsonData["updatedTime"] = updatedTime
            jsonData["servers"].append(newJsonData)
        jsonData['updated'] = updated

        # with open(jsonFile, 'w', encoding='utf-8') as f:
        #     f.write(json.dumps(jsonData, ensure_ascii=False))
        jsonDump()

class SessionCheckHandler(tornado.web.RequestHandler):
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET')
    # @tornado.web.asynchronous
    # @tornado.gen.coroutine
    def get(self):
        pass
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        global  sessionCheckFlag
        type = self.get_argument("type")
        if type == "all":
            if sessionCheckFlag == 0:
                print("sessionCheck!!!")
                sessionCheckFlag = 1
                sessionDefault()
                for idx, server in enumerate(jsonData["servers"]):
                    # print("idx:" + str(idx))
                    # print(server)
                    jsonData["servers"][idx]["session"] = get_num_of_sessions(server["id"])
                    jsonData["servers"][idx]["sessionAt"] = what_time_is_now()
                    jsonDump()
                sessionCheckFlag = 0
        elif type == "id":
            id = self.get_argument("id")
            # print(id)
            jsonData["servers"][int(id)]["session"] = get_num_of_sessions(jsonData["servers"][int(id)]["id"])
            jsonData["servers"][int(id)]["sessionAt"] = what_time_is_now()
            jsonDump()




class LoginHandler(tornado.web.RequestHandler):
    def get(self, *args, **kwargs):
        pass
    def post(self, *args, **kwargs):
        username = self.get_argument("username")
        password = self.get_argument("password")
        if username == "admin" and password == "yunjiankong":
            self.redirect(index_url)
        else:
            self.redirect(login_url)


def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
        # (r"/login", LoginHandler),
        # (r"/sessionCheck", SessionCheckHandler),
    ])

if __name__ == "__main__":
    port = 000
    app = make_app()
    app.listen(port)
    tornado.ioloop.IOLoop.current().start()
