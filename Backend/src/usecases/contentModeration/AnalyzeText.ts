import { ContentModerationService } from './ContentModerationService.js';
import type { AnalyzeTextDTO } from '../../interfaces/dtos/ContentModeration.dto.js';

export const AnalyzeText = async (data: AnalyzeTextDTO) => {
  return ContentModerationService.analyzeText(data);
};
