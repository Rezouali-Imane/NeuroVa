import { aiClient } from '../../infrastructure/ai/openai.client.js';
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
  const model = resolveChatModel();
  let reply = "I couldn't analyze that image right now. Please try again.";

  try {
    if (aiClient.isClaude) {
      // Claude API - supports image URLs in content blocks
      const response = await aiClient.claude.messages.create({
        model,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: userPrompt },
              {
                type: 'image',
                source: {
                  type: 'url',
                  url: data.imageDataUrl,
                },
              },
            ] as any,
          },
        ],
        system: 'You are Neurova, a helpful academic assistant. Analyze the image and answer clearly in markdown. Refuse unsafe requests.',
        max_tokens: 1000,
      });
      const textBlock = response.content?.[0] as any;
      const claudeText = textBlock?.type === 'text' ? textBlock.text : null;
      reply = claudeText?.trim() || reply;
    } else {
      // OpenAI/Gemini API
      const response = await aiClient.openai.chat.completions.create({
        model,
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
        max_tokens: 1000,
      });
      reply = response.choices[0]?.message?.content?.trim() || reply;
    }
  } catch (error) {
    console.error('Image message error:', error);
  }

  await ChatHistoryRepository.save(data.userid, 'USER', `[IMAGE] ${userPrompt}`);
  await ChatHistoryRepository.save(data.userid, 'ASSISTANT', reply);

  return {
    reply,
    language: 'English',
    usedDocuments: false,
    actions: [],
  };
};
