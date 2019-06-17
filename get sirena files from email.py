import imaplib
import email
import os.path as path
import os
import gzip 
import io
import random

host = "imap.gmail.com"
port = 993
user = "andrey.noskov@onetwotrip.com"
pas  = "S081172370n"

folder = "C:\\Sirena_Online_Ticket\\email_reps\\"

Connection = imaplib.IMAP4_SSL(host = host, port=port)
Connection.login(user,pas)
Connection.list()

Connection.select("inbox")
result, data = Connection.search(None, '(UNSEEN)', '(FROM "city@sirena-travel.ru")')

ids = data[0]

ids_list = ids.split()

i = 0

for ids in ids_list:

    result, emaildata = Connection.fetch(ids, '(RFC822)')
    raw_email = emaildata[0][1]

    mail = email.message_from_bytes(raw_email)
    if mail.is_multipart():
        for part in mail.walk():
            content_type = part.get_content_type()
            filename = part.get_filename()
            if filename:

                i += 1    

                filetag = part.get_filename()[:-3]
                outfile_path = path.join(folder, filetag + '.txt')

                compressed_file = io.BytesIO(part.get_payload(decode = True))
                decompressed_file = gzip.GzipFile(fileobj = compressed_file)

                if os.path.exists(outfile_path):
                    r = random.randint(0, 99)
                    outfile_path = path.join(folder, filetag + f'_{r}.txt')    

                with open(outfile_path, 'wb') as outfile:
                    outfile.write(decompressed_file.read())    

print(f"done: {i} mails unpacked")            

#Удалим разобранные письма
result, data = Connection.search(None, '(SEEN)', '(FROM "city@sirena-travel.ru")')

i = 0
for num in data[0].split():
    Connection.store(num, '+FLAGS', '\\Deleted')
    i += 1

print(f"done: {i} emails deleted")

Connection.expunge()
Connection.close()
Connection.logout()



