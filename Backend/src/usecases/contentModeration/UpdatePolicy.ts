import { ContentModerationService } from './ContentModerationService.js';
import type { UpdateContentModerationPolicyDTO } from '../../interfaces/dtos/ContentModeration.dto.js';

export const UpdatePolicy = async (userid: string, data: UpdateContentModerationPolicyDTO) => {
  return ContentModerationService.updatePolicy(userid, data);
};
