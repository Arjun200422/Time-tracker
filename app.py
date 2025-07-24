from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
import psycopg2.extras

app = Flask(__name__)
CORS(app)

# Replace with your Neon connection string
conn_str = 'postgresql://neondb_owner:npg_0Yaj2nIZcgbA@ep-still-flower-advp9064-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

def get_db():
    return psycopg2.connect(conn_str, cursor_factory=psycopg2.extras.RealDictCursor)

@app.route('/projects', methods=['GET'])
def get_projects():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM projects")
    projects = cur.fetchall()
    db.close()
    return jsonify(projects)

@app.route('/projects', methods=['POST'])
def add_project():
    data = request.json
    db = get_db()
    cur = db.cursor()
    cur.execute("INSERT INTO projects (user_id, name) VALUES (%s, %s) RETURNING id", (data['user_id'], data['name']))
    project_id = cur.fetchone()['id']
    db.commit()
    db.close()
    return jsonify({"id": project_id, "message": "Project added"}), 201

if __name__ == '__main__':
    app.run(debug=True)
