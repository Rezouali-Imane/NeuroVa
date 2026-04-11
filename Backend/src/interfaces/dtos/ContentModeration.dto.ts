import type { ContentFilterLevel } from './DigitalDiscipline.dto.js';

export interface AnalyzeTextDTO {
  userid: string;
  content: string;
}

export interface AnalyzeImageDTO {
  userid: string;
  imageUrl: string;
}

export interface UpdateContentModerationPolicyDTO {
  sensitivecontentblockingenabled?: boolean;
  sensitivitylevel?: ContentFilterLevel;
}

export interface ContentModerationDecision {
  decision: 'ALLOW' | 'REVIEW' | 'BLOCK';
  reason: string;
  confidence: number;
  policy: {
    sensitivecontentblockingenabled: boolean;
    sensitivitylevel: ContentFilterLevel;
  };
}
