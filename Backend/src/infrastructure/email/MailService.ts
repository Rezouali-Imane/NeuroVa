import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export const MailService = {
  async sendVerificationCode(email: string, code: string) {
    await resend.emails.send({
      from: 'Neurova <onboarding@resend.dev>',
      to: email,
      subject: 'Vérifiez votre compte Neurova',
      html: `<p>Votre code de vérification est : <strong>${code}</strong></p>
      <p>Ce code expirera dans 1 heure.</p>`,
    });
  },

  async sendResetPasswordCode(email: string, code: string) {
    await resend.emails.send({
      from: 'Neurova Security <security@resend.dev>',
      to: email,
      subject: 'Réinitialisation de votre mot de passe',
      html: `
        <h1>Récupération de compte</h1>
        <p>Utilisez le code suivant pour réinitialiser votre mot de passe : ${code}</p>
        <p>Ce code expirera dans 1 heure.</p>
        <p>Si vous n'avez pas demandé ce changement, vous pouvez ignorer cet email.</p>
      `,
    });
  }
};
