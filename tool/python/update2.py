import os,sys
import stat,fnmatch

from hashlib import md5

from zfile import ZFile
import config

def get_cur_path():
    path = sys.path[0]
    if os.path.isdir(path):
         return path
    elif os.path.isfile(path):
         return os.path.dirname(path)

def gitupdate():  
    os.system("cd /Users/trunk/Desktop/game/alpha && git pull && cd database && php main.php update localhost && cd ../ && /usr/local/bin/mono tool/ProjectHelper_New/ProjectHelper2.exe client")
    os.system("cd /Users/trunk/Desktop/game/alpha && cd client/res_compress_encrypt/ && python thinRes.py")
    os.system("sed -ie 's/RELEASE_MODE=false/RELEASE_MODE=true/g' /Users/trunk/Desktop/game/alpha/client/COG/src/config.lua && sed -ie 's/AUTO_UPDATE=false/AUTO_UPDATE=true/g' /Users/trunk/Desktop/game/alpha/client/COG/src/config.lua")
    os.system("rm -rf /Users/trunk/Desktop/game/alpha/client/COG/src/config.luae")
    os.system("cd /Users/trunk/Desktop/game/alpha/client/COG && ./encrypt.command")
    os.system("cd /Users/trunk/Desktop/game/alpha/ && git checkout .")
    # os.system("cd /home/cocos_update_tool_php/manifest && /bin/cp -f update.zip update_bk.zip")
    # os.system("cd /Users/trunk/Desktop/game/alpha && cd client/res_compress_encrypt/ && python thinRes.py")

def comparativeSize(new_ver, old_ver):
    if new_ver > old_ver:
        return 1
    elif new_ver < old_ver:
        return -1
    else:
        return 0

# def comparativeSize(new_ver, old_ver):
#     new_ver_list = new_ver.split('.')
#     old_ver_list = old_ver.split('.')
#     na = int(new_ver_list[0])
#     nb = int(new_ver_list[1])
#     nc = int(new_ver_list[2])
#     oa = int(old_ver_list[0])
#     ob = int(old_ver_list[1])
#     oc = int(old_ver_list[2])
#     if na > oa:
#         return 1
#     elif na < oa:
#         return -1
#     else:
#         if nb > ob:
#             return 1
#         elif nb < ob:
#             return -1
#         else:
#             if nc > oc:
#                 return 1
#             elif nc < oc:
#                 return -1
#             else:
#                 return 0

def getVersion():
    version_path = manifest_path + version_file
    
    if os.path.exists(version_path):
        f = open(version_path,"r")
        line = f.readline()
        f.close()
    else:
        f = open(version_path,"w")
        f.write(str(config.baseVersion))
        f.flush()
        f.close()
        line = str(config.baseVersion)
            
    return line

def getVersionList(path):
    if os.path.exists(path):
        dirlist = []
        for name in os.listdir(path):
            fullname = os.path.join(path, name).replace("\\","/")
            st = os.lstat(fullname)
            if stat.S_ISDIR(st.st_mode):
                dirlist.append(name)
            else:
                pass
        return dirlist
    else:
        return []

# def preProcess(new_ver):
#     cur_ver=getVersion()

#     status = comparativeSize(int(new_ver), int(cur_ver))

#     if status == -1:
#         print ("new version error!\nnew version must less than old version!")
#         return

#     ver_list = getVersionList(manifest_path)
#     ver_int_list=[ int(i) for i in ver_list]
#     ver_int_list.sort()
#     ver_int_list.reverse()

#     for old_ver in ver_int_list:
#         old_ver_str = str(old_ver)
#         if old_ver == new_ver:
#             continue
#         if old_ver == int(new_ver)-1:
#             zip_name = config.zipname + new_ver + config.postfix
#             zip_path = manifest_path + "/"  + zip_name

#             print ("ready to generate:" + zip_path + "\n")
#             print ("----generating..." + "\n")
#             print ("res_dir is " + file_path + "\n")
#             print ("save_dir is " + manifest_path + "\n")
#             print ("cur_ver is " + old_ver_str + "\n")
#             print ("new_ver is " + new_ver + "\n")
#             zip_update_file(file_path +"/",manifest_path + "/",old_ver_str,new_ver, zip_name)
#             print ("----done\n")
#         if old_ver == 0:
#             zip_name = config.zipname + config.postfix
#             zip_path = manifest_path + "/"  + zip_name

#             print ("ready to generate:" + zip_path + "\n")
#             print ("----generating..." + "\n")
#             print ("res_dir is " + file_path + "\n")
#             print ("save_dir is " + manifest_path + "\n")
#             print ("cur_ver is " + old_ver_str + "\n")
#             print ("new_ver is " + new_ver + "\n")
#             zip_update_file(file_path +"/",manifest_path + "/",old_ver_str,new_ver, zip_name)
#             print ("----done\n")
#         gen_md5_manifest_file(manifest_path + "/" + new_ver + "/", old_ver_str, new_ver, manifest_path)
#     gen_md5_manifest_file(manifest_path + "/" + new_ver + "/", new_ver, new_ver, manifest_path)
#     if the_path == "trunk":
#         os.system("cd /home/cocos_update_tool_php/manifest && /bin/cp -f update_bk.zip update.zip")

def preProcess(new_ver):
    cur_ver=getVersion()

    status = comparativeSize(int(new_ver), int(cur_ver))

    if status == -1:
        print ("new version error!\nnew version must less than old version!")
        return

    ver_list = getVersionList(manifest_path)
    # print ("ver_list is {}.".format(ver_list))

    for old_ver in ver_list:
        if old_ver == new_ver:
            continue
        zip_path = ""       
        zip_name = config.zipname + config.postfix
        if int(new_ver) == int(config.baseVersion):
            zip_path = manifest_path + "/" + str(old_ver) + "/" + zip_name
        else:
            zip_path = manifest_path + "/" + new_ver + "/" +str(old_ver) + "/"  + zip_name

        print "ready to generate:" + zip_path + "\n"
        print "----generating..." + "\n"
        print "res_dir is " + file_path +"/" + "\n"
        print "save_dir is " + manifest_path +"/" + "\n"
        print "cur_ver is " + old_ver + "\n"
        print "new_ver is " + new_ver + "\n"
        zip_update_file(file_path +"/",manifest_path + "/",old_ver,new_ver)
        print "----done\n"
    gen_md5_manifest_file(manifest_path + "/" + new_ver + "/", new_ver, new_ver)


def get_file_list(path, ext, subdir = True ):
    if os.path.exists(path):
        dirlist = []
        for name in os.listdir(path):
            fullname = os.path.join(path, name)
            st = os.lstat(fullname)
            if stat.S_ISDIR(st.st_mode) and subdir:
                dirlist +=  get_file_list(fullname,ext)
            elif os.path.isfile(fullname):
                if fnmatch.fnmatch( fullname, ext):  
                    dirlist.append(fullname)
            else:
                pass 
        return dirlist
    else:
        return []

def md5_file(filename):
    m = md5()
    a_file = open(filename,'rb')
    m.update(a_file.read())
    a_file.close()
    return m.hexdigest()

def gen_md5_list(manifest_path=""):
    if manifest_path == "":
        manifest_path = get_cur_path()

    cur_path = manifest_path

    size = len(cur_path)    
    reslist = get_file_list(cur_path+"src","*")
    reslist +=  get_file_list(cur_path+"res","*")
    new_list = []
    for line in reslist:
        md5 = md5_file(line)
        new_line = line[size:len(line)].replace('\\','/')
        new_list.append(new_line+":"+md5)

    return new_list

def gen_md5_list_file(new_list,manifest_path="",save_path = ""):
    if not new_list:
        new_list = gen_md5_list()

    if save_path == "":
        save_path = get_cur_path()

    if manifest_path == "":
        manifest_path = get_cur_path()

    list_file = save_path + "/list.txt"
    fp=open(list_file,'w')
    fp.truncate()

    for new_line in new_list:
        line = manifest_path + "/" + new_line.split(":")[0]
        md5 = md5_file(line)
        fp.write(new_line)
        fp.write("\n")
    fp.flush()
    fp.close()


# def gen_md5_manifest_file(save_dir, cur_ver, new_ver, manifest_path):
#     if cur_ver == new_ver:
#         json = '{\
#         \n\t"packageUrl" : "http://%(cdn_url)s/manifest",\
#         \n\t"remoteVersionUrl" : "http://%(url)s/version2.php?manifest=version&manifest_version=%(new_ver)s",\
#         \n\t"remoteManifestUrl" : "http://%(url)s/version2.php?manifest=project&manifest_version=%(new_ver)s",\
#         \n\t"version" : "%(new_ver)s",\
#         \n\t"engineVersion" : "Cocos2d-x v3.16",\
#         \n\t"assets" : {\
#         \n\t},\
#         \n\t"searchPaths":["src/","res/"]\
#         \n}' % {'new_ver':new_ver, 'url':config.url, 'cdn_url':config.cdn_url}

#         f = file(save_dir+"project.manifest", "w+")
#         f.write(json)
#         f.close()

#         json = '{\
#         \n\t"packageUrl" : "http://%(cdn_url)s/manifest",\
#         \n\t"version" : "%(new_ver)s",\
#         \n\t"engineVersion" : "Cocos2d-x v3.16"\n}' % {'new_ver':new_ver, 'url':config.url, 'cdn_url':config.cdn_url}
#         f = file(save_dir+"version.manifest", "w+")
#         f.write(json)
#         f.close()
#     elif int(cur_ver) == 0:
#         md5 = md5_file(manifest_path+"/"+config.zipname+config.postfix)
#         md5_data = '\n\t\t"%(zipname)s":{"md5":"%(md)s","compressed":true}' % {'zipname':config.zipname+config.postfix, 'md':md5}
#         file_size = os.path.getsize(manifest_path+"/"+config.zipname+config.postfix)
#         # print ("md5 is {}".format(md5))
#         json = '{\
#         \n\t"packageUrl" : "http://%(cdn_url)s/manifest",\
#         \n\t"remoteVersionUrl" : "http://%(url)s/version2.php?manifest=version&manifest_version=%(new_ver)s",\
#         \n\t"remoteManifestUrl" : "http://%(url)s/version2.php?manifest=project&manifest_version=%(new_ver)s",\
#         \n\t"version" : "%(new_ver)s",\
#         \n\t"engineVersion" : "Cocos2d-x v3.16",\
#         \n\t"assets" : {\
#         \n\t\t%(md_data)s\
#         \n\t},\
#         \n\t"file_size":"%(file_size)s",\
#         \n\t"searchPaths":["src/","res/"]\
#         \n}' % {'new_ver':new_ver, 'zipname':config.zipname, 'md_data':md5_data, 'url':config.url, 'cdn_url':config.cdn_url, 'file_size':file_size}
#         # print ("json is {}".format(json))
#         f = file(save_dir+"project"+cur_ver+".manifest", "w+")
#         f.write(json)
#         f.close()
#         #generate version.manifest url not use
#         json = '{\
#         \n\t"packageUrl" : "http://%(cdn_url)s/manifest",\
#         \n\t"version" : "%(new_ver)s",\
#         \n\t"file_size":"%(file_size)s",\
#         \n\t"engineVersion" : "Cocos2d-x v3.16"\n}' % {'new_ver':new_ver, 'url':config.url, 'cdn_url':config.cdn_url, 'file_size':file_size, 'cur_ver':cur_ver}
#         f = file(save_dir+"version"+cur_ver+".manifest", "w+")
#         f.write(json)
#         f.close()
#     else:
#         file_size = 0
#         md5_data = ""
#         for x in xrange(int(cur_ver)+1,int(new_ver)+1):
#             x = str(x)
#             md5 = md5_file(manifest_path+"/"+config.zipname+x+config.postfix)
#             md5_data1 = '\n\t\t"%(zipname)s":{"md5":"%(md)s","compressed":true}' % {'zipname':config.zipname+x+config.postfix, 'md':md5}
#             if x == new_ver:
#                 md5_data = md5_data + md5_data1
#             else:
#                 md5_data = md5_data + md5_data1 + ","
#             file_size = file_size + os.path.getsize(manifest_path+"/"+config.zipname+x+config.postfix)
#         # print ("md5 is {}".format(md5))
#         json = '{\
#         \n\t"packageUrl" : "http://%(cdn_url)s/manifest",\
#         \n\t"remoteVersionUrl" : "http://%(url)s/version2.php?manifest=version&manifest_version=%(new_ver)s",\
#         \n\t"remoteManifestUrl" : "http://%(url)s/version2.php?manifest=project&manifest_version=%(new_ver)s",\
#         \n\t"version" : "%(new_ver)s",\
#         \n\t"engineVersion" : "Cocos2d-x v3.16",\
#         \n\t"assets" : {\
#         \n\t\t%(md_data)s\
#         \n\t},\
#         \n\t"file_size":"%(file_size)s",\
#         \n\t"searchPaths":["src/","res/"]\
#         \n}' % {'new_ver':new_ver, 'zipname':config.zipname, 'md_data':md5_data, 'url':config.url, 'cdn_url':config.cdn_url, 'file_size':file_size}
#         # print ("json is {}".format(json))
#         f = file(save_dir+"project"+cur_ver+".manifest", "w+")
#         f.write(json)
#         f.close()

#         json = '{\
#         \n\t"packageUrl" : "http://%(cdn_url)s/manifest",\
#         \n\t"version" : "%(new_ver)s",\
#         \n\t"file_size":"%(file_size)s",\
#         \n\t"engineVersion" : "Cocos2d-x v3.16"\n}' % {'new_ver':new_ver, 'url':config.url, 'cdn_url':config.cdn_url, 'file_size':file_size}
#         f = file(save_dir+"version"+cur_ver+".manifest", "w+")
#         f.write(json)
#         f.close()



def gen_md5_manifest_file(save_dir, cur_ver, new_ver):
    if cur_ver == new_ver:
        json = '{\
        \n\t"packageUrl" : "http://%(cdn_url)s/manifest/%(new_ver)s/%(cur_ver)s",\
        \n\t"remoteVersionUrl" : "http://%(url)s/version2.php?manifest=version&manifest_version=%(new_ver)s",\
        \n\t"remoteManifestUrl" : "http://%(url)s/version2.php?manifest=project&manifest_version=%(new_ver)s",\
        \n\t"version" : "%(new_ver)s",\
        \n\t"file_size":"0",\
        \n\t"engineVersion" : "Cocos2d-x v3.16",\
        \n\t"assets" : {\
        \n\t},\
        \n\t"searchPaths":["src/","res/"]\
        \n}' % {'new_ver':new_ver, 'cur_ver':cur_ver, 'url':config.url, 'cdn_url':config.cdn_url}

        f = file(save_dir+"project.manifest", "w+")
        f.write(json)
        f.close()
        # print ("json is {}".format(json))
        json = '{\
        \n\t"packageUrl" : "http://%(cdn_url)s/manifest/%(new_ver)s/%(cur_ver)s",\
        \n\t"remoteVersionUrl" : "http://%(url)s/version2.php?manifest=version&manifest_version=%(new_ver)s",\
        \n\t"remoteManifestUrl" : "http://%(url)s/version2.php?manifest=project&manifest_version=%(new_ver)s",\
        \n\t"version" : "%(new_ver)s",\
        \n\t"file_size":"0",\
        \n\t"engineVersion" : "Cocos2d-x v3.16"\n}' % {'new_ver':new_ver, 'cur_ver':cur_ver, 'url':config.url, 'cdn_url':config.cdn_url}
        f = file(save_dir+"version.manifest", "w+")
        f.write(json)
        f.close()
    else:
        md5 = md5_file(save_dir+config.zipname + config.postfix)
        file_size = os.path.getsize(save_dir+config.zipname + config.postfix)
        # print ("md5 is {}".format(md5))
        json = '{\
        \n\t"packageUrl" : "http://%(cdn_url)s/manifest/%(new_ver)s/%(cur_ver)s",\
        \n\t"remoteVersionUrl" : "http://%(url)s/version2.php?manifest=version&manifest_version=%(new_ver)s",\
        \n\t"remoteManifestUrl" : "http://%(url)s/version2.php?manifest=project&manifest_version=%(new_ver)s",\
        \n\t"version" : "%(new_ver)s",\
        \n\t"engineVersion" : "Cocos2d-x v3.16",\
        \n\t"assets" : {\
        \n\t\t"%(zipname)s":{"md5":"%(md)s","compressed":true}\
        \n\t},\
        \n\t"file_size":"%(file_size)s",\
        \n\t"searchPaths":["src/","res/"]\
        \n}' % {'new_ver':new_ver, 'cur_ver':cur_ver, 'zipname':config.zipname + config.postfix, 'md':md5, 'url':config.url, 'cdn_url':config.cdn_url, 'file_size':file_size}
        # print ("json is {}".format(json))
        f = file(save_dir+"project.manifest", "w+")
        f.write(json)
        f.close()
        #generate version.manifest
        json = '{\
        \n\t"packageUrl" : "http://%(cdn_url)s/manifest/%(new_ver)s/%(cur_ver)s",\
        \n\t"remoteVersionUrl" : "http://%(url)s/version2.php?manifest=version&manifest_version=%(cur_ver)s",\
        \n\t"remoteManifestUrl" : "http://%(url)s/version2.php?manifest=project&manifest_version=%(cur_ver)s",\
        \n\t"version" : "%(new_ver)s",\
        \n\t"file_size":"%(file_size)s",\
        \n\t"engineVersion" : "Cocos2d-x v3.16"\n}' % {'new_ver':new_ver, 'cur_ver':cur_ver, 'url':config.url, 'cdn_url':config.cdn_url, 'file_size':file_size}
        f = file(save_dir+"version.manifest", "w+")
        f.write(json)
        f.close()





def cmp_str(str1,str2):
    len1 = len(str1)
    len2 = len(str2)
    if len1 != len2:
        return False
    for i in range(0,len1):
        if str1[i] != str2[i]:
            return false

    return True

def check_different(old_list_file,new_list):
    new_list_dic = {}
    for line in new_list:
        sp = line.split(':')
        new_list_dic[sp[0]] = sp[1]

    f = open(old_list_file,"r")
    f.seek(0)  

    #list in file
    old_list_dic = {}
    for line in f:
        sp = str(line).strip().split(':')
        if len(sp) != 2:
            continue
        old_list_dic[sp[0]] = sp[1]
    f.close()

    arr = []
    for key,val in new_list_dic.iteritems():
        if not old_list_dic.has_key(key):
            arr.append(key)
        else:
            if val != old_list_dic[key]:
                arr.append(key)

    return arr

def write_version(save_dir,version):
    fp=open(save_dir+version_file,'w')
    fp.truncate()
    fp.write(str(version))
    fp.flush()
    fp.close()

def trim_dir(file_dir):
    file_dir = file_dir.strip().replace("\\","/")

    endc = file_dir[len(file_dir)-1]
    if endc != "/":
        file_dir += "/"
    return file_dir


# def zip_update_file(res_dir,save_dir,cur_ver,new_ver,zip_name):
#     res_dir = trim_dir(res_dir)
#     save_dir = trim_dir(save_dir)

#     save_new_ver_list_dir = save_dir+str(new_ver)
#     save_new_ver_dir = save_dir

#     if not os.path.exists(save_new_ver_list_dir):
#         os.makedirs(save_new_ver_list_dir)
    
#     save_cur_ver_dir = save_dir+"/"+str(cur_ver)+"/"
#     old_list_file = save_cur_ver_dir + "list.txt"

#     cur_res_list = gen_md5_list(res_dir)
#     update_files = []
#     if not os.path.exists(old_list_file):
#         update_files = cur_res_list
#         arr = []
#         for line in update_files:
#             arr.append(line.split(":")[0])
#         update_files = arr
#     else:
#         update_files = check_different(old_list_file,cur_res_list)
#     cnt = 0
#     z = ZFile(zip_name,"w",save_new_ver_dir,res_dir)
#     for line in update_files:
#         cnt += 1
#         filename = res_dir + line
#         z.addfile(filename)
#     z.close()

#     gen_md5_list_file(cur_res_list,res_dir,save_new_ver_list_dir)

#     write_version(save_dir+"/",new_ver)


def zip_update_file(res_dir,save_dir,cur_ver,new_ver,gen_base_ver=True):
    res_dir = trim_dir(res_dir)
    save_dir = trim_dir(save_dir)

    save_new_ver_list_dir = save_dir+str(new_ver)+"/"
    if new_ver == config.baseVersion:
        save_new_ver_dir = save_new_ver_list_dir
    else:
        save_new_ver_dir = save_new_ver_list_dir+str(cur_ver)+"/"

    if not os.path.exists(save_new_ver_dir):
        os.makedirs(save_new_ver_dir)
    
    #old version dir
    save_cur_ver_dir = save_dir+"/"+str(cur_ver)+"/"
    #old file list
    old_list_file = save_cur_ver_dir + "list.txt"

    if not os.path.exists(old_list_file):
        #gen base version file
        if gen_base_ver:#new_ver != config.baseVersion:
            zip_update_file(res_dir,save_dir,config.baseVersion,config.baseVersion,False)
    # print ("res_dir is {}".format(res_dir))
    # cur_res_list = gen_md5_list(res_dir)
    cur_res_list = gen_md5_list(trim_dir(file_path))
    # print ("cur_res_list is {}".format(cur_res_list))
    update_files = []
    if not os.path.exists(old_list_file):
        update_files = cur_res_list
        arr = []
        for line in update_files:
            arr.append(line.split(":")[0])
        update_files = arr
    else:
        update_files = check_different(old_list_file,cur_res_list)
    # print ("update_files is {}".format(update_files))
    #gen zip file
    cnt = 0
    z = ZFile(config.zipname + config.postfix,"w",save_new_ver_dir,res_dir)
    # print ("save_new_ver_dir is {}".format(save_new_ver_dir))
    for line in update_files:
        cnt += 1
        filename = res_dir + line
        # print filename + " start \n"
        z.addfile(filename)
        # print filename + " end \n"
    # print "z addfile end \n"
    z.close()
    # print "z close \n"
        
    # if len(update_files) > 0:
    #   z = ZFile(config.zipname,"w",save_new_ver_dir,res_dir)
    #   for line in update_files:
    #       cnt += 1
    #       filename = res_dir + line
    #       #print filename
    #       z.addfile(filename)
    #   z.close()
    print "write %d files into %s" %(cnt,save_new_ver_dir+config.zipname + config.postfix)

    gen_md5_list_file(cur_res_list,res_dir,save_new_ver_list_dir)

    gen_md5_manifest_file(save_new_ver_dir, cur_ver, new_ver)

    write_version(save_dir+"/",new_ver)


if __name__ == "__main__": 
    the_ver=sys.argv[1]
    the_path=sys.argv[2]

    cur_path = get_cur_path()
    cur_path = trim_dir(cur_path)

    file_path = cur_path + "file"
    res_file_path = cur_path + "res_file/"
    manifest_path = cur_path +"manifest"
    version_file = "/version_" + the_path

    gitupdate()
    preProcess(the_ver)


