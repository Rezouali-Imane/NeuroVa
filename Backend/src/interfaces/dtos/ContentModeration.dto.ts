import type { ContentFilterLevel } from './DigitalDiscipline.dto.js';

export interface AnalyzeTextDTO {
  userid: string;
  content: string;
}

export interface AnalyzeImageDTO {
  userid: string;
  imageUrl: string;
}

export interface AnalyzeAccessDTO {
  userid: string;
  content?: string;
  imageUrl?: string;
  url?: string;
}

export interface UpdateContentModerationPolicyDTO {
  sensitivecontentblockingenabled?: boolean;
  sensitivitylevel?: ContentFilterLevel;
}

export interface ContentModerationDecision {
  decision: 'ALLOW' | 'REVIEW' | 'BLOCK';
  reason: string;
  confidence: number;
  riskScore?: number;
  riskLevel?: 'LOW' | 'MEDIUM' | 'HIGH';
  matchedCategories?: string[];
  policy: {
    sensitivecontentblockingenabled: boolean;
    sensitivitylevel: ContentFilterLevel;
  };
}
