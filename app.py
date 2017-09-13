from flask import Flask
app = Flask(__name__, static_url_path="/static")

@app.route("/hello")
def hello():
    return {greeting: "hello world"}
