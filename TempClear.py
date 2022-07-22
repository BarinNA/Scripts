
import os
import shutil
import datetime

print("Запускаем обработку")

tempPath = "C:\\Users\\barin_\\Downloads\\temp"
fileList = os.listdir(tempPath)

deleteMoment = datetime.datetime.today() - datetime.timedelta(days=7)

print('Все файлы ранее {0} будут удалены'.format(deleteMoment.strftime("%Y-%m-%d")))

i = 0

for filePath in fileList:
    
    fullpath = os.path.join(tempPath,filePath)
    t = os.path.getmtime(fullpath)
    
    if  datetime.datetime.fromtimestamp(t) < deleteMoment:
        
        if os.path.isdir(fullpath):
            shutil.rmtree(fullpath)
        else:
            os.remove(fullpath) 
        
        i += 1

print('Удалено файлов - {0}'.format(i))        
