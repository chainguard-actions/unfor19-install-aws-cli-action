#!/usr/bin/env python3
"""Simple HTTP/1.1 server for testing. Serves files from the current directory."""
import http.server
import socketserver
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 18080


class HTTP11Handler(http.server.SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, format, *args):
        pass  # suppress logging


class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True


with ReusableTCPServer(("", PORT), HTTP11Handler) as httpd:
    httpd.serve_forever()
