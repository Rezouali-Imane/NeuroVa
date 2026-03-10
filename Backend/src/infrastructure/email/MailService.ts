import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export const MailService = {
  async sendVerificationCode(email: string, code: string) {
    await resend.emails.send({
      from: 'Neurova <onboarding@resend.dev>',
      to: email,
      subject: 'Verify your Neurova account',
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body { 
                margin: 0; 
                padding: 0; 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                background-color: #f5f5f5;
              }
              .container { 
                max-width: 600px; 
                margin: 40px auto; 
                background: white; 
                border-radius: 12px; 
                overflow: hidden;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              }
              .header { 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                padding: 40px 20px; 
                text-align: center;
              }
              .content { 
                padding: 40px 30px; 
                text-align: center;
              }
              .code-box { 
                background: #f8f9fa; 
                border: 2px dashed #667eea; 
                border-radius: 8px; 
                padding: 20px; 
                margin: 30px 0;
                display: inline-block;
              }
              .code { 
                font-size: 32px; 
                font-weight: bold; 
                letter-spacing: 4px; 
                color: #667eea;
                font-family: 'Courier New', monospace;
              }
              .footer { 
                background: #f8f9fa; 
                padding: 20px; 
                text-align: center; 
                color: #6c757d; 
                font-size: 14px;
              }
              h1 { 
                color: white; 
                margin: 0; 
                font-size: 24px; 
                font-weight: 600;
              }
              p { 
                color: #495057; 
                line-height: 1.6; 
                margin: 10px 0;
              }
              .expiry { 
                color: #6c757d; 
                font-size: 14px; 
                margin-top: 20px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Verify Your Account</h1>
              </div>
              <div class="content">
                <p style="font-size: 16px;">Welcome to Neurova! 🎉</p>
                <p>Please use the verification code below to complete your registration:</p>
                <div class="code-box">
                  <div class="code">${code}</div>
                </div>
                <p class="expiry">⏰ This code will expire in 15 minutes</p>
              </div>
              <div class="footer">
                <p>If you didn't create an account with Neurova, you can safely ignore this email.</p>
                <p>© 2026 Neurova. All rights reserved.</p>
              </div>
            </div>
          </body>
        </html>
      `,
    });
  },

  async sendResetPasswordCode(email: string, code: string) {
    await resend.emails.send({
      from: 'Neurova Security <security@resend.dev>',
      to: email,
      subject: 'Reset your password',
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body { 
                margin: 0; 
                padding: 0; 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                background-color: #f5f5f5;
              }
              .container { 
                max-width: 600px; 
                margin: 40px auto; 
                background: white; 
                border-radius: 12px; 
                overflow: hidden;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              }
              .header { 
                background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); 
                padding: 40px 20px; 
                text-align: center;
              }
              .content { 
                padding: 40px 30px; 
                text-align: center;
              }
              .code-box { 
                background: #fff5f5; 
                border: 2px dashed #f5576c; 
                border-radius: 8px; 
                padding: 20px; 
                margin: 30px 0;
                display: inline-block;
              }
              .code { 
                font-size: 32px; 
                font-weight: bold; 
                letter-spacing: 4px; 
                color: #f5576c;
                font-family: 'Courier New', monospace;
              }
              .warning { 
                background: #fff3cd; 
                border-left: 4px solid #ffc107; 
                padding: 15px; 
                margin: 20px 0; 
                text-align: left;
                border-radius: 4px;
              }
              .footer { 
                background: #f8f9fa; 
                padding: 20px; 
                text-align: center; 
                color: #6c757d; 
                font-size: 14px;
              }
              h1 { 
                color: white; 
                margin: 0; 
                font-size: 24px; 
                font-weight: 600;
              }
              p { 
                color: #495057; 
                line-height: 1.6; 
                margin: 10px 0;
              }
              .expiry { 
                color: #6c757d; 
                font-size: 14px; 
                margin-top: 20px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Password Reset Request</h1>
              </div>
              <div class="content">
                <p style="font-size: 16px;">We received a request to reset your password.</p>
                <p>Use the code below to reset your password:</p>
                <div class="code-box">
                  <div class="code">${code}</div>
                </div>
                <p class="expiry">⏰ This code will expire in 1 hour</p>
                <div class="warning">
                  <p style="margin: 0; color: #856404;">
                    <strong>⚠️ Security Notice:</strong><br>
                    If you didn't request this password reset, please ignore this email. Your password will remain unchanged.
                  </p>
                </div>
              </div>
              <div class="footer">
                <p>This is an automated message, please do not reply.</p>
                <p>© 2026 Neurova. All rights reserved.</p>
              </div>
            </div>
          </body>
        </html>
      `,
    });
  }
};
