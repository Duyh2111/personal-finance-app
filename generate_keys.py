#!/usr/bin/env python3
"""
Generate secure keys for production deployment
"""
import secrets

def generate_key(length=32):
    """Generate a secure random key"""
    return secrets.token_urlsafe(length)

if __name__ == "__main__":
    print("🔑 Generated Secure Keys for Production:")
    print("="*50)
    print(f"SECRET_KEY={generate_key(32)}")
    print(f"JWT_SECRET_KEY={generate_key(32)}")
    print("="*50)
    print("Copy these keys to your Render environment variables!")
    print("⚠️  Keep these keys secure and never share them publicly!")