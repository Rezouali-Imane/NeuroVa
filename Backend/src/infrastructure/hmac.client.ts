import crypto from 'node:crypto';

type HmacPayload = {
  userid: string;
  code?: string;
  exp: number;
};

const HMAC_SECRET = process.env.HMAC_SECRET || 'change_me_hmac_secret';

const toBase64Url = (value: string): string => {
  return Buffer.from(value).toString('base64url');
};

const fromBase64Url = (value: string): string => {
  return Buffer.from(value, 'base64url').toString('utf8');
};

const sign = (encodedPayload: string): string => {
  return crypto.createHmac('sha256', HMAC_SECRET).update(encodedPayload).digest('base64url');
};

export const HmacClient = {
  generate(payload: { userid: string; code?: string }, expiresInSeconds: number = 900): string {
    const exp = Math.floor(Date.now() / 1000) + expiresInSeconds;
    const rawPayload: HmacPayload = {
      userid: payload.userid,
      exp,
    };

    if (payload.code !== undefined) {
      rawPayload.code = payload.code;
    }

    const encodedPayload = toBase64Url(JSON.stringify(rawPayload));
    const signature = sign(encodedPayload);
    return `${encodedPayload}.${signature}`;
  },

  verify(token: string): { userid: string; code?: string } {
    const [encodedPayload, signature] = token.split('.');

    if (!encodedPayload || !signature) {
      throw new Error('Invalid token format.');
    }

    const expectedSignature = sign(encodedPayload);
    if (signature !== expectedSignature) {
      throw new Error('Invalid token signature.');
    }

    const parsed = JSON.parse(fromBase64Url(encodedPayload)) as HmacPayload;
    const now = Math.floor(Date.now() / 1000);

    if (!parsed.exp || parsed.exp < now) {
      throw new Error('Token expired.');
    }

    return parsed.code !== undefined
      ? { userid: parsed.userid, code: parsed.code }
      : { userid: parsed.userid };
  },
};
