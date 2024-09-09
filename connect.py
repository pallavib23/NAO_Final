# -*- coding: utf-8 -*-
import logging
import qi
from flask import Flask, request, jsonify
import time
import threading
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import speech_recognition as sr


app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Create a global session object
session = qi.Session()
#NAO_IP = '11.255.255.105'
NAO_IP = '11.0.0.126'

def ensure_connected():
    if not session.isConnected():
        logging.info("Attempting to connect to NAO robot...")
        session.connect("tcp://{}:9559".format(NAO_IP))

def start_nao_behaviors():
    """Start the desired NAO behaviors like ALListeningMovement, ALBasicAwareness, etc."""
    try:
        ensure_connected()
        listening_movement = session.service("ALListeningMovement")
        basic_awareness = session.service("ALBasicAwareness")
        autonomous_blinking = session.service("ALAutonomousBlinking")
        speaking_movement = session.service("ALSpeakingMovement")

        # Start the behaviors
        listening_movement.setEnabled(True)
        basic_awareness.startAwareness()
        autonomous_blinking.setEnabled(True)
        speaking_movement.setEnabled(True)
        logging.info("Started ALListeningMovement, ALBasicAwareness, ALAutonomousBlinking, and ALSpeakingMovement.")
    except Exception as e:
        logging.error("Error starting NAO behaviors: {}".format(e))

def nao_wave_naturally(motion):
    """Create a more natural waving motion for NAO."""
    # Move arm up to start wave
    names = ["RShoulderPitch", "RShoulderRoll", "RElbowYaw", "RElbowRoll", "RWristYaw"]
    angles = [0.3, -0.3, 1.2, 0.5, 0.0]  # Adjusted angles for more natural posture
    times = [1.0, 1.0, 1.0, 1.0, 1.0]
    motion.angleInterpolation(names, angles, times, True)

    # Wave by rotating the elbow
    for i in range(3):  # Perform the wave three times
        motion.angleInterpolation(["RElbowRoll"], [1.0], [0.4], True)
        motion.angleInterpolation(["RElbowRoll"], [0.5], [0.4], True)

    # Return to a neutral position
    angles = [1.4, 0.0, 0.5, 1.0, 0.3]
    motion.angleInterpolation(names, angles, times, True)

def nao_wave_and_speak(motion, tts, text):
    """Function to wave and speak simultaneously."""
    # Start threading to perform waving and speaking at the same time
    wave_thread = threading.Thread(target=nao_wave_naturally, args=(motion,))
    speak_thread = threading.Thread(target=tts.say, args=(text,))

    wave_thread.start()
    speak_thread.start()

    # Wait for both threads to complete
    wave_thread.join()
    speak_thread.join()

@app.route('/connect_nao', methods=['GET'])
def connect_nao():
    logging.info("Received request to connect to NAO robot.")
    try:
        ensure_connected()
        if session.isConnected():
            logging.info("Making NAO speak and wave.")
            start_nao_behaviors()

            tts = session.service("ALTextToSpeech")
            motion = session.service("ALMotion")
            tts.setLanguage("French")
            #tts.setLanguage("English")

            # Make NAO wave and speak at the same time
            motion.wakeUp()
            nao_wave_and_speak(motion, tts, "Bonjour, je suis NAO")

            return jsonify({"status": "connected"}), 200
        else:
            return jsonify({"status": "disconnected"}), 500
    except RuntimeError as e:
        logging.error("RuntimeError: {}".format(e))
        return jsonify({"status": "failed"}), 500
    except Exception as e:
        logging.error("Unexpected error: {}".format(e))
        return jsonify({"status": "failed"}), 500

@app.route('/ask_quiz_question', methods=['POST'])
def ask_quiz_question():
    """NAO asks a single quiz question in French."""
    logging.info("Received request to ask a single quiz question.")
    try:
        data = request.get_json()
        question = data.get('question', '')

        ensure_connected()
        if session.isConnected():
            tts = session.service("ALTextToSpeech")
            tts.setLanguage("French")
            #tts.setLanguage("English")

            try:
                question_text = question.encode('utf-8')  # NAO will say only the question

                logging.info("Asking question: {}".format(question_text))
                tts.say(question_text)  # NAO says the question
                time.sleep(4)  # Pause to give NAO time to finish speaking

            except Exception as e:
                logging.error("Failed to ask question: {}. Error: {}".format(question, e))
                return jsonify({"status": "failed", "error": str(e)}), 500

            return jsonify({"status": "success"}), 200
        else:
            return jsonify({"status": "disconnected"}), 500
    except Exception as e:
        logging.error("Failed to ask quiz question: {}".format(e))
        return jsonify({"status": "failed", "error": str(e)}), 500


@app.route('/send_text', methods=['POST'])
def send_text():
    try:
        data = request.get_json()
        text_to_say = data.get('text', '')

        ensure_connected()
        if session.isConnected():
            tts = session.service("ALTextToSpeech")
            tts.setLanguage("French")
            #tts.setLanguage("English")
            tts.say(text_to_say)
            return jsonify({"status": "success"}), 200
        else:
            return jsonify({"status": "disconnected"}), 500
    except Exception as e:
        logging.error("Failed to send text to NAO: {}".format(e))
        return jsonify({"status": "failed", "error": str(e)}), 500

@app.route('/check_connection', methods=['GET'])
def check_connection():
    logging.info("Received request to check NAO connection status.")
    try:
        ensure_connected()
        if session.isConnected():
            return jsonify({"status": "connected"}), 200
        else:
            return jsonify({"status": "disconnected"}), 200
    except Exception as e:
        logging.error("Error checking connection: {}".format(e))
        return jsonify({"status": "failed"}), 500

if __name__ == '__main__':
    app.run(host='172.27.160.1', port=5000)
