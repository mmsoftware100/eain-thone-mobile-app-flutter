# Family Expense Tracker

A expense tracker app for family.

## Feature

- [ ] Simple data entry for expense and income by each family member
- [ ] Easily see current month expense total, income total.
- [ ] Offline first data entry
- [ ] Sync across family when connection restored.

## UI

- [ ] Simple Data entry for expense and income. Just enter description and amount , app will categorize type (eg. expense or income)
- [ ] store items in local storage like sqlite
- [ ] if user want to sync across devices / family , create account using email
- [ ] Sync strategy, data entry always store on local storage and then sync in background, sync with backend api whenever internet connectivity is restored. When we get new items from cloud, store in local storage also.

## Screens

- [ ] Home page , show list of transaction (both income / expense ) , add new transaction button (FAB)
- [ ] Transaction Creat / Edit Page , show form (description, amount, type (expense / income), date) , type default to expense, date as current date , on submit store / update in sqlite 
- [ ] Transaction Detail Page , show transaction detail (description, amount, type (expense / income), date) , edit and delete option
- [ ] Settings Page , show user profile (name, email) , logout option
- [ ] Login Page , show login form (email, password) , on submit call login api , if success redirect to home page , else show error message
- [ ] Register Page , show register form (name, email, password) , on submit call register api , if success redirect to login page , else show error message
- [ ] Sync Indicator , show sync indicator when syncing data in background , the whole app
- [ ] Error Handling , show error message when api call failed , network error , etc

## API

- [ ] Register
- [ ] Login
- [ ] Sync
- [ ] Transaction CRUD


## State Management, HTTP and flutter related cases

- [ ] Use provider as state management
- [ ] sqlite for local storage
- [ ] DIO for HTTP
- [ ] Clean and Modernized UI with smooth UI/UX



## Screen Flow


When start app
- [ ] new user should show Login Page 
- [ ] if user is alredy decide to use offline first , show direct Home Page

Transaction Form Screen

- [ ] first show big text area input for description
- [ ] then show number input for amount
- [ ] then show side by side mode / switch or two button  for type (expense / income) , default as expense selected
- [ ] then show date picker for date , default today
- [ ] then show submit button

The main point is user just need to focus on description and amount , rest will be handled by app. 
UI Hierarcy should focus on big description input 


User Registration / Login Flow from Home Page
- [ ] if user click on home page's cloud icon to sync, check user is already signed in, sync data if user is signed in, else show login screen
- [ ] if user click on login button in login screen, show login form (email, password) , on submit call login api , if success redirect to home page , else show error message
- [ ] if user click on register button in login screen, show register form (name, email, password) , on submit call register api , if success redirect to login page , else show error message
- [ ] then sync local records with server.


## Features Imporvements

- [ ] Home Scren's see all transaction button does not navigate to transaction list screen,
- [ ] Transaction list page show list of transation , can be filter by month, date range , income / expense type  , etc with pagination of local storage , 
- [ ] Transaction Detail Screen's should able to swipe left / right to see previous / next transaction on the whold card / page 
- [ ] add category management ? user can add / edit / delete category , and use in transaction form, offline first, sync also.

