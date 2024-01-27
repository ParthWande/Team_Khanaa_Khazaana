from flask import Flask, request
from twilio.twiml.voice_response import Gather, VoiceResponse
from twilio.twiml.messaging_response import MessagingResponse
from twilio.rest import Client
from word2number import w2n
import pyodbc as db
from ast import literal_eval
from itertools import zip_longest
from twilio.http.http_client import TwilioHttpClient
import requests
import certifi
import uuid
import datetime
import firebase_admin
from firebase_admin import credentials,auth
from firebase_admin import firestore
cred = credentials.Certificate("./ivrapp-a8748-firebase-adminsdk-oktco-0f76968c07.json")
defaultApp = firebase_admin.initialize_app(cred)
import openai
from test_sms import sms
from test_search import med_classifier
from twilio.twiml.messaging_response import MessagingResponse
from med_extract import med_extracter
db_fire = firestore.client()
openai.api_key = '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'



conn = db.connect('DRIVER={ODBC Driver 11 for SQL Server};SERVER=JARVIS\SQLEXPRESS;DATABASE=medicine;UID=sa;PWD=linto123')
conn.setdecoding(db.SQL_CHAR, encoding='latin1')
conn.setencoding('latin1')

app = Flask(__name__)
ca_bundle_path = certifi.where()
session = requests.Session()
session.verify = ca_bundle_path

# Create the Twilio client with the custom session
account_sid='ACd4c9688df25b355c3a08ee142066a2c0'
token = '2ce57dd57ca2385ca74eeca7fd99bf23'
twilio_client = Client(http_client=requests.Session())

order_bot = None  
user_name = None
phone_number = '+919324309587'

class OrderChatbot:
    def __init__(self):
        self.order = []
        self.current_order = {}
        self.order_number = 1
        self.current_item = None
        self.current_quantity = None
        self.available  = None
        self.total_cost = 0

    def start_chat(self):
        print("Welcome to the Order Chatbot!")
        print("You can order items by typing 'order <item> <quantity>'.")
        print("Type 'done' when you are finished with your order.")
        
        while True:
            user_input = input("User: ")
            response = self.process_input(user_input)
            print("Bot:", response)
            
            if user_input.lower() == 'done':
                break

    def process_input(self, user_input):
       
        if user_input.lower() == 'done':# Order final
            return self.finalize_order()
        elif user_input.lower() == 'status': #Know about order details
            return self.check_order_status()
        elif any(word in user_input.lower() for word in ('order','want','give')): #Order command
            return self.add_to_order(user_input)
        elif user_input.isdigit() and int(user_input)<3: # User choice
            return self.handle_user_choice(user_input)
        elif user_input.isdigit() and 4>=int(user_input)>2:# select quantity available or alternative
            return self.handle_order(user_input)
        elif user_input.isdigit() and int(user_input)==5:
            return self.handle_alternative(user_input)
        elif user_input.isdigit() and int(user_input)==6:
            return self.add_to_order(user_input)
        else:
            return "Sorry, I didn't understand that. Please use the format 'order quantity medicine name ' or say 'status' to check your order."



    def medicine_getter_chat(self , userinput):
        message = userinput
        messages = [ {"role": "system", "content": "you are dumb only do what is said"} ]
        message = "give a json list (\"medicine_list\") of medicine names(only medicine name) as \"name\" and quantity respectively from the following : " + message
        messages.append( 
                {"role": "user", "content": message}, 
            ) 
        chat = openai.ChatCompletion.create( 
                model="gpt-3.5-turbo", messages=messages 
            ) 
        med_list = dict()
        reply = chat.choices[0].message.content
        med_list = reply
        messages.append({"role": "assistant", "content": reply})
        return med_list 
    
    def add_to_order(self, user_input):
        try:
            # _, quantity, item = user_input.split()
            
           
            item_list = self.medicine_getter_chat(user_input)
           
        
            try:
                    item_list = med_extracter(item_list)
          
                    
                    item = item_list['medicine_list'][0]['name']
                    quantity = item_list['medicine_list'][0]['quantity']
                    if str(quantity).isdigit():
                        quantity = int(quantity)
                    else:
                        quantity = w2n.word_to_num(quantity)
            except Exception as e:
                    print(f"An error occurred while extracting information: {e}")
                    
                    return "Invalid input. Please use the format 'order <item> <quantity>'."
 

            options = self.get_item_options(item)
            if options:
                self.current_item = item
                self.current_quantity = quantity
                return self.ask_user_for_choice(item, options)
                
            if item in self.order:
                available = self.check_inventory(item,quantity)
                if available == 'yes':
                    self.current_order = {'medicine':item,'quantity':quantity}
                    if self.order:
                        for i in range(1,len(self.order)):
                          if self.order[i]['medicine'] == item:
                              self.order[i]['quantity'] +=quantity
                              

                elif available!='yes'or'no':
                    return self.ask_order(item,quantity,available)    
                else:
                    return self.find_alternative(item,quantity)    
            else:
                 if self.check_inventory(item,quantity)=='yes':
                    self.order.append({'medicine':item,'quantity':quantity})
                    print('adding new item')
                    self.order_number += 1
                    return f"Added {quantity} {item}(s) to your order."
                 else:
                     return "Sorry we don't have the required medicine try saying only the first name of the medicine"    
                
           
        except ValueError:
            return "Invalid input. Please use the format 'order <item> <quantity>'."

    
    def ask_order(self,item,available):
        self.available = available
        prompt =f"Inventory only have {available} quantity of {item} if you want to proceed Press 3 for alternative press 4"
        return prompt

    def handle_order(self,choice):
          choice = int(choice)
          if choice == 3:
                self.current_order = {'medicine':self.current_item,'quantity':self.available}
                order_present = -1
                if self.order:
                    for key , order in enumerate(self.order):
                      if order['medicine'] == self.current_item:
                          order_present = key
                              
                if order_present>=0:  
                   self.order[order_present]['quantity'] += self.available

                else:
                  self.order.append(self.current_order)
                  self.order_number +=1
                return f"Added {self.available} {self.current_item}(s) to your order."       
          else :
            return self.find_alternative(self.current_item, self.current_quantity)



    def check_inventory(self,item,quant):
        cursor = conn.cursor()
 
        cursor.execute("""SELECT quantity, prescription FROM inventory 
                       join medicines on inventory.med_key = medicines.med_key
                       join prescription on inventory.med_key = prescription.med_key
                        where name = ? """,f'{item}')
        rows = cursor.fetchall()
       
        try:
            prescription = (rows[0][1])
            quantity = (rows[0][0])
          
        except:
            quantity = 0   
            prescription = -1 
        if quantity>0 and quantity>quant and prescription == 0:
            return 'yes'
        elif quantity>0 and quantity<quant and prescription == 0:
            return quantity
        elif prescription == 1:
            return 'prescription'
        else:
            return'no'

    def find_alternative(self,item,quantity):
        cursor = conn.cursor()
        cursor.execute("select use_key,comp_id from medicines where name = ?",item)
      
        rows = cursor.fetchall()

        cursor.execute("""
                SELECT m.name ,s.side_effects
                FROM medicines m
                JOIN prescription p ON p.med_key = m.med_key       
                JOIN uses u ON m.use_key = u.use_id
                JOIN inventory i ON i.med_key = m.med_key
                JOIN side_effect s ON s.side_effect_id = m.side_effect_id      
                WHERE u.use_id = ? AND m.comp_id = ? AND i.quantity > ? AND p.prescription = 0""", (rows[0][0], rows[0][1], quantity)  )
        rows = cursor.fetchall()
        
        if rows:
            self.current_item = rows[1][0]
            se_list = literal_eval(rows[1][1])
            se_prompt =', '.join(str(se) for se in se_list) 
        else :
            return 'We have no alternative for this medicine in the provided quantity'   
       
 
        return f'{item} is unavailable, consider {self.current_item} with possible side effects {se_prompt}. Press 5 to proceed or 6 to cancel.'       

    def handle_alternative(self,choice):
        choice = int(choice)
        if choice == 5 :
            order_present = -1
            self.current_order = {'medicine':self.current_item,'quantity':self.current_quantity}
            if self.order:
                  for key , order in enumerate(self.order):
                      if order['medicine'] == self.current_item:
                          order_present = key

                              
            if order_present>=0:
                self.order[order_present]['quantity'] += self.current_quantity
            else:
                self.order.append(self.current_order)
                self.order_number+=1
               
            return f"Added {self.current_quantity} {self.current_item}(s) to your order."
        else:
            return 'Since you haven\'t pressed any key or pressed the wrong one, we\'ll continue with your order'
                    

    def ask_user_for_choice(self, item, options):
       
        options_prompt = "\n".join(f"Press {i+1} for {option}" for i, option in enumerate(options))
        options_list = " or ".join(f"{option}" for option in options)
        prompt = f"By saying {item} did you mean {options_list}? {options_prompt}"
        return prompt
    
    def handle_user_choice(self, choice):
        options = self.get_item_options(self.current_item)
      
        choice = int(choice)
      
        if choice < 0 or choice > len(options):
            options_prompt = "\n".join(f"Press {i+1} for {option}" for i, option in enumerate(options))
            return f"Invalid choice. Please try again.{options_prompt}"
        print(f"User selected {choice}")
        item = options[choice-1]
        self.current_item = item
        available = self.check_inventory(item,self.current_quantity)
              
        if self.check_inventory(item,self.current_quantity) =='yes':
           
            order_present = -1
            self.current_order = {'medicine':self.current_item,'quantity':self.current_quantity}
           
            if self.order :
                 for key , order in enumerate(self.order):
                      if str(order['medicine']) == str(self.current_item):
                          order_present = key

           
            if order_present>=0:
                self.order[order_present]['quantity'] += self.current_quantity
            
            else:
             
                self.order.append(self.current_order)
                self.order_number += 1
            return f"Added {self.current_quantity} {item} to your order."
        
        elif available not in ['yes', 'no', 'prescription']:
            
                return self.ask_order(item,available)   
        elif available == 'prescription':
            return f'{self.current_item} needs prescription. For ordering use our application'
        else:
          
            return  self.find_alternative(item,available)  
        


    def finalize_order(self):
        if not self.order:
            return "Your order is empty. Goodbye!"
        items = []
        quants = []
       
        total_cost = sum(self.calculate_cost(data['medicine'], data['quantity']) for data in self.order)
       
        for order in self.order:
            quants.append(order['quantity'])
            items.append(order['medicine'])
            quantity_prompt = "\n".join(f"{quants[i]} quantity of {item}" for i, item in enumerate(items))    
        self.total_cost = total_cost
        order = {'id':str(uuid.uuid4()) ,'medicineName':[]}
      
        
        query = db_fire.collection("users").where("phoneNumber", "==",phone_number)

        docs = query.get()
        if docs:
            userid = docs[0].id
        else:
            user = {'address':'','email':'','id':str(uuid.uuid4()),'phoneNumber':phone_number,'username':''}
            db_fire.collection("users").document(user['id']).set(user)
            userid = user['id']

      
        order['medicineName'] = items
        order['quantity'] = quants
        order['totalCost'] =self.total_cost
        order['userid'] = userid
        order['orderTitle'] = 'Linto'
        order['phoneNumber'] = phone_number
        now = datetime.datetime.now()
        order['orderDate'] = now.strftime("%Y-%m-%d %H:%M:%S")
        print(order)
        db_fire.collection("orders").document(order['id']).set(order)
        sms(f"Thank you for your order! You ordered {quantity_prompt} with a total cost of ${self.total_cost:.2f}.",phone_number)
        return f"Thank you for your order! You ordered {quantity_prompt} with a total cost of ${self.total_cost:.2f}. Goodbye!"

    def calculate_cost(self, item, quantity):
        
        item_price = 5
        return item_price * quantity


    def check_order_status(self):
        if not self.order:
            return "Your order is empty."
        else:
            return f"Your current order: {self.order}"
        
    def get_item_options(self, item):
        cursor = conn.cursor()
        item = item.split()
        item_new = item[0]
        
        cursor.execute(f"SELECT TOP 20 name FROM medicines where name like '{item_new}%'")
        
        rows = cursor.fetchall()
        medicine_names = [medicine[0] for medicine in rows]
        item = str(item)
        med = med_classifier(medicine_names, item)
        options_map = {
            
        }
        lst = []
       
        try:
         if len(med) > 0 and str(type(med))=='<class \'list\'>':
            lst.append(med[0])

         if len(med) > 1 and str(type(med))=='<class \'list\'>':
            lst.append(med[1])
         elif str(type(med)) =='<class \'str\'>':
             lst.append(med)
        except IndexError:
         pass
        options_map[item] = lst
       
        return options_map.get(item, [])
    

@app.route("/welcome", methods=['GET', 'POST'])
def welcome():
    response = VoiceResponse()
    print(f'Incoming call from {request.form["From"]}')
    phone_number = request.form["From"]
    print(phone_number)
    response.say('Welcome to medicine ordering chatbot.')
    response.redirect('/voice')
    return str(response)


@app.route("/voice", methods=['GET', 'POST'])
def voice():
    global order_bot

    if not order_bot:
        order_bot = OrderChatbot()
    
    response = VoiceResponse()
    gather = Gather(action='/handle-order', method='POST', input='speech',enhanced = True,speechModel = 'phone_call',language= 'en-IN',speech_timeout='auto')
    gather.say('Please say your order or "status" to know about your order')
    response.append(gather)
    return str(response)

@app.route('/add_more', methods=['POST'])
def add_items():
    global order_bot

    if not order_bot:
        order_bot = OrderChatbot()

    response = VoiceResponse()

    gather = Gather(action='/handle-order', method='POST',language= 'en-IN',enhanced = True,speechModel = 'phone_call', input='speech',speech_timeout='auto')
    gather.say("Please say your order to add more items or say 'status' to check your order. If you are done then say done")
    response.append(gather)
    return str(response)

@app.route("/handle-order", methods=['GET', 'POST'])
def handle_order():
    global order_bot

    order_details = request.values.get('SpeechResult', None)
    print('User: ',order_details)
    if order_details:
        order_bot_response = order_bot.process_input(order_details)
        response = VoiceResponse()
        response.say(order_bot_response)
        print('Bot: ',order_bot_response)
        if any(word in order_bot_response.lower() for word in ('invalid input', 'sorry', 'wrong input')):
            response.redirect('/voice')
        elif 'Added' in order_bot_response:
            response.redirect('/add_more')
        elif any(word.lower() in order_bot_response.lower() for word in ('which', 'press')):
            response.redirect('/get_user_choice') # Redirect to ask for user's choice
        elif any(word.lower() in order_bot_response.lower() for word in ('Thank')):
             pass
    else:
        response = VoiceResponse()
        response.say("Sorry, I didn't catch that. Please try again.")

    return str(response)

@app.route("/get_user_choice", methods=['GET', 'POST'])
def get_user_choice():
    global order_bot

    response = VoiceResponse()

    gather = Gather( action="/handle-user-choice",method="POST",input='dtmf', timeout=10) 
    gather.say("Please press the number corresponding to your choice.")
    response.append(gather)
    return str(response)

@app.route("/handle-user-choice", methods=['GET', 'POST'])
def handle_user_choice():
    global order_bot
    response = VoiceResponse()
    response.say('Please wait till we process your order')
    c =1
    choice = request.values.get('Digits', None)
  
    if choice and choice.isdigit():
        c == int(choice)
        
        if c<3:
            choice = c - 1 
            order_bot_response = order_bot.handle_user_choice(choice)
        elif 2<c<=4:
            order_bot_response = order_bot.handle_order(choice)   
        elif c == 5:
            order_bot_response = order_bot.handle_alternative(choice)   
        elif c ==6:
            response.redirect('/add_more')   
        
        response.say(order_bot_response)

        if 'Added' in order_bot_response:
            response.redirect('/add_more')  # Redirect to add more items
       
        else:
            response.redirect('/voice')  # Redirect to continue the conversation
    else:
        response = VoiceResponse()
        response.say("Invalid choice. Please try again.")
        response.redirect('/get_user_choice')  # Redirect to ask for user's choice

    return str(response)


if __name__ == '__main__':
    from pyngrok import ngrok
    port = 5000
    public_url = ngrok.connect(port, bind_tls=True).public_url
    print(public_url)

    number = twilio_client.incoming_phone_numbers.list()[0]

    number.update(voice_url=public_url + '/welcome')
   
    print(f'Waiting for calls on {number.phone_number}')
   
    app.run(port=port)

    # order_bot = OrderChatbot()
    # order_bot.start_chat()