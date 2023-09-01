from flask import Flask, request, jsonify
from flask_cors import CORS, cross_origin
import psycopg2.pool
from datetime import datetime
import smtplib
import ssl
from flask_mail import Mail, Message
import random
import re

app = Flask(__name__)
CORS(app)

DB_HOST = ''
DB_PORT = ''
DB_USER = ''
DB_PASSWORD = ''
DB_NAME = ''

# Define a dictionary to store generated OTPs and their associated email
otp_data = {}

connection_pool = psycopg2.pool.SimpleConnectionPool(
    1, 
    10,  
    host=DB_HOST,
    port=DB_PORT,
    user=DB_USER,
    password=DB_PASSWORD,
    database=DB_NAME
)
# Function to check if the email format is valid
def is_valid_email(email):
    email_regex = re.compile(r"[^@]+@[^@]+\.[^@]+")
    return bool(email_regex.match(email))
def get_connection():
    try:
        return connection_pool.getconn()
    except Exception as e:
        print('Error getting connection:', e)
        return None

# Define a function to return a connection to the pool
def return_connection(conn):
    try:
        connection_pool.putconn(conn)
    except Exception as e:
        print('Error returning connection:', e)

# Define a function to create the doctors table if it does not exist
def create_table():
    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return False

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to create the table
        create_table_query = '''
            CREATE TABLE IF NOT EXISTS doctors (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                phonenumber VARCHAR(10) NOT NULL, -- Changed from INTEGER to VARCHAR(10)
                email VARCHAR(100) NOT NULL,
                hospitalName VARCHAR(200) NOT NULL,
                city VARCHAR(50) NOT NULL,
                admittedBy VARCHAR(50) NOT NULL,
                date_joined DATE NOT NULL,
                date_last_updated DATE NOT NULL
            );
        '''

        # Execute the query and commit the changes
        cursor.execute(create_table_query)
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return True if successful
        return True

    except Exception as e:
        # Print the error and return False if unsuccessful
        print('Error creating table:', e)
        return False

# Define a function to save data to the database
def save_data_to_database(data):
    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return False

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to insert data into the table
        query = "INSERT INTO doctors (name, phonenumber, email, hospitalName, city, admittedBy, date_joined, date_last_updated) VALUES (%s, %s, %s, %s, %s, %s, %s, %s);"

        # Determine the value for admittedBy
        admitted_by = data.get('admittedBy', 'Admin')

        # Define the values to insert into the query placeholders
        values = (
            data.get('name'),
            data.get('phonenumber'),
            data.get('email'),
            data.get('hospitalName'),
            data.get('city'),
            admitted_by,
            datetime.now().date(),  # Current date for date_joined
            datetime.now().date()   # Current date for date_last_updated
        )

        # Execute the query and commit the changes
        cursor.execute(query, values)
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return True if successful
        return True

    except Exception as e:
        # Print the error and return False if unsuccessful
        print('Error saving data:', e)
        return False

# Modify the get_doctors_data function to print the fetched data
# Modify the get_doctors_data function to print the lengths of the fetched rows
def get_doctors_data():
    try:
         # Get a connection from the pool
         connection = get_connection()
         if connection is None:
             return []

         # Create a cursor object to execute queries
         cursor = connection.cursor()

         # Define the SQL query to select data from the table
         query = "SELECT id, name, phonenumber, email, hospitalName, city, admittedBy, date_joined, date_last_updated FROM doctors;"

         # Execute the query and fetch all the results
         cursor.execute(query)
         data = cursor.fetchall()

         # Print the lengths of the fetched rows for debugging
         for row in data:
             print(f"Length of Row: {len(row)}")

         # Close the cursor and return the connection to the pool
         cursor.close()
         return_connection(connection)

         # Initialize an empty list to store doctors data as dictionaries 
         doctors_list = []

         # Loop through each row of data and create a dictionary for each doctor
         for row in data:
             doctor = {
                 'id': row[0],
                 'name': row[1],
                 'phonenumber': str(row[2]),  
                 'email': row[3],
                 'hospitalName': row[4],
                 'city': row[5],
                 'admittedBy': row[6],
                 'date_joined': row[7].strftime('%Y-%m-%d'), 
                 'date_last_updated': row[8].strftime('%Y-%m-%d')  
             }

             # Append the doctor dictionary to the list
             doctors_list.append(doctor)

         # Return the list of doctors data
         return doctors_list

    except Exception as e:
        # Print the error and return an empty list if unsuccessful
        print('Error fetching doctor data:', e)
        return []
    
def create_admins_table():
    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return False

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to create the table
        create_table_query = '''
            CREATE TABLE IF NOT EXISTS admins (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) NOT NULL,
                phoneNumber VARCHAR(10) NOT NULL,
                date_joined DATE NOT NULL,
                date_last_updated DATE NOT NULL
            );
        '''

        # Execute the query and commit the changes
        cursor.execute(create_table_query)
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return True if successful
        return True

    except Exception as e:
        # Print the error and return False if unsuccessful
        print('Error creating admins table:', e)
        return False

# Define a function to save admin data to the database
def save_admin_data_to_database(data):
    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return False

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to insert data into the admins table
        query = "INSERT INTO admins (name, email, phoneNumber, date_joined, date_last_updated) VALUES (%s, %s, %s, %s, %s);"

        # Define the values to insert into the query placeholders
        values = (
            data.get('name'),
            data.get('email'),
            data.get('phoneNumber'),
            datetime.now().date(),
            datetime.now().date()
        )

        # Execute the query and commit the changes
        cursor.execute(query, values)
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return True if successful
        return True

    except Exception as e:
        # Print the error and return False if unsuccessful
        print('Error saving admin data:', e)
        return False

# Define a function to get admin data from the database
def get_admins_data():
    try:
         # Get a connection from the pool
         connection = get_connection()
         if connection is None:
             return []

         # Create a cursor object to execute queries
         cursor = connection.cursor()

         # Define the SQL query to select data from the admins table
         query = "SELECT id, name, email, phoneNumber, date_joined, date_last_updated FROM admins;"

         # Execute the query and fetch all the results
         cursor.execute(query)
         data = cursor.fetchall()

         # Close the cursor and return the connection to the pool
         cursor.close()
         return_connection(connection)

         # Initialize an empty list to store admins data as dictionaries 
         admins_list = []

         # Loop through each row of data and create a dictionary for each admin
         for row in data:
             admin = {
                 'id': row[0],
                 'name': row[1],
                 'email': row[2],
                 'phoneNumber': row[3],
                 'date_joined': row[4].strftime('%Y-%m-%d'), 
                 'date_last_updated': row[5].strftime('%Y-%m-%d')  
             }

             # Append the admin dictionary to the list
             admins_list.append(admin)

         # Return the list of admins data
         return admins_list

    except Exception as e:
        # Print the error and return an empty list if unsuccessful
        print('Error fetching admin data:', e)
        return []
    


# Function to check if the email exists in the admin database
def email_exists_in_admin_database(email):
    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return False

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to check if the email exists in the admins table
        query = "SELECT COUNT(*) FROM admins WHERE email = %s;"

        # Execute the query with the email as a parameter
        cursor.execute(query, (email,))

        # Fetch the result
        result = cursor.fetchone()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Check if the email exists (if the count is greater than 0)
        return result[0] > 0

    except Exception as e:
        # Print the error and return False if an error occurs
        print('Error checking email in admin database:', e)
        return False
# Function to send OTP email
def send_otp_email(email, otp):
    try:
        # SMTP configuration for Gmail
        smtp_server = ''
        smtp_port = 
        smtp_username = ''  # Replace with your Gmail address
        smtp_password = ''  # Replace with your Gmail password
        app.config['MAIL_USE_TLS'] = True
        app.config['MAIL_USE_SSL'] = False
        # Compose the email message
        subject = 'OTP Verification'
        message = f'Your OTP is: {otp}'
        sender_email = smtp_username
        receiver_email = email

        # Create the email message
        msg = f"From: {sender_email}\nTo: {receiver_email}\nSubject: {subject}\n\n{message}"

        # Create a secure SSL context
        context = ssl.create_default_context()

        # Create a SMTP connection
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls(context=context)
            server.login(smtp_username, smtp_password)

            # Send the email
            server.sendmail(sender_email, receiver_email, msg)

    except Exception as e:
        print('Error sending OTP email:', e)

# Define a route to handle POST requests for registering admins
@app.route('/register_admin', methods=['POST'])
@cross_origin()
def register_admin():
    # Get the JSON data from the request body
    data = request.json

    # Get the email from the JSON data
    email = data.get('email')

    # Check if the email already exists in the admins database
    if email_exists_in_admin_database(email):
        # Generate a new 6-digit OTP
        new_otp = generate_otp()

        # Send the new OTP to the registered email
        send_otp_email(email, new_otp)
        
        # Store the OTP and its associated email in the dictionary
        otp_data[email] = new_otp

        # Send the new OTP to the registered email
        send_otp_email(email, new_otp)

        response = {
            'response': 'An OTP has been sent to your email for verification. If not recived click Send OTP again'
        }
    else:
        response = {
            'response': 'Error: Email is not registered as an admin. You cannot use this app'
        }

    # Return the response dictionary as a JSON response
    return jsonify(response)
# Function to get admin data from the database based on email
def get_admin_data_by_email(email):
    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return None

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to select admin data from the admins table
        query = "SELECT name, phoneNumber FROM admins WHERE email = %s;"

        # Execute the query with the email as a parameter
        cursor.execute(query, (email,))

        # Fetch the result
        result = cursor.fetchone()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return the admin data as a dictionary
        if result:
            admin_data = {
                'name': result[0],
                'phone': result[1],
                'email': email,
            }
            return admin_data
        else:
            return None

    except Exception as e:
        # Print the error and return None if an error occurs
        print('Error fetching admin data:', e)
        return None
# Helper function to generate a 6-digit OTP
def generate_otp():
    return str(random.randint(100000, 999999))


# Define a route to handle GET requests for doctors data
@app.route('/doctors', methods=['GET'])
@cross_origin()
def get_doctors():
    # Call the function to get doctors data from the database
    doctors_list = get_doctors_data()

    # Return the list as a JSON response
    return jsonify(doctors_list)

# Define a route to handle POST requests for processing data
@app.route('/process_data', methods=['POST'])
@cross_origin()
def process_data():
    # Get the JSON data from the request body
    data = request.json

    # Get the data dictionary from the JSON data
    received_data = data.get('data')

    # Call the function to create the table if it does not exist
    create_table()

    # Call the function to save the data to the database
    success = save_data_to_database(received_data)

    # If successful, create a response dictionary with a success message
    if success:
        response = {
            'name': received_data.get('name'),
            'response': 'Data has been saved successfully.'
        }
    
    # If unsuccessful, create a response dictionary with an error message
    else:
        response = {
            'name': received_data.get('name'),
            'response': f"Error: Data could not be saved."
        }

    # Return the response dictionary as a JSON response
    return jsonify(response)

# Define a route to handle DELETE requests for removing doctors by email, phone, and id
@app.route('/remove_doctor', methods=['DELETE'])
@cross_origin()
def remove_doctor():
    # Get the JSON data from the request body
    data = request.json

    # Get the id, email, and phone number from the JSON data
    id = data.get('id')
    email = data.get('email')
    phonenumber = data.get('phonenumber')

    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return jsonify({'response': 'Error: Could not remove doctor.'})

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to delete the doctor by id, email, and phone
        delete_query = "DELETE FROM doctors WHERE id = %s OR email = %s OR phonenumber = %s;"

        # Execute the query with id, email, and phone as parameters
        cursor.execute(delete_query, (id, email, phonenumber))

        # Commit the changes
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Create a response dictionary with a success message
        response = {'response': 'Doctor has been removed successfully.'}

        # Return the response dictionary as a JSON response
        return jsonify(response)

    except Exception as e:
        # Print the error and return an error message as a JSON response if an error occurs
        print('Error removing doctor:', e)
        return jsonify({'response': 'Error: Could not remove doctor.'})
@app.route('/edit_doctor', methods=['PUT'])
@cross_origin()
def edit_doctor():
    # Get the JSON data from the request body
    data = request.json

    # Get the doctor information from the JSON data
    doctor_info = {
        'name': data.get('name'),
        'phonenumber': data.get('phonenumber'),
        'email': data.get('email'),
        'hospitalName': data.get('hospitalName'),
        'city': data.get('city'),
    }

    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return jsonify({'response': 'Error: Unable to connect to the database.'}), 500

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to update the doctor information
        query = "UPDATE doctors SET name = %s, phonenumber = %s, email = %s, hospitalName = %s, city = %s, date_last_updated = %s WHERE id = %s;"

        # Get the doctor ID from the JSON data
        doctor_id = data.get('id')

        # Get the current date for date_last_updated
        date_last_updated = datetime.now().date()

        # Execute the query with the doctor information and commit the changes
        cursor.execute(query, (doctor_info['name'], doctor_info['phonenumber'], doctor_info['email'], doctor_info['hospitalName'], doctor_info['city'], date_last_updated, doctor_id))
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return a success response
        response = {'response': 'Doctor information updated successfully.'}
        return jsonify(response)

    except Exception as e:
        # Print the error and return an error response
        print('Error updating doctor information:', e)
        return jsonify({'response': 'Error: Unable to update the doctor information.'}), 500

@app.route('/admins', methods=['GET'])
@cross_origin()
def get_admins():
    # Call the function to get admins data from the database
    admins_list = get_admins_data()

    # Return the list as a JSON response
    return jsonify(admins_list)

# Define a route to handle POST requests for adding admin data
@app.route('/add_admin', methods=['POST'])
@cross_origin()
def add_admin():
    # Get the JSON data from the request body
    data = request.json

    # Call the function to create the admins table if it does not exist
    create_admins_table()

    # Call the function to save the admin data to the database
    success = save_admin_data_to_database(data)

    # If successful, create a response dictionary with a success message
    if success:
        response = {
            'name': data.get('name'),
            'response': 'Admin data has been saved successfully.'
        }

    # If unsuccessful, create a response dictionary with an error message
    else:
        response = {
            'name': data.get('name'),
            'response': 'Error: Admin data could not be saved.'
        }

    # Return the response dictionary as a JSON response
    return jsonify(response)

# Define a route to handle DELETE requests for removing admins by id, email, and phone number
@app.route('/remove_admin', methods=['DELETE'])
@cross_origin()
def remove_admin():
    # Get the JSON data from the request body
    data = request.json

    # Get the id, email, and phone number from the JSON data
    id = data.get('id')
    email = data.get('email')
    phoneNumber = data.get('phoneNumber')

    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return jsonify({'response': 'Error: Unable to connect to the database.'}), 500

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to delete the admin by id, email, and phone number
        query = "DELETE FROM admins WHERE id = %s AND email = %s AND phoneNumber = %s;"

        # Execute the query with the id, email, and phone number and commit the changes
        cursor.execute(query, (id, email, phoneNumber))
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return a success response
        return jsonify({'response': 'Admin removed successfully.'})

    except Exception as e:
        # Print the error and return an error response
        print('Error removing admin:', e)
        return jsonify({'response': 'Error: Unable to remove the admin.'}),

@app.route('/edit_admin', methods=['PUT'])
@cross_origin()
def edit_admin():
    # Get the JSON data from the request body
    data = request.json

    # Get the admin information from the JSON data
    admin_info = {
        'id': data.get('id'),
        'name': data.get('name'),
        'email': data.get('email'),
        'phoneNumber': data.get('phoneNumber'),
    }

    try:
        # Get a connection from the pool
        connection = get_connection()
        if connection is None:
            return jsonify({'response': 'Error: Unable to connect to the database.'}), 500

        # Create a cursor object to execute queries
        cursor = connection.cursor()

        # Define the SQL query to update the admin information
        query = "UPDATE admins SET name = %s, email = %s, phoneNumber = %s, date_last_updated = %s WHERE id = %s;"

        # Get the current date for date_last_updated
        date_last_updated = datetime.now().date() 

        # Execute the query with the admin information and commit the changes
        cursor.execute(query, (admin_info['name'], admin_info['email'], admin_info['phoneNumber'], date_last_updated, admin_info['id']))
        connection.commit()

        # Close the cursor and return the connection to the pool
        cursor.close()
        return_connection(connection)

        # Return a success response
        response = {'response': 'Admin information updated successfully.'}
        return jsonify(response)

    except Exception as e:
        # Print the error and return an error response
        print('Error updating admin information:', e)
        return jsonify({'response': 'Error: Unable to update the admin information.'}), 500
# Define a route to handle POST requests for verifying OTP
@app.route('/verify_otp', methods=['POST'])
@cross_origin()
def verify_otp():
    # Get the JSON data from the request body
    data = request.json

    # Get the email and OTP from the JSON data
    email = data.get('email')
    user_otp = data.get('otp')

    # Check if the email exists in the otp_data dictionary
    if email in otp_data:
        # Get the stored OTP associated with the email
        stored_otp = otp_data[email]

        # Check if the user-provided OTP matches the stored OTP
        if user_otp == stored_otp:
            # OTP verification successful, remove the OTP from the dictionary
            del otp_data[email]

            # Get the admin's name, phone number, and email from the database
            admin_data = get_admin_data_by_email(email)

            if admin_data:
                name = admin_data['name']
                phone = admin_data['phone']

                response = {
                    'response': 'OTP verification successful.',
                    'name': name,
                    'phone': phone,
                    'email': email,
                }
            else:
                response = {'response': 'Error: Admin data not found.'}
        else:
            response = {'response': 'Invalid OTP. Please try again.'}
    else:
        response = {'response': 'Invalid email or OTP. Please try again.'}

    return jsonify(response)  # Return the response as JSON


if __name__ == '__main__':
    app.run(debug=True)