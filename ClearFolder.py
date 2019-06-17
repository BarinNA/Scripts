import os

folderPath = "C:\\Users\\andrey.noskov\\Documents\\DailyTemp"

for p in os.scandir(folderPath):
    os.remove(os.path.join(folderPath,p.name))
    
   