# WhatsApp Cloud API Setup Guide

This guide will help you set up WhatsApp Cloud API for OTP authentication in your Flutter application.

## Prerequisites

- A Meta Business Account
- A WhatsApp Business Account
- A verified phone number for your business
- Flutter development environment

## Step 1: Create Meta Business Account

1. Go to [Meta for Developers](https://developers.facebook.com/)
2. Create a developer account if you don't have one
3. Create a new app and select "Business" as the app type
4. Add WhatsApp product to your app

## Step 2: Set Up WhatsApp Business API

1. In your Meta app dashboard, navigate to WhatsApp > Getting Started
2. **IMPORTANT**: Register your account with Cloud API first:
   - Go to WhatsApp > API Setup
   - Click "Register Account" or "Enable Cloud API"
   - Complete the registration process
3. Add a phone number to your WhatsApp Business Account
4. Verify your business phone number
5. Note down the following credentials:
   - **Access Token**: Your temporary access token
   - **Phone Number ID**: The ID of your business phone number
   - **WhatsApp Business Account ID**: Your business account ID

## Step 3: Configure Environment Variables

Create or update your environment configuration with the WhatsApp credentials:

```dart
// In your whatsapp_cloud_service.dart or environment config
class WhatsAppConfig {
  static const String accessToken = 'YOUR_ACCESS_TOKEN_HERE';
  static const String phoneNumberId = 'YOUR_PHONE_NUMBER_ID_HERE';
  static const String businessAccountId = 'YOUR_BUSINESS_ACCOUNT_ID_HERE';
  static const String apiVersion = 'v18.0';
}
```

### Example Configuration

Based on your provided credentials:

```dart
class WhatsAppConfig {
  static const String accessToken = 'EAAPyeNHVBWoBPTP7CPRZAbzTp03LIfhiZB1ae2OZAGREyRc1MFZCnF6sZBuRL7x768llQ8kZBDu0NZAqBiZCt1TTtXHbYGZCcBHplyiQcQ9knpKSojaQHET0895JtyQfmtOBjgdzb0EBE2tdHG15NtvY5ydXZCpO0LZBskZCXQvnZB9UiO69MhmjpNTZBZC6CPHl4rtUfXZB9gZDZD';
  static const String phoneNumberId = '773616775832523';
  static const String businessAccountId = '1336565927809632';
  static const String apiVersion = 'v18.0';
}
```

## Step 4: Update WhatsApp Cloud Service

Ensure your `whatsapp_cloud_service.dart` is configured with the correct credentials:

```dart
class WhatsAppCloudService {
  static const String _accessToken = WhatsAppConfig.accessToken;
  static const String _phoneNumberId = WhatsAppConfig.phoneNumberId;
  static const String _businessAccountId = WhatsAppConfig.businessAccountId;
  static const String _apiVersion = WhatsAppConfig.apiVersion;
  
  // ... rest of the implementation
}
```

## Step 5: Test WhatsApp Integration

1. Run your Flutter application
2. Navigate to the phone login screen
3. Enter a valid phone number (with country code)
4. Click "Send OTP via WhatsApp"
5. Check your WhatsApp for the OTP message
6. Enter the received OTP and verify

## Step 6: Production Setup

### Generate Permanent Access Token

1. In your Meta app dashboard, go to WhatsApp > Configuration
2. Generate a permanent access token
3. Replace the temporary token in your configuration

### Webhook Configuration (Optional)

1. Set up a webhook endpoint to receive delivery status
2. Configure the webhook URL in your Meta app dashboard
3. Verify the webhook with the provided verification token

## API Endpoints Used

### Send Message
```
POST https://graph.facebook.com/v18.0/{phone-number-id}/messages
```

### Get Business Profile
```
GET https://graph.facebook.com/v18.0/{whatsapp-business-account-id}
```

## Message Template

The service uses the following OTP message template:

```
Your verification code is: {otp_code}

This code will expire in 5 minutes. Do not share this code with anyone.
```

## Security Best Practices

1. **Never commit access tokens** to version control
2. **Use environment variables** for sensitive credentials
3. **Implement rate limiting** to prevent abuse
4. **Validate phone numbers** before sending OTPs
5. **Set OTP expiration** (default: 5 minutes)
6. **Log all API calls** for debugging and monitoring

## Troubleshooting

### Common Issues

#### Error 400: Bad Request
- Check if your access token is valid and not expired
- Verify the phone number format (must include country code)
- Ensure the recipient's phone number has WhatsApp installed

#### Error 401: Unauthorized
- Your access token may be invalid or expired
- Check if your app has the necessary permissions

#### Error 403: Forbidden
- Your WhatsApp Business Account may not be approved
- Check if you've exceeded rate limits

#### Error 404: Not Found
- Verify your Phone Number ID is correct
- Check if the phone number is registered with WhatsApp Business

#### Error 133010: Account Not Registered
- **This is the most common setup issue**
- Your WhatsApp Business Account is not registered with Cloud API
- **Solution**: Go to Meta Developer Console > WhatsApp > API Setup
- Click "Register Account" or "Enable Cloud API"
- Complete the registration process before using the API
- Wait 5-10 minutes after registration before testing

#### Account Disabled Due to Policy Violations
If your WhatsApp Business account has been disabled, you'll see errors like "Account disabled" or "This account has been disabled because it does not comply with WhatsApp Business's Commerce Policy."

**Common Reasons for Account Suspension:**
- Violation of WhatsApp Business Terms of Service
- Breach of Terms of Acceptable Use
- Sending spam or unsolicited messages
- Using inappropriate business names or display names
- Violating commerce policies

**Solutions:**
1. **Request a Review:**
   - Go to Meta Business Manager
   - Navigate to WhatsApp Manager
   - Find your disabled account
   - Click "Request Review" if available
   - Provide detailed explanation of your business use case
   - Wait for Meta's response (can take several days)

2. **Create a New Business Account:**
   - If review is denied or not available, create a new Meta Business Account
   - Use a different business name and phone number
   - Ensure compliance with all WhatsApp policies
   - Use appropriate business category and description

3. **Use Alternative Solutions:**
   - Consider using Twilio WhatsApp API as an alternative
   - Use SMS-based OTP as a fallback
   - Implement email-based verification

#### Display Name Violations
Error: "Verified name is invalid" or "Your display name violates WhatsApp guidelines."

**Solutions:**
1. **Update Display Name:**
   - Go to Meta Business Manager → WhatsApp Manager
   - Select your WhatsApp Business Account
   - Click on "Settings" → "Business Info"
   - Update the display name to comply with guidelines:
     - Use your actual business name
     - Avoid special characters, emojis, or symbols
     - Don't use generic terms like "Test" or "Demo"
     - Ensure it matches your business registration

2. **Display Name Guidelines:**
   - Must represent your actual business
   - Cannot be misleading or impersonate others
   - Should be professional and appropriate
   - Must comply with local regulations
   - Cannot contain promotional language

#### Test Number Limitations
Test numbers (like 15551807601) have significant limitations and may not work for production use.

**Solutions:**
1. **Use Real Business Phone Number:**
   - Register an actual business phone number
   - Ensure you have access to receive SMS/calls for verification
   - Use a number that represents your business

2. **For Development/Testing:**
   - Use WhatsApp Business API Test Numbers (if available)
   - Add test phone numbers to your app's test users
   - Use sandbox environment for initial testing

#### Account Recovery Steps
1. **Immediate Actions:**
   - Stop all message sending activities
   - Review WhatsApp Business Policies
   - Document your legitimate business use case

2. **Appeal Process:**
   - Submit appeal through Meta Business Support
   - Provide business registration documents
   - Explain your OTP use case clearly
   - Show compliance measures you've implemented

3. **Prevention for New Accounts:**
   - Read and understand WhatsApp Business Policies
   - Implement proper opt-in mechanisms
   - Use approved message templates
   - Monitor sending patterns and user feedback
   - Implement proper rate limiting

#### Alternative Solutions
If WhatsApp Cloud API is not available:

1. **Twilio WhatsApp API:**
   ```dart
   // Already implemented in twilio_sms_service.dart
   // Can be extended for WhatsApp
   ```

2. **SMS Fallback:**
   ```dart
   // Use existing Twilio SMS service
   await TwilioSMSService.sendOTP(phoneNumber, otp);
   ```

3. **Email Verification:**
   ```dart
   // Implement email-based OTP as backup
   await EmailService.sendOTP(email, otp);
   ```

#### Message Not Delivered
- Recipient may have blocked your business number
- Check if the recipient's phone number is valid
- Verify your message template compliance

### Rate Limits

- **Messaging**: 1000 messages per day (can be increased)
- **API Calls**: 4000 calls per hour per app
- **Concurrent Requests**: 100 requests per second

### Getting Help

1. Check [WhatsApp Business API Documentation](https://developers.facebook.com/docs/whatsapp)
2. Review [Meta Business Help Center](https://business.facebook.com/help)
3. Contact Meta Business Support for account-specific issues

## Additional Resources

- [WhatsApp Business API Reference](https://developers.facebook.com/docs/whatsapp/cloud-api/reference)
- [Message Templates Guide](https://developers.facebook.com/docs/whatsapp/message-templates)
- [Webhook Setup Guide](https://developers.facebook.com/docs/whatsapp/cloud-api/webhooks)
- [Rate Limits Documentation](https://developers.facebook.com/docs/graph-api/overview/rate-limiting)

---

**Note**: This integration uses WhatsApp Cloud API which is free for the first 1000 conversations per month. After that, standard messaging rates apply.