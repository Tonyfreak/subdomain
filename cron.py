import os
from time import sleep
import psycopg2
import base64
import subprocess

DATABASE_URL = os.environ['DATABASE_URL']

conn = psycopg2.connect(DATABASE_URL, sslmode='require')
cur = conn.cursor()

#checks the db queue table every 60 secs

try:
   cur.execute("select * from queue limit 1")
   t = cur.fetchall()
   t = t[0]
   id = t[0]
   url = t[1]
   conn.commit()
   cur.execute(f"delete from queue where id = '{id}'")
   conn.commit()
   folder = url.replace(".com","")
   #sends to run.py
   subprocess.call(['bash','/app/bas.sh',url,folder])
   #next scan starts after 1 minute
   #sleep(60)

except:
   sleep(60)

cur.close()
conn.close()
