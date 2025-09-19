# Expense Tracker API Documentation

## Overview
RESTful API for the Expense Tracker application built with Express.js, TypeScript, and MongoDB.

**Base URL:** `http://localhost:3000/api/v1`

## Authentication
All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Data Models

### User Model
```typescript
interface User {
  _id?: string;
  name: string;
  email: string;
  password: string; // hashed
  createdAt: Date;
  updatedAt: Date;
}
```

### Transaction Model
```typescript
interface Transaction {
  _id?: string;
  description: string;
  amount: number;
  category: string;
  type: 'income' | 'expense';
  date: Date;
  userId: string; // Reference to User._id
  isSynced: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

## API Endpoints

### Authentication Endpoints

#### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2023-09-06T10:30:00.000Z",
      "updatedAt": "2023-09-06T10:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### POST /auth/login
Authenticate user and get access token.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2023-09-06T10:30:00.000Z",
      "updatedAt": "2023-09-06T10:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### GET /auth/me
Get current user profile (Protected).

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2023-09-06T10:30:00.000Z",
      "updatedAt": "2023-09-06T10:30:00.000Z"
    }
  }
}
```

### Transaction Endpoints

#### GET /transactions
Get all transactions for the authenticated user (Protected).

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `type` (optional): Filter by type ('income' or 'expense')
- `category` (optional): Filter by category
- `startDate` (optional): Filter from date (ISO string)
- `endDate` (optional): Filter to date (ISO string)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "_id": "64f8a1b2c3d4e5f6a7b8c9d1",
        "description": "Grocery shopping",
        "amount": 85.50,
        "category": "Food",
        "type": "expense",
        "date": "2023-09-06T14:30:00.000Z",
        "userId": "64f8a1b2c3d4e5f6a7b8c9d0",
        "isSynced": true,
        "createdAt": "2023-09-06T14:35:00.000Z",
        "updatedAt": "2023-09-06T14:35:00.000Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalItems": 95,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

#### POST /transactions
Create a new transaction (Protected).

**Request Body:**
```json
{
  "description": "Salary payment",
  "amount": 3500.00,
  "category": "Salary",
  "type": "income",
  "date": "2023-09-01T09:00:00.000Z"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Transaction created successfully",
  "data": {
    "transaction": {
      "_id": "64f8a1b2c3d4e5f6a7b8c9d2",
      "description": "Salary payment",
      "amount": 3500.00,
      "category": "Salary",
      "type": "income",
      "date": "2023-09-01T09:00:00.000Z",
      "userId": "64f8a1b2c3d4e5f6a7b8c9d0",
      "isSynced": true,
      "createdAt": "2023-09-06T15:00:00.000Z",
      "updatedAt": "2023-09-06T15:00:00.000Z"
    }
  }
}
```

#### GET /transactions/:id
Get a specific transaction by ID (Protected).

**Response (200):**
```json
{
  "success": true,
  "data": {
    "transaction": {
      "_id": "64f8a1b2c3d4e5f6a7b8c9d2",
      "description": "Salary payment",
      "amount": 3500.00,
      "category": "Salary",
      "type": "income",
      "date": "2023-09-01T09:00:00.000Z",
      "userId": "64f8a1b2c3d4e5f6a7b8c9d0",
      "isSynced": true,
      "createdAt": "2023-09-06T15:00:00.000Z",
      "updatedAt": "2023-09-06T15:00:00.000Z"
    }
  }
}
```

#### PUT /transactions/:id
Update a specific transaction (Protected).

**Request Body:**
```json
{
  "description": "Updated grocery shopping",
  "amount": 92.75,
  "category": "Food",
  "type": "expense",
  "date": "2023-09-06T14:30:00.000Z"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Transaction updated successfully",
  "data": {
    "transaction": {
      "_id": "64f8a1b2c3d4e5f6a7b8c9d1",
      "description": "Updated grocery shopping",
      "amount": 92.75,
      "category": "Food",
      "type": "expense",
      "date": "2023-09-06T14:30:00.000Z",
      "userId": "64f8a1b2c3d4e5f6a7b8c9d0",
      "isSynced": true,
      "createdAt": "2023-09-06T14:35:00.000Z",
      "updatedAt": "2023-09-06T16:20:00.000Z"
    }
  }
}
```

#### DELETE /transactions/:id
Delete a specific transaction (Protected).

**Response (200):**
```json
{
  "success": true,
  "message": "Transaction deleted successfully"
}
```

### Analytics Endpoints

#### GET /analytics/summary
Get financial summary for the authenticated user (Protected).

**Query Parameters:**
- `startDate` (optional): Start date for analysis (ISO string)
- `endDate` (optional): End date for analysis (ISO string)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "summary": {
      "totalIncome": 5500.00,
      "totalExpenses": 2340.75,
      "netBalance": 3159.25,
      "transactionCount": 28,
      "categoryBreakdown": {
        "Food": 850.50,
        "Transportation": 320.25,
        "Entertainment": 180.00,
        "Salary": 5500.00
      },
      "monthlyTrend": [
        {
          "month": "2023-08",
          "income": 3500.00,
          "expenses": 1200.50,
          "net": 2299.50
        },
        {
          "month": "2023-09",
          "income": 2000.00,
          "expenses": 1140.25,
          "net": 859.75
        }
      ]
    }
  }
}
```

### Sync Endpoints

#### POST /sync/transactions
Bulk sync transactions from mobile app (Protected).

**Request Body:**
```json
{
  "transactions": [
    {
      "localId": "temp_1",
      "description": "Coffee",
      "amount": 4.50,
      "category": "Food",
      "type": "expense",
      "date": "2023-09-06T08:30:00.000Z",
      "isSynced": false
    },
    {
      "localId": "temp_2",
      "description": "Bus fare",
      "amount": 2.75,
      "category": "Transportation",
      "type": "expense",
      "date": "2023-09-06T09:15:00.000Z",
      "isSynced": false
    }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Transactions synced successfully",
  "data": {
    "syncedTransactions": [
      {
        "localId": "temp_1",
        "serverId": "64f8a1b2c3d4e5f6a7b8c9d3",
        "status": "created"
      },
      {
        "localId": "temp_2",
        "serverId": "64f8a1b2c3d4e5f6a7b8c9d4",
        "status": "created"
      }
    ]
  }
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address"
    },
    {
      "field": "amount",
      "message": "Amount must be a positive number"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Access denied. No token provided."
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Access denied. Invalid token."
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Transaction not found"
}
```

### 409 Conflict
```json
{
  "success": false,
  "message": "User with this email already exists"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

## Status Codes
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Internal Server Error

## Rate Limiting
- Authentication endpoints: 5 requests per minute per IP
- General API endpoints: 100 requests per minute per user
- Sync endpoints: 10 requests per minute per user

## Notes
- All timestamps are in ISO 8601 format
- Amounts are stored as floating-point numbers with 2 decimal precision
- User passwords are hashed using bcrypt
- JWT tokens expire after 24 hours
- All endpoints return JSON responses
- CORS is enabled for the Flutter app domain