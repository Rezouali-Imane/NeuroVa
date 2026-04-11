import { ContentModerationService } from './ContentModerationService.js';
import type { AnalyzeImageDTO } from '../../interfaces/dtos/ContentModeration.dto.js';

export const AnalyzeImage = async (data: AnalyzeImageDTO) => {
  return ContentModerationService.analyzeImage(data);
};
