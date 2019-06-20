#Использовать v8runner

//Скрипт автоматизирует работу с версионирования базы recoins

Процедура ВыгрузитьКонфигурацию(ИзФайловой)
	
	Конфигуратор = Новый УправлениеКонфигуратором();
	
	Если Не ИзФайловой Тогда
		Конфигуратор.УстановитьКонтекст("/IBConnectionString""Srvr=localhost; Ref='reconsiled_base'""", "backup", ",'rfg1c");
	Иначе
		Конфигуратор.УстановитьКонтекст("/IBConnectionString""file=C:\1C_DATA\recions_dev2""", "", "");
	КонецЕсли;
	
	ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
	
	КаталогВыгрузки = "C:\1C_DATA\git\recoins";
	
	ПараметрыЗапуска.Добавить("/DumpConfigToFiles """ + КаталогВыгрузки + """ -update");
	
	Попытка
		Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Сообщить("Конфигурация выгружена в файлы");
	Исключение
		Сообщить(Конфигуратор.ВыводКоманды());
	КонецПопытки;
	
КонецПроцедуры

//Собираем cf файл конфигурации из разобранной конфы
Процедура СобратьКонфигурацию(Параметры)
	
	КаталогФайлов = Параметры.ПутьКИсходникам;
	КаталогСФ = КаталогФайлов + "\recoins_" + Формат(ТекущаяДата(), "ДФ=dd.MM.yyyy") + ".cf";
	
	Сообщить("Создаем временную базу");
	
	Конфигуратор = Новый УправлениеКонфигуратором();
	ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
	ПараметрыЗапуска.Добавить("/LoadConfigFromFiles """ + КаталогФайлов + """");
	
	Попытка
		Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Сообщить("Конфигурация загружена во временную ИБ");
	Исключение
		Сообщить(Конфигуратор.ВыводКоманды());
	КонецПопытки;
	
	ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
	ПараметрыЗапуска.Добавить("/DumpCfg  """ + КаталогСФ + """");
	
	Попытка
		Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Сообщить("Конфигурация выгружена в cf");
	Исключение
		Сообщить(Конфигуратор.ВыводКоманды());
	КонецПопытки;
	
	Сообщить("Удаляем временную базу");
	УдалитьФайлы(Конфигуратор.ПутьКВременнойБазе());
	
КонецПроцедуры

//Процедура переходит на нужную ветку, выгружает туда тек. конфигурацию, индексирует изменения и комитит их
Процедура ВыгрузитьДоработкиВВетку(ПараметрыПроцедуры)
	
	//Перейдем в рабочий каталог
	УстановитьТекущийКаталог("C:\1C_DATA\git\recoins");
	
	//Перейдем в ветку
	ЗапуститьПриложение("git checkout " + ПараметрыПроцедуры.Ветка);
	
	//Выгрузим конфу в файлы
	Конфигуратор = Новый УправлениеКонфигуратором();
	
	Конфигуратор.УстановитьКонтекст(ПараметрыПроцедуры.СтрокаСоедиенения, 
									ПараметрыПроцедуры.Логин, ПараметрыПроцедуры.Пароль);
	
	//"/IBConnectionString""Srvr=localhost; Ref='reconsiled_base'"""

	ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
	
	КаталогВыгрузки = "C:\1C_DATA\git\recoins";
	ПараметрыЗапуска.Добавить("/DumpConfigToFiles """ + КаталогВыгрузки + """ -update");
	
	Попытка
		Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Сообщить("Конфигурация выгружена в файлы");
	Исключение
		Сообщить(Конфигуратор.ВыводКоманды());
		Возврат;
	КонецПопытки;
	
	//Проиндексируем изменения
	Попытка
		ЗапуститьПриложение("git add -A",,Истина);
		Сообщить("Изменения проиндексированы");
	Исключение
		Сообщить("Не удалось проиндексировать изменения - " + ОписаниеОшибки());
		Возврат;
	КонецПопытки;		


	//Закомитем
	ТекстКомита = "data for " + Формат(ТекущаяДата(), "dd.MM.yyyy");

	Попытка
		ЗапуститьПриложение("git commit -a -m """ + ТекстКомита + """",, Истина);
		Сообщить("Изменения закоммичены");
	Исключение
		Сообщить("Не удалось закомитить изменения - " + ОписаниеОшибки());
	КонецПопытки;		
	
КонецПроцедуры

ИзФайловой		 = АргументыКоманднойСтроки.Найти("f") <> Неопределено;
ИзБазыАлексея	 = АргументыКоманднойСтроки.Найти("d") <> Неопределено;
ИзПрода			 = АргументыКоманднойСтроки.Найти("m") <> Неопределено;
Собрать_CF		 = АргументыКоманднойСтроки.Найти("cf") <> Неопределено;
Подсказка		 = АргументыКоманднойСтроки.Найти("-h") <> Неопределено 
					ИЛИ АргументыКоманднойСтроки.Найти("-help") <> Неопределено;

ПараметрыПроцедуры = Новый Структура("Ветка, СтрокаСоедиенения, Логин, Пароль",,,"","");

Если Подсказка Тогда
	ТекстПодсказки = "аргументы: [cf] будет создан cf в этой папке, 
		|[f] выгрузка из файловой базы, 
		|[d] выгрузка из базы Алексея в ветку recoins_dzyuban,
		|[m] выгрузка из основной базы в ветку master";
	Сообщить(ТекстПодсказки);
ИначеЕсли ИзБазыАлексея Тогда

	ПараметрыПроцедуры.Ветка = "recoins_dzyuban";
	ПараметрыПроцедуры.СтрокаСоедиенения = "/IBConnectionString""file=C:\Users\alexey.dzuban\Documents\СверочнаяТестовая""";

	ВыгрузитьДоработкиВВетку(ПараметрыПроцедуры);
ИначеЕсли ИзПрода Тогда

	ПараметрыПроцедуры.Ветка = "master";
	ПараметрыПроцедуры.СтрокаСоедиенения = "/IBConnectionString""Srvr=localhost; Ref='reconsiled_base'""";
	ПараметрыПроцедуры.Логин = "backup";
	ПараметрыПроцедуры.Пароль = ",'rfg1c";

	ВыгрузитьДоработкиВВетку(ПараметрыПроцедуры);
ИначеЕсли Не Собрать_CF Тогда
	ВыгрузитьКонфигурацию(ИзФайловой);
ИначеЕсли Собрать_CF Тогда

	//Обработка подсказки
	Если Подсказка = АргументыКоманднойСтроки.Найти("-h") <> Неопределено 
		ИЛИ АргументыКоманднойСтроки.Найти("-help") <> Неопределено Тогда

		ТекстПодсказки = "Команда cf служит для сборки cf файла из исходников
		|В качестве аргумента команды cf передаетися путь к папке исходников.
		|Если путь не указан, то ищем исхъодники в текущем рабочем каталоге";

		Сообщить(ТекстПодсказки);
	
	Иначе
		
		//Обработка выполнения
		Если АргументыКоманднойСтроки.Количество() < 2 Тогда
			ПутьКИсходникам = ТекущийКаталог(); 
		Иначе
			ПутьКИсходникам = АргументыКоманднойСтроки[1];
		КонецЕсли;
		
		ПараметрыСбораCF.Вставить("ПутьКИсходникам", ПутьКИсходникам);
		СобратьКонфигурацию(ПараметрыСбораCF);	
		
	КонецЕсли;	
		
Иначе
	Сообщить("не понятно что делать");	
КонецЕсли;

