from flask import Flask, request, jsonify
from flask_cors import CORS
import sys
import io

app = Flask(__name__)
CORS(app)  # Allow CORS for all domains, for demo purposes

@app.route('/execute', methods=['POST'])
def execute_code():
    try:
        # Get the user code from the request
        data = request.get_json()
        user_code = data.get('user_code', '')
        
        # Redirect stdout to capture print statements
        old_stdout = sys.stdout
        redirected_output = io.StringIO()
        sys.stdout = redirected_output

        # Execute the user's code
        exec(user_code)

        # Restore stdout and get output
        sys.stdout = old_stdout
        output = redirected_output.getvalue()

        return jsonify({"output": output}), 200
    
    except Exception as e:
        # Return error details if execution fails
        sys.stdout = old_stdout
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)

