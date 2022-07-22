@chcp 65001

@REM Для работы данного скрипта необходимо: 
@REM    1. установить пакет vannessa-runner - https://github.com/oscript-library/vanessa-runner
@REM    2. развернуть службу ras на сервере 1С - https://infostart.ru/1c/articles/810752/ 

@REM Путь к файлу настроек
set settings_path = settings.json

@REM Отключить сеансы, установить блокировку новых подключений (выполняет в среднем 1,5 - 3 минуты)
call vrunner session kill --settings %settings_path%

@REM Обновим информационную базу из хранилища
call vrunner loadrepo --settings %settings_path%

@REM Обновим информационную базу
call vrunner updatedb --settings %settings_path%

@REM Отключим блокировку новых подключений
call vrunner session unlock --settings %settings_path%