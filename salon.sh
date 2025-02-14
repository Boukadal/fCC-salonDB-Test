#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# display a welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to the Best Salon. How may I serve You?\n"

MAIN_MENU() {
  # display arg with Main menu 
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  
  # display the services
  echo "$($PSQL "SELECT * FROM services ORDER BY service_id")" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "This is not a service available. Please make a right choice, what can I do for you?"
  else
    SVC_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    # if not among services 
    if [[ -z $SVC_SELECTED ]]
    then
      MAIN_MENU "This is not a service. What can I do for you Today?"
    else
      # get service
      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      
      # get phone number
      echo -e "\nWhat's your phone number?"

      read CUSTOMER_PHONE
      # check customer
      CUSTOMER_PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if not found 
      if [[ -z $CUSTOMER_PHONE_RESULT ]]
      then
        # add new customer
        # ask customer name 
        echo -e "\nPhone number not found. What's your name?"
        read CUSTOMER_NAME

        # insert new customer phone and name
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")  
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        echo -e "\nGood to see you again $CUSTOMER_NAME"
      fi

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'") 
      
      # ask service time
      echo -e "\nWhat time would you like your $(echo $SERVICE | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
      read SERVICE_TIME

      # insert row in appointments
      INSERT_APPOINTMENT_ROW=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")   

      # final message to get out 
      echo -e "\nI have put you down for a $(echo $SERVICE | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi

  fi
}

MAIN_MENU
