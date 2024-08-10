import logging
import qi
from flask import Flask, request, jsonify
import time

app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Create a global session object
session = qi.Session()
NAO_IP = '11.255.255.105'

def ensure_connected():
    if not session.isConnected():
        logging.info("Attempting to connect to NAO robot...")
        session.connect("tcp://{}:9559".format(NAO_IP))

def make_nao_listen_and_respond(question, correct_answer):
    try:
        tts = session.service("ALTextToSpeech")
        asr = session.service("ALSpeechRecognition")
        memory = session.service("ALMemory")

        # Ensure services are available
        if not tts or not asr or not memory:
            logging.error("One or more services are unavailable.")
            return

        # Prepare NAO to ask the question
        asr.setLanguage("English")
        asr.subscribe("NAO_Answer")

        # Ask the question
        logging.info("Asking question: {}".format(question))
        tts.say(question)

        def on_speech_recognized(value):
            logging.info("Recognized: {}".format(value))
            if value and correct_answer.lower() in value[0].lower():
                tts.say("Correct")
            else:
                tts.say("Incorrect, the correct answer is {}".format(correct_answer))
            asr.unsubscribe("NAO_Answer")

        # Subscribe to the event for recognized words
        memory.subscriber("WordRecognized").signal.connect(on_speech_recognized)

        # Wait for the user to answer
        time.sleep(10)  # Increase or decrease as necessary

        # Unsubscribe after listening period
        asr.unsubscribe("NAO_Answer")

    except Exception as e:
        logging.error("Error in make_nao_listen_and_respond: {}".format(e))

def ask_multiple_questions(questions):
    try:
        for q in questions:
            question = q["question"]
            correct_answer = q["answer"]
            make_nao_listen_and_respond(question, correct_answer)
            # Short pause before asking the next question
            time.sleep(2)
    except Exception as e:
        logging.error("Error in ask_multiple_questions: {}".format(e))

@app.route('/connect_nao', methods=['GET'])
def connect_nao():
    logging.info("Received request to connect to NAO robot.")
    try:
        ensure_connected()
        if session.isConnected():
            logging.info("Making NAO speak and wave.")
            tts = session.service("ALTextToSpeech")
            motion = session.service("ALMotion")
            
            # Make NAO wave
            motion.wakeUp()
            names = ["RShoulderPitch", "RShoulderRoll", "RElbowYaw", "RElbowRoll", "RWristYaw"]
            angles = [0.5, -0.5, 0.5, 1.0, 0.3]
            times = [1.0, 1.0, 1.0, 1.0, 1.0]
            motion.angleInterpolation(names, angles, times, True)

            tts.say("Hello, I'm NAO")
            return jsonify({"status": "connected"}), 200
        else:
            return jsonify({"status": "disconnected"}), 500
    except RuntimeError as e:
        logging.error("RuntimeError: {}".format(e))
        return jsonify({"status": "failed"}), 500
    except Exception as e:
        logging.error("Unexpected error: {}".format(e))
        return jsonify({"status": "failed"}), 500

@app.route('/send_text', methods=['POST'])
def send_text():
    try:
        data = request.get_json()
        text_to_say = data.get('text', '')

        if session.isConnected():
            tts = session.service("ALTextToSpeech")
            tts.say(text_to_say)
            return jsonify({"status": "success"}), 200
        else:
            return jsonify({"status": "disconnected"}), 500
    except Exception as e:
        logging.error("Failed to send text to NAO: {}".format(e))
        return jsonify({"status": "failed", "error": str(e)}), 500

@app.route('/ask_questions', methods=['POST'])
def ask_question():
    try:
        # Get the JSON data from the request
        data = request.get_json()
        questions = data.get('questions', [])  # Get the questions from the request
        
        # Check connection
        ensure_connected()
        if session.isConnected():
            # Process the questions
            ask_multiple_questions(questions)
            return jsonify({"status": "success"}), 200
        else:
            return jsonify({"status": "disconnected"}), 500
    except Exception as e:
        logging.error("Error in ask_questions: {}".format(e))
        return jsonify({"status": "failed", "error": str(e)}), 500
    
@app.route('/check_connection', methods=['GET'])
def check_connection():
    logging.info("Received request to check NAO connection status.")
    try:
        if session.isConnected():
            return jsonify({"status": "connected"}), 200
        else:
            return jsonify({"status": "disconnected"}), 200
    except Exception as e:
        logging.error("Error checking connection: {}".format(e))
        return jsonify({"status": "failed"}), 500

if __name__ == '__main__':
    app.run(host='172.27.160.1', port=5000)
