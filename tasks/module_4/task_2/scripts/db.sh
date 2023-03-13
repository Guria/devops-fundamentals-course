#!/usr/bin/env bash

# Define variables
DB_FILE="./data/users.db"
BACKUP_DIR="./backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Define functions
# Check if the backups directory exists, create it if not
ensure_db_file_exists() {
  if [ ! -f "$DB_FILE" ]; then
    read -p "Database file does not exist. Create it? (y/n) " confirm_create
    if [[ $confirm_create =~ ^[Yy]$ ]]; then
      mkdir -p "$(dirname "$DB_FILE")"
      touch "$DB_FILE"
      echo "Created database file: $DB_FILE"
    else
      echo "Cannot proceed without database file."
      exit 1
    fi
  fi
  mkdir -p "$BACKUP_DIR"
}

add_user() {
  read -p "Enter username: " username
  while [[ ! $username =~ ^[a-zA-Z]+$ ]]; do
    read -p "Invalid username. Enter username: " username
  done
  read -p "Enter role: " role
  while [[ ! $role =~ ^[a-zA-Z]+$ ]]; do
    read -p "Invalid role. Enter role: " role
  done
  echo "$username, $role" >> "$DB_FILE"
  echo "Added user: $username, $role"
}

backup_db() {
  cp "$DB_FILE" "$BACKUP_DIR/$DATE-users.db.backup"
  echo "Created backup: $BACKUP_DIR/$DATE-users.db.backup"
}

restore_db() {
  LAST_BACKUP=$(ls -t "$BACKUP_DIR"/*.backup 2>/dev/null | head -n1)
  if [ -z "$LAST_BACKUP" ]; then
    echo "No backup file found."
  else
    cp "$LAST_BACKUP" "$DB_FILE"
    echo "Restored from backup: $LAST_BACKUP"
  fi
}

find_user() {
  read -p "Enter username: " username
  found_entries=$(grep -i "^$username," "$DB_FILE")
  if [ -z "$found_entries" ]; then
    echo "User not found"
  else
    echo "$found_entries"
  fi
}

list_users() {
  if [ "$1" == "--inverse" ]; then
    cat --number "$DB_FILE" | tac
  else
    cat --number "$DB_FILE"
  fi
}

# Handle command line arguments
case "$1" in
  add)
    ensure_db_file_exists
    add_user
    ;;
  backup)
    ensure_db_file_exists
    backup_db
    ;;
  restore)
    ensure_db_file_exists
    restore_db
    ;;
  find)
    ensure_db_file_exists
    find_user
    ;;
  list)
    ensure_db_file_exists
    list_users "$2"
    ;;
  help|*)
    echo "Usage: db.sh [COMMAND]"
    echo ""
    echo "Available commands:"
    echo "  add       Adds a new user to the database"
    echo "  backup    Creates a backup of the database"
    echo "  restore   Restores the database from the last backup"
    echo "  find      Finds a user by username"
    echo "  list      Lists all users in the database"
    echo "  help      Prints this help message"
    ;;
esac
