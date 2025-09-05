# API Documentation: User Login
<api-endpoint method="POST" path="/api/v1/auth/login">
## Overview
This endpoint handles user authentication and returns a JWT token.

<warning>
This endpoint rate limits requests to 10 per minute per IP address.

</warning>
## Request
<request>
### Headers
```
Content-Type: application/json
Accept: application/json

```

### Body
```json
{
  "email": "user@example.com",
  "password": "secure_password123"
}
```

</request>
## Response
<response status="200">
### Success Response
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 123,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

</response>
<response status="401">
### Authentication Failed
```json
{
  "error": "Invalid credentials"
}
```

</response>
<note>
The JWT token expires after 24 hours. Use the refresh endpoint to get a new token.

</note>
<deprecated version="2.0">
The 'username' field in the request body is deprecated. Use 'email' instead.

</deprecated>
</api-endpoint>
