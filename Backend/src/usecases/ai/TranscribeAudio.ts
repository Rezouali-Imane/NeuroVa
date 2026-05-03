import openai from '../../infrastructure/ai/openai.client.js';
import { toFile } from 'openai/uploads';

export const TranscribeAudio = async (
  fileBuffer: Buffer,
  filename: string,
  mimetype: string,
): Promise<string> => {
  if (!fileBuffer || fileBuffer.length === 0) {
    throw new Error('Audio file is empty');
  }

  try {
    const file = await toFile(fileBuffer, filename || 'voice-message.webm', {
      type: mimetype || 'audio/webm',
    });

    const transcript = await openai.audio.transcriptions.create({
      file,
      model: 'whisper-1',
    });

    const text = transcript.text?.trim() ?? '';
    if (!text) {
      throw new Error('Unable to transcribe voice message');
    }

    return text;
  } catch {
    throw new Error(
      'Voice transcription is not available with the current AI provider configuration.',
    );
  }
};
