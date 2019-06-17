import os
import shutil

localCachePath = "C:\\Users\\andrey.noskov\\AppData\\Local\\1C\\1cv8"

i = 0
for f in os.scandir(localCachePath):
    if len(f.name) > 35:
        print("remove " + f.name)
        shutil.rmtree(os.path.join(localCachePath,f.name))
        i += 1

print("Deleted {} elements".format(i))


    