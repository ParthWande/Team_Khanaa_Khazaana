from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def med_classifier(medicine_names, target_medicine, top_n=2):

    vectorizer = TfidfVectorizer()

    X = vectorizer.fit_transform(medicine_names)

    target_vector = vectorizer.transform([target_medicine])

    cosine_sim = cosine_similarity(target_vector, X)

    top_indices = cosine_sim.argsort()[0][-top_n:][::-1]


    medicine_similarities = [(medicine_names[index], cosine_sim[0][index]) for index in range(len(medicine_names))]


    top_medicines = [medicine_names[index] for index in top_indices]

 
    
    return top_medicines