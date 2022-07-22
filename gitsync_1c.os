
//Скрипт выполняет синхронизацию настроенных хранилищ с репозиторием

Процедура ВыполнитьСинхронизацию()

	ПутьКФайлуНастроек = "C:\1C_DATA\settings\gitsync_1c.json";

	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл(ПутьКФайлуНастроек);
	
	Попытка
		НастройкиПодключения = ПрочитатьJSON(ЧтениеJSON);
	Исключение
		Сообщить("Не удалось прочитать файл настроек плдключения " + ОписаниеОшибки());
		Возврат;
	КонецПопытки;	 	
	
	Для Каждого Стр Из НастройкиПодключения.Settings Цикл

		СтрокаКоманды = "gitsync sync --storage-user " + Стр.User + " " + Стр.Storage + " " 
			+ Стр.Repo;

		Попытка	
			ЗапуститьПриложение(СтрокаКоманды);
		Исключение
			Сообщить(ОписаниеОшибки());
			Продолжить;
		КонецПопытки;	

	КонецЦикла;	


КонецПроцедуры	

ВыполнитьСинхронизацию();