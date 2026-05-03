import openai from '../../infrastructure/ai/openai.client.js';
import { resolveChatModel } from '../../infrastructure/ai/model-resolver.js';
import { AssistantRepository, ChatHistoryRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { SendImageMessageDTO } from '../../interfaces/dtos/AI.dto.js';

const buildPrompt = (prompt?: string, faithmode?: boolean) => {
  const base = prompt?.trim() || 'Describe this image and help me with safe, academic guidance.';
  if (!faithmode) return base;
  return `${base}\n\nFaith mode: keep the response aligned with respectful Islamic values.`;
};

export const SendImageMessage = async (data: SendImageMessageDTO) => {
  if (!data.userid) throw new Error('User ID is required');
  if (!data.imageDataUrl?.trim()) throw new Error('Image data is required');

  await AssistantRepository.findOrCreate(data.userid);

  const userPrompt = buildPrompt(data.prompt, data.faithmode);

  const response = await openai.chat.completions.create({
    model: resolveChatModel(),
    messages: [
      {
        role: 'system',
        content:
          'You are Neurova, a helpful academic assistant. Analyze the image and answer clearly in markdown. Refuse unsafe requests.',
      },
      {
        role: 'user',
        content: [
          { type: 'text', text: userPrompt },
          { type: 'image_url', image_url: { url: data.imageDataUrl } },
        ] as any,
      },
    ],
  });

  const reply =
    response.choices[0]?.message?.content?.trim() ||
    "I couldn't analyze that image right now. Please try again.";

  await ChatHistoryRepository.save(data.userid, 'USER', `[IMAGE] ${userPrompt}`);
  await ChatHistoryRepository.save(data.userid, 'ASSISTANT', reply);

  return {
    reply,
    language: 'English',
    usedDocuments: false,
    actions: [],
  };
};
