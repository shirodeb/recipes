import requests
import json
import re
import os
import pathlib
import shutil

requests.adapters.DEFAULT_RETRIES=10

no_possible_strings = [
    '.dmg', '.msi', '.exe', '.yml', '.yaml', '.json', '.pkg', '.nsis', '.rpm'
    '-win', '-mac', '-osx', '-darwin', 'aarch64', 'arm64'
]


def fetch_github(url):
    if 'github.com' not in url:
        return None
    username, repo = re.findall(r'github.com/([^/]*)/([^/]*)', url)[0]
    resp = requests.get(f"https://api.github.com/repos/{username}/{repo}")
    if resp.status_code != 200:
        raise Exception("fetch failed: " + str(resp.status_code))
    general = resp.json()
    resp = requests.get(f"https://api.github.com/repos/{username}/{repo}/releases/latest")
    if resp.status_code != 200 and resp.status_code != 404:
        raise Exception("fetch release/latest failed: " + str(resp.status_code))
    release = None
    if resp.status_code == 404:
        resp = requests.get(f"https://api.github.com/repos/{username}/{repo}/releases")
        if resp.status_code != 200:
            raise Exception("fetch release failed: " + str(resp.status_code))
        release = resp.json()
        if len(release) == 0:
            raise Exception("fetch release failed: no release yet")
        release = release[0]

    else:
        release = resp.json()

    def f(s):
        if '.' not in s[0]:
            return False
        for ns in no_possible_strings:
            if ns in s[0]:
                return False;
        return True

    urls=list(filter(f, map(lambda x: (x['name'], x['browser_download_url']), release['assets'])))
    if len(urls) == 1:
        url = urls[0][1]
    elif len(urls) > 1:
        for index, value in enumerate(urls):
            print(index, value[0])
        v=input('Which one?')
        if len(v) == 0: 
            v=  0
        v=int(v)
        url=urls[v][1]

    ver = release['tag_name']
    if not ver[0].isdigit():
        ver = ver[1:]
        
    return {
        'username': username,
        'repo': repo,
        'desc': general['description'],
        'version': ver,
        'url': url
    }

target_dir =  pathlib.Path("/home/shiroko/Projects/recipes_repo/Electrons/todo")
target_dir2 =  pathlib.Path("/home/shiroko/Projects/recipes_repo/Electrons")
target_dir3 =  pathlib.Path("/home/shiroko/Projects/recipes_repo/Electrons/notok")
target_dir4 =  pathlib.Path("/home/shiroko/Projects/recipes_repo/Electrons/finished")

def generate(codename, name, url):
    if 'github.com' not in url:
        return None

    username = ''
    repo = ''

    try: username, repo = re.findall(r'github.com/([^/]*)/([^/]*)', url)[0]
    except: return None
    
    package = f"com.github.{username}.{repo}"
    package = package.lower()
    pdir=target_dir.joinpath(package)
    if pdir.exists():
        print(f"{package} is existed.")
        return

    if target_dir2.joinpath(package).exists() or target_dir3.joinpath(package).exists() or target_dir4.joinpath(package).exists():
        print(f"{package} is existed.")
        return

    try:
        shutil.copytree('templates/', pdir)
        shutil.copyfile(f'apps/{codename}/{codename}-icon.png', pdir.joinpath('templates/icon.png'))
        sh=pdir.joinpath('build.sh')
        info = None
        try:
            info=fetch_github(url)
        except Exception as e:
            print("Failed to fetch", e)
            shutil.rmtree(pdir)
            return 

        if info is None:
            print("No github info.")
            shutil.rmtree(pdir)
            return

        with open(sh, 'r') as f:
            texts = f.read()
            texts = texts.replace('%PACKAGE%', package)
            texts = texts.replace('%USERNAME%', info['username'])
            texts = texts.replace('%REPO%', info['repo'])
            texts = texts.replace('%NAME%', name)
            texts = texts.replace('%VERSION%', info['version'])
            texts = texts.replace('%URL%', info['url'])
            texts = texts.replace('%DESC%', info['desc'] or '')

            with open(sh, 'w') as fw :
                fw.write(texts)
    except Exception as e:
        shutil.rmtree(pdir)
        print("Error", url)
        raise e

if __name__ == '__main__':
    with open('./repos.txt', 'r') as f:
        for i, line in enumerate(f.readlines()):
            if i < 220: continue
            codename, name, url = line.strip().split('\t')
            print(i)
            generate(codename, name, url)
