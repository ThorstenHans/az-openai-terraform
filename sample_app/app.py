import os
import openai
from flask import Flask, request
from logging.config import dictConfig

dictConfig({
    'version': 1,
    'formatters': {'default': {
        'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    }},
    'handlers': {'wsgi': {
        'class': 'logging.StreamHandler',
        'stream': 'ext://flask.logging.wsgi_errors_stream',
        'formatter': 'default'
    }},
    'root': {
        'level': 'INFO',
        'handlers': ['wsgi']
    }
})


app = Flask(__name__)

@app.route('/ask', methods=['POST'])
def ask():
    content = request.json
    question = content['question']

    if not question:
        return ('', 400)

    app.logger.info("Processing question: %s", question)
    openai.api_base = os.getenv('OPENAI_API_URL')
    openai.api_type = "azure"
    openai.api_version = os.getenv('OPENAI_API_VERSION')
    openai.key = os.getenv("OPENAI_API_KEY") 
    
    deployment_name = os.getenv('DEPLOYMENT_NAME')

    response = openai.ChatCompletion.create(
                engine=deployment_name,
                messages=[
                    {"role": "system", "content": "You are a helpful assistant called Jarvis. Always introduce yourself. Always answer in Markdown. You may only answer questions related to software development and engineering. You can use emojis if appropriate."},
                    {"role": "user", "content": question}
                ]
            )
    # print(response)
    return response

@app.route('/healthz/liveness')
def liveness():
    app.logger.debug("Liveness probe invoked")
    return "OK"

@app.route('/healthz/readiness')
def readiness():
    app.logger.debug("Readiness probe invoked")
    return "OK"
