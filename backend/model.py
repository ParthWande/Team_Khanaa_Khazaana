from langchain.memory import ConversationBufferMemory
from langchain.prompts import PromptTemplate
from langchain.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_community.llms import CTransformers

import concurrent
from langchain.chains import RetrievalQA
DB_FAISS_PATH = 'New folder/vectorstore/db_faiss'

custom_prompt_template = """Use the following pieces of information to answer the user's question.
If you don't know the answer, just say that you don't know, don't try to make up an answer.
You are a pharmacist for medicine so be polite and greet the customer. you are a pharmacist

Context: {context}
Question: {question}

Only return the helpful answer below and nothing else.
Helpful answer:
"""

def set_custom_prompt():
    """
    Prompt template for QA retrieval for each vectorstore
    """
    prompt = PromptTemplate(template=custom_prompt_template,
                            input_variables=['history','context', 'question'])
    return prompt

#Retrieval QA Chain
def retrieval_qa_chain(llm, prompt, db):
    qa_chain = RetrievalQA.from_chain_type(llm=llm,
                                       chain_type='stuff',
                                       retriever=db.as_retriever(search_kwargs={'k': 2}),
                                       return_source_documents=True,
                                       chain_type_kwargs={'prompt': prompt,
                                                          "memory": ConversationBufferMemory(memory_key="history", input_key="question"), 
                                                          }
                                       
                                       )
    return qa_chain

#Loading the model
def load_llm():
    # Load the locally downloaded model here
    llm = CTransformers(
        model = "TheBloke/Llama-2-7B-Chat-GGML",
        model_type="llama",
        max_new_tokens = 2048,
        temperature = 0.5
    )
    return llm

llm = load_llm()
qa_prompt = set_custom_prompt()
embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2",
                                       model_kwargs={'device': 'cpu'})
db = FAISS.load_local(DB_FAISS_PATH, embeddings)

#QA Model Function
def qa_bot():
  
    qa = retrieval_qa_chain(llm, qa_prompt, db)

    return qa

#output function
def final_result(query):
    qa_result = qa_bot()
    response = qa_result({'query': query})
    return response['result']

def parallel_qa(query):
    with concurrent.futures.ThreadPoolExecutor() as executor:
        future = executor.submit(final_result, query)
        return future.result()

def chatbot(userinput):
   
    user_input = userinput
    if any(word in user_input.lower() for word in ('bye','thanks','thank','time','thank you','goodbye','adios','see you later','later','farewell')):
        return ("Goodbye! If you have more questions in the future, feel free to ask. Take care!")
        
    else:
        answer = parallel_qa(user_input)
        return answer

