#!/bin/bash

# Script to help generate base64 encoded keystore and print secrets for GitHub Actions

echo "=========================================================="
echo "      Keystore and Secrets Generator for GitHub Actions   "
echo "=========================================================="
echo ""

KEYSTORE_FILE="upload-keystore.jks"

# Ask if they want to create a new keystore
read -p "Do you want to create a NEW keystore? (y/N): " create_new
create_new=${create_new:-N}

if [[ "$create_new" =~ ^[Yy]$ ]]; then
    read -p "Enter keystore password (STORE_PASSWORD): " store_pass
    read -p "Enter key alias (KEY_ALIAS): " key_alias
    read -p "Enter key password (KEY_PASSWORD) [Press Enter if same as keystore password]: " key_pass
    key_pass=${key_pass:-$store_pass}

    echo ""
    echo "Generating new keystore: $KEYSTORE_FILE..."
    keytool -genkey -v -keystore "$KEYSTORE_FILE" -keyalg RSA -keysize 2048 -validity 10000 -alias "$key_alias" -storepass "$store_pass" -keypass "$key_pass" -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown"
    echo "Keystore created successfully!"
    echo ""
else
    read -p "Enter path to your existing keystore file [default: $KEYSTORE_FILE]: " existing_keystore
    KEYSTORE_FILE=${existing_keystore:-$KEYSTORE_FILE}

    if [ ! -f "$KEYSTORE_FILE" ]; then
        echo "Error: Keystore file '$KEYSTORE_FILE' not found."
        exit 1
    fi
fi

# Generate base64
echo "Encoding keystore to Base64..."
if command -v base64 >/dev/null 2>&1; then
    BASE64_STRING=$(base64 "$KEYSTORE_FILE" | tr -d '\n')
elif command -v certutil >/dev/null 2>&1; then
    certutil -encode "$KEYSTORE_FILE" tmp.b64 >/dev/null 2>&1
    BASE64_STRING=$(findstr /v /c:"-----" tmp.b64 | tr -d '\n' | tr -d '\r')
    rm tmp.b64
else
    echo "Error: Neither 'base64' nor 'certutil' found. Cannot encode."
    exit 1
fi

echo ""
echo "=========================================================="
echo "                    GITHUB SECRETS                        "
echo "=========================================================="
echo "Go to: Your Repository > Settings > Security > Secrets and variables > Actions"
echo "Click 'New repository secret' for each of the following:"
echo ""
echo "Secret Name: KEYSTORE_BASE64"
echo "Secret Value (copy everything between the lines):"
echo "----------------------------------------------------------"
echo "$BASE64_STRING"
echo "----------------------------------------------------------"
echo ""
echo "Secret Name: KEY_ALIAS"
echo "Secret Value: (The alias you used when creating the key)"
echo ""
echo "Secret Name: KEY_PASSWORD"
echo "Secret Value: (The password for the key alias)"
echo ""
echo "Secret Name: STORE_PASSWORD"
echo "Secret Value: (The password for the keystore file)"
echo "=========================================================="
echo ""
echo "IMPORTANT: Do NOT commit the '$KEYSTORE_FILE' file to Git!"
echo "If it is currently in your repository, delete it or add it to .gitignore."
