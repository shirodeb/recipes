#!/usr/bin/env python3
import os
import queue
import requests
import threading, threadpool
import base64
import urllib.parse
import subprocess
import json
import re


query_link = (
    "https://appstore.uniontech.com/prod-api/store-dist-search/searchAllApp/?keyword="
)

token = ""

def check_cms(keyword: str) -> bool:
    resp = requests.get(
        url=query_link + urllib.parse.quote(keyword),
        headers={"Authorization": f"Bearer {token}"},
    )
    if resp.status_code != 200:
        raise Exception("Check cms failed: " + str(resp.status_code))
    return len(resp.json()["datas"]) != 0

def filter_list_by_cms(list_):
    q = queue.Queue()
    pool = threadpool.ThreadPool(32)

    def do_task(l):
        if not check_cms(l):
            q.put(l)
        else:
            print(f"{l} is existed.")

    tasks = threadpool.makeRequests(do_task, list_)
    [pool.putRequest(task) for task in tasks]
    pool.wait()
    return list(q.queue)

if __name__ == "__main__":
    list_ = []
    with open("apps.txt", "r") as f:
        for line in f.readlines():
            line = line.strip()
            list_.append(line)

    new_list = filter_list_by_cms(list_)

    with open("not_existed.txt", "w") as f:
        f.write('\n'.join(new_list))

