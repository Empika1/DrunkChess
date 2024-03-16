#!/usr/bin/env python

from http.server import BaseHTTPRequestHandler, HTTPServer

class ConnectionCounterHTTPRequestHandler(BaseHTTPRequestHandler):
    # Initialize a counter for connections
    connection_count = 0

    def do_GET(self):
        # Increment the connection count
        ConnectionCounterHTTPRequestHandler.connection_count += 1

        # Set response headers
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()

        # Prepare the response message
        response_message = f"Connected {ConnectionCounterHTTPRequestHandler.connection_count} times."

        # Send the response to the client
        self.wfile.write(response_message)

def run():
    print("Starting the HTTP server...")
    server_address = ('127.0.0.1', 8080)  # You can change the IP and port as needed
    httpd = HTTPServer(server_address, ConnectionCounterHTTPRequestHandler)
    print(f"HTTP server is running at http://{server_address[0]}:{server_address[1]}")
    httpd.serve_forever()

if __name__ == '__main__':
    run()
