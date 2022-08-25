import requests
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--msg',type=str , help = 'message to be sent')
parser.add_argument('--type',type=str , help = 'type of file')
parser.add_argument('--path',type=str , help = 'path of the file')
parser.add_argument('--caption',type=str , help = 'caption to the file')
args = parser.parse_args()

def telegram_bot_sendtext(bot_message):

   bot_token = "5289342558:AAEhXTwpk3p6qDjI_NLOx4gkOM4eTONmuXQ"
   bot_chatID = "1129722320"
   if(args.type == "photos"):
        send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&parse_mode=Markdown&text=' + args.msg
        response = requests.get(send_text)
   else:
        files = {'document':open(args.path,'rb')}
        send_text = 'https://api.telegram.org/bot' + bot_token + '/sendDocument?chat_id=' + bot_chatID + '&caption=' + args.caption
        response = requests.post(send_text, files=files)

   return response.json()


test = telegram_bot_sendtext(args.msg)
print(test) 
   
   




