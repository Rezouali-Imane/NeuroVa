import type { AnalyzeAccessDTO } from '../../interfaces/dtos/ContentModeration.dto.js';
import {
  classifyImageUrl,
  classifyTextContent,
  classifyUrlAccess,
  ensureModerationContext,
} from '../../infrastructure/content-moderation/moderation.utils.js';

export const AnalyzeAccess = async (data: AnalyzeAccessDTO) => {
  const { policy, blockedDomains } = await ensureModerationContext(data.userid);

  const checks = [] as Array<{
    type: 'text' | 'image' | 'url';
    decision: 'ALLOW' | 'REVIEW' | 'BLOCK';
    reason: string;
    confidence: number;
    riskScore?: number;
    riskLevel?: 'LOW' | 'MEDIUM' | 'HIGH';
    matchedCategories?: string[];
  }>;

  if (data.content?.trim()) {
    const textDecision = classifyTextContent(
      data.content,
      policy.sensitivitylevel,
      policy.sensitivecontentblockingenabled,
      blockedDomains,
    );
    checks.push({
      type: 'text',
      decision: textDecision.decision,
      reason: textDecision.reason,
      confidence: textDecision.confidence,
      ...(textDecision.riskScore !== undefined ? { riskScore: textDecision.riskScore } : {}),
      ...(textDecision.riskLevel !== undefined ? { riskLevel: textDecision.riskLevel } : {}),
      ...(textDecision.matchedCategories !== undefined
        ? { matchedCategories: textDecision.matchedCategories }
        : {}),
    });
  }

  if (data.imageUrl?.trim()) {
    const imageDecision = classifyImageUrl(
      data.imageUrl,
      policy.sensitivitylevel,
      policy.sensitivecontentblockingenabled,
      blockedDomains,
    );
    checks.push({
      type: 'image',
      decision: imageDecision.decision,
      reason: imageDecision.reason,
      confidence: imageDecision.confidence,
      ...(imageDecision.riskScore !== undefined
        ? { riskScore: imageDecision.riskScore }
        : {}),
      ...(imageDecision.riskLevel !== undefined
        ? { riskLevel: imageDecision.riskLevel }
        : {}),
      ...(imageDecision.matchedCategories !== undefined
        ? { matchedCategories: imageDecision.matchedCategories }
        : {}),
    });
  }

  if (data.url?.trim()) {
    const urlDecision = classifyUrlAccess(
      data.url,
      policy.sensitivitylevel,
      policy.sensitivecontentblockingenabled,
      blockedDomains,
    );
    checks.push({
      type: 'url',
      decision: urlDecision.decision,
      reason: urlDecision.reason,
      confidence: urlDecision.confidence,
      ...(urlDecision.riskScore !== undefined ? { riskScore: urlDecision.riskScore } : {}),
      ...(urlDecision.riskLevel !== undefined ? { riskLevel: urlDecision.riskLevel } : {}),
      ...(urlDecision.matchedCategories !== undefined
        ? { matchedCategories: urlDecision.matchedCategories }
        : {}),
    });
  }

  const blocked = checks.find((c) => c.decision === 'BLOCK');
  const review = checks.find((c) => c.decision === 'REVIEW');

  const finalDecision = blocked?.decision ?? review?.decision ?? 'ALLOW';
  const reason = blocked?.reason ?? review?.reason ?? 'Content access allowed';
  const confidence = blocked?.confidence ?? review?.confidence ?? 0.9;

  return {
    decision: finalDecision,
    reason,
    confidence,
    checks,
    policy: {
      sensitivecontentblockingenabled: policy.sensitivecontentblockingenabled,
      sensitivitylevel: policy.sensitivitylevel,
    },
    blockedByPolicy: finalDecision === 'BLOCK',
  };
};
