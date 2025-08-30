# Twilio SMS Integration Setup Guide

This guide will help you set up Twilio SMS integration for the RentME Koraput app.

## Prerequisites

1. A Twilio account (sign up at https://www.twilio.com/)
2. Flutter development environment
3. The RentME Koraput app codebase

## Step 1: Create Twilio Account

1. Go to https://www.twilio.com/ and sign up for a free account
2. Verify your email and phone number
3. Complete the account setup process

## Step 2: Get Twilio Credentials

1. Log in to your Twilio Console at https://console.twilio.com/
2. From the dashboard, note down:
   - **Account SID** (starts with "AC")
   - **Auth Token** (click the eye icon to reveal)

## Step 3: Get a Twilio Phone Number

1. In the Twilio Console, go to **Phone Numbers** > **Manage** > **Buy a number**
2. Choose your country and select a phone number
3. Purchase the number (free trial accounts get one free number)
4. Note down the phone number in E.164 format (e.g., +1234567890)

## Step 4: Verify Phone Numbers (Trial Accounts Only)

**IMPORTANT**: If you're using a Twilio trial account, you must verify any phone numbers you want to send SMS to before testing.

### How to Verify Phone Numbers:

1. Go to your Twilio Console: https://console.twilio.com/
2. Navigate to **Phone Numbers** > **Manage** > **Verified Caller IDs**
3. Click **Add a new number**
4. Enter the phone number you want to test with (including country code)
5. Choose **SMS** as the verification method
6. Enter the verification code you receive
7. The number will now be verified and can receive SMS from your trial account

### Trial Account Error (Error 21608):
If you see an error like "The number +91XXXXXXXXX is unverified. Trial accounts cannot send messages to unverified numbers", you need to:
- Verify the phone number as described above, OR
- Upgrade to a paid Twilio account to send SMS to any number

## Step 5: Configure Environment Variables

### Option A: Using --dart-define (Recommended)

Run your Flutter app with the following command:

```bash
flutter run --dart-define=TWILIO_ACCOUNT_SID=your_account_sid_here --dart-define=TWILIO_AUTH_TOKEN=your_auth_token_here --dart-define=TWILIO_PHONE_NUMBER=+1234567890
```

### Option B: Using .env file (Development)

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` file with your credentials:
   ```
   TWILIO_ACCOUNT_SID=your_account_sid_here
   TWILIO_AUTH_TOKEN=your_auth_token_here
   TWILIO_PHONE_NUMBER=+1234567890
   ```

3. Add `.env` to your `.gitignore` file to avoid committing secrets

## Step 6: Test SMS Functionality

1. Run the app:
   ```bash
   flutter run -d chrome --dart-define=TWILIO_ACCOUNT_SID=your_sid --dart-define=TWILIO_AUTH_TOKEN=your_token --dart-define=TWILIO_PHONE_NUMBER=+1234567890
   ```

2. Navigate to SMS Login screen
3. Enter a valid phone number
4. Click "Send OTP"
5. Check your phone for the SMS

## Troubleshooting

### Common Issues

1. **"Error 21608: The number is unverified" (Most Common)**
   - **Solution**: Verify the phone number in Twilio Console (see Step 4 above)
   - **Alternative**: Upgrade to a paid Twilio account
   - This error occurs when using trial accounts with unverified numbers

2. **"Twilio SMS service is not configured"**
   - Ensure all three environment variables are set correctly
   - Check that values don't contain the placeholder text

3. **"Invalid phone number format"**
   - Ensure phone number is in E.164 format (+1234567890)
   - Remove any spaces, dashes, or parentheses

4. **"Failed to send SMS"**
   - Check your Twilio account balance
   - Verify the phone number is verified in your Twilio account (for trial accounts)
   - Check Twilio Console logs for detailed error messages

5. **SMS not received**
   - Check if the recipient number is verified (required for trial accounts)
   - Verify the sender phone number is active in Twilio
   - Check spam/junk folders

### Trial Account Limitations

- Can only send SMS to verified phone numbers
- Limited number of SMS messages
- SMS messages include "Sent from your Twilio trial account" prefix

### Production Deployment

1. Upgrade your Twilio account to remove trial limitations
2. Use secure environment variable management (AWS Secrets Manager, etc.)
3. Never commit credentials to version control
4. Consider using Twilio's Verify API for enhanced security

## Support

If you encounter issues:

1. Check Twilio Console logs: https://console.twilio.com/logs
2. Review Twilio documentation: https://www.twilio.com/docs/sms
3. Contact Twilio support: https://support.twilio.com/

## Security Best Practices

1. Never commit credentials to version control
2. Use environment variables for all sensitive data
3. Rotate credentials regularly
4. Monitor usage in Twilio Console
5. Set up billing alerts to avoid unexpected charges
6. Use Twilio's IP allowlisting for additional security