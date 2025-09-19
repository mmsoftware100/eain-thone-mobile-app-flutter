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

