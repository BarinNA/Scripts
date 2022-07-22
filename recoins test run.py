import subprocess
import os
import shutil

def runTests(basename, path_tests, path_allurereport):

    path_add = os.path.join("C:\\1C_DATA","Tests", "add")

    path_1c = r"C:\Program Files\1cv8\8.3.13.1513\bin\1cv8.exe"

    #очистим каталог path_allurereport от прошлых отчетов
    os.chdir(path_allurereport)

    for file in os.scandir(path_allurereport):
        if not os.path.isdir(file.path):
            os.remove(file.path)

    #сменим рабочую директорию т.к. не удалось добится запуска по абсолютному пути
    os.chdir(path_add)

    run_command     = f"ENTERPRISE /s localhost\{basename} /N backup /P 081172370 /RunModeManagedApplication /DisableStartupMessages"
    execute_command = "/Execute xddTestRunner.epf"
    test_command    = [f"/C xddRun ЗагрузчикКаталога {path_tests}; xddReport ГенераторОтчетаAllureXMLВерсия2 {path_allurereport}/json_for_allure {path_allurereport};xddShutdown"]

    command = [path_1c] + run_command.split() + execute_command.split() + test_command
    subprocess.run(command, shell = False)



#переделать на json с настройками
t1 = {'basename': 'reconsiled_base', 'path_tests': 'C:/1C_DATA/Tests/recoins', 'path_allurereport': 'C:/1C_DATA/Allure/1C_reports/recoins_rep'}
t2 = {'basename': 'white_travel', 'path_tests': 'C:/1C_DATA/Tests/white', 'path_allurereport': 'C:/1C_DATA/Allure/1C_reports/white_rep'}

#t1 = {'basename': 'reconsiled_base', 'path_tests': 'C:/1C_DATA/Tests/recoins', 'path_allurereport': 'C:/1C_DATA/Allure/for_testing'}

tests = []
tests.append(t1)
tests.append(t2)

print("Запускаем тесты.")

for test in tests:
   runTests(test['basename'], test['path_tests'], test['path_allurereport'])

print("Тесты пройдены.")

path_allurehtml = r"C:\1C_DATA\Allure\html_report"    
path_allure     = r'"C:\Program Files (x86)\allure-commandline-2.10.0\allure-2.10.0\bin\allure.bat"'

#----------------------------------------------------------------------------------------------
#Запуск Allure

#Переместим папку C:\1C_DATA\Allure\html_report\history в папку C:\1C_DATA\Allure\1C_reports
#Это делается для корректного формирования трендов

if os.path.exists(t1['path_allurereport'] + '/history'):
    shutil.rmtree(t1['path_allurereport'] + '/history') 

if os.path.exists(path_allurehtml + '/history'):
    shutil.copytree(path_allurehtml + '/history', t1['path_allurereport'] + '/history') 

print("Запускаем формирование отчетов")

#соберем строку из путей к папкам с данными отчетов
path_reports1c = ''
for test in tests:
    path_reports1c = path_reports1c + test['path_allurereport'] + ' '

#Запустим формирование отчета allure
command = f'{path_allure} generate --clean {str.strip(path_reports1c)} -o {path_allurehtml}' 
subprocess.run(command, shell = True)

print("Отчеты сформированы")
