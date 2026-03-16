process.env.GEMINI_API_KEY ||= 'test-gemini-key';
process.env.GEMINI_MODEL ||= 'gemini-2.0-flash';
process.env.DATABASE_URL ||= 'postgresql://user:pass@localhost:5432/testdb';
process.env.DIRECT_URL ||= process.env.DATABASE_URL;
process.env.JWT_SECRET ||= 'test-secret';
process.env.RESEND_API_KEY ||= 'test-resend-key';