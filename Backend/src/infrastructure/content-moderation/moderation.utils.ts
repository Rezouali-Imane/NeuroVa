import 'dotenv/config';
import prisma from '../database/prisma.client.js';
import type { ContentModerationDecision } from '../../interfaces/dtos/ContentModeration.dto.js';

const UNSAFE_TEXT_TERMS = [
  'porn',
  'porno',
  'xxx',
  'nude',
  'naked',
  'explicit sex',
  'rape',
  'incest',
  'gore',
  'beheading',
  'kill',
  'murder',
  'terror',
  'bomb',
  'how to make a bomb',
  'suicide',
  'self-harm',
  'hate speech',
  'meth',
  'cocaine',
  'heroin',
];

const SENSITIVE_TEXT_TERMS = [
  'violence',
  'weapon',
  'blood',
  'depression',
  'anxiety',
  'drugs',
  'adult',
  'nsfw',
  'escort',
  'casino',
  'betting',
];

const UNSAFE_IMAGE_TOKENS = [
  'nsfw',
  'porn',
  'nude',
  'nudity',
  'sex',
  'gore',
  'blood',
  'violence',
  'weapon',
  'beheading',
  'selfharm',
  'explicit',
  'fetish',
];

const HIGH_RISK_TEXT_PATTERNS: Array<{ pattern: RegExp; weight: number; category: string }> = [
  { pattern: /\b(rape|incest|child\s?porn|cp)\b/i, weight: 45, category: 'sexual_violence' },
  {
    pattern: /\b(how to make a bomb|build a bomb|terror attack|mass shooting)\b/i,
    weight: 42,
    category: 'extreme_violence',
  },
  {
    pattern: /\b(kill myself|suicide plan|self[-\s]?harm)\b/i,
    weight: 40,
    category: 'self_harm',
  },
];

const MEDIUM_RISK_URL_TOKENS: Array<{ token: string; weight: number; category: string }> = [
  { token: 'porn', weight: 35, category: 'adult_content' },
  { token: 'xxx', weight: 35, category: 'adult_content' },
  { token: 'nude', weight: 28, category: 'adult_content' },
  { token: 'escort', weight: 24, category: 'adult_services' },
  { token: 'casino', weight: 20, category: 'gambling' },
  { token: 'bet', weight: 18, category: 'gambling' },
  { token: 'torrent', weight: 16, category: 'risky_site' },
];

const toRiskLevel = (score: number): 'LOW' | 'MEDIUM' | 'HIGH' => {
  if (score >= 70) return 'HIGH';
  if (score >= 35) return 'MEDIUM';
  return 'LOW';
};

const clamp = (value: number, min = 0, max = 100): number => Math.max(min, Math.min(max, value));

const scoreTextRisk = (text: string) => {
  let score = 0;
  const categories = new Set<string>();

  for (const rule of HIGH_RISK_TEXT_PATTERNS) {
    if (rule.pattern.test(text)) {
      score += rule.weight;
      categories.add(rule.category);
    }
  }

  for (const term of UNSAFE_TEXT_TERMS) {
    if (text.includes(term)) {
      score += 14;
      categories.add('unsafe_text');
    }
  }

  for (const term of SENSITIVE_TEXT_TERMS) {
    if (text.includes(term)) {
      score += 7;
      categories.add('sensitive_text');
    }
  }

  return {
    score: clamp(score),
    categories: [...categories],
  };
};

const scoreImageRisk = (imageUrl: string) => {
  let score = 0;
  const categories = new Set<string>();

  for (const token of UNSAFE_IMAGE_TOKENS) {
    if (imageUrl.includes(token)) {
      score += 13;
      categories.add('unsafe_image');
    }
  }

  if (/\b(nsfw|explicit|18\+|adult)\b/i.test(imageUrl)) {
    score += 20;
    categories.add('adult_image');
  }

  return {
    score: clamp(score),
    categories: [...categories],
  };
};

const parseBlockedDomainsFromEnv = (): string[] => {
  const raw = process.env.DEFAULT_BLOCKED_DOMAINS?.trim() ?? '';
  if (!raw) return [];

  const items = raw
    .split(/[\n,;]+/)
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean);

  const sanitized = items
    .map((item) => item.replace(/^https?:\/\//, '').replace(/^www\./, '').split('/')[0] ?? item)
    .filter((item) => item.includes('.'));

  return [...new Set(sanitized)];
};

export const DEFAULT_BLOCKED_DOMAINS = parseBlockedDomainsFromEnv();

const normalizeDomain = (value: string): string => {
  const trimmed = value.trim().toLowerCase();
  const withoutProtocol = trimmed.replace(/^https?:\/\//, '');
  const host = withoutProtocol.split('/')[0] ?? '';
  return host.replace(/^www\./, '');
};

const domainMatches = (candidate: string, blocked: string): boolean =>
  candidate === blocked || candidate.endsWith(`.${blocked}`);

export const extractCandidateDomains = (value: string): string[] => {
  const text = value.toLowerCase();
  const matches = text.match(/(?:https?:\/\/)?(?:www\.)?[a-z0-9-]+(?:\.[a-z0-9-]+)+/g) ?? [];
  const normalized = matches.map(normalizeDomain).filter(Boolean);
  return [...new Set(normalized)];
};

export const findMatchedBlockedDomains = (
  source: string,
  blockedDomains: string[],
): string[] => {
  const candidates = extractCandidateDomains(source);
  if (candidates.length === 0) return [];

  const normalizedBlocked = blockedDomains.map(normalizeDomain).filter(Boolean);
  const matched = new Set<string>();

  for (const candidate of candidates) {
    for (const blocked of normalizedBlocked) {
      if (domainMatches(candidate, blocked)) matched.add(blocked);
    }
  }

  return [...matched];
};

export const ensureModerationContext = async (userid: string) => {
  const settings = await prisma.digitaldisciplinesettings.upsert({
    where: { userid },
    update: {},
    create: {
      userid,
      filterlevel: 'SFW_STRICT',
      dailyfreeminutes: 0,
      customblockingenabled: true,
      faithmodeenabled: false,
    },
  });

  const policy = await prisma.contentmoderationpolicy.upsert({
    where: { settingsid: settings.settingsid },
    update: {},
    create: {
      settingsid: settings.settingsid,
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    },
  });

  const existingWebsites = await prisma.blockedwebsite.findMany({
    where: { settingsid: settings.settingsid },
    select: { domain: true },
  });

  const existingSet = new Set(existingWebsites.map((w) => normalizeDomain(w.domain)));
  const missingDefaults = DEFAULT_BLOCKED_DOMAINS.filter(
    (domain) => !existingSet.has(normalizeDomain(domain)),
  );

  if (missingDefaults.length > 0) {
    await prisma.blockedwebsite.createMany({
      data: missingDefaults.map((domain) => ({
        settingsid: settings.settingsid,
        domain,
      })),
    });
  }

  const mergedBlockedDomains = [
    ...new Set([...DEFAULT_BLOCKED_DOMAINS, ...existingWebsites.map((w) => w.domain)]),
  ];

  return { settings, policy, blockedDomains: mergedBlockedDomains };
};

export const classifyTextContent = (
  content: string,
  policyLevel: 'NORMAL' | 'SFW_STRICT',
  blockingEnabled: boolean,
  blockedDomains: string[],
): ContentModerationDecision => {
  const text = content.toLowerCase();
  const risk = scoreTextRisk(text);
  const hasUnsafeTerm = UNSAFE_TEXT_TERMS.some((term) => text.includes(term));
  const hasSensitiveTerm = SENSITIVE_TEXT_TERMS.some((term) => text.includes(term));
  const unsafeHit = hasUnsafeTerm || risk.score >= 70;
  const sensitiveHit = hasSensitiveTerm || risk.score >= 35;
  const matchedDomains = findMatchedBlockedDomains(content, blockedDomains);

  if (matchedDomains.length > 0) {
    const score = clamp(Math.max(risk.score, 96));
    return {
      decision: 'BLOCK',
      reason: `Blocked domain detected: ${matchedDomains[0]}`,
      confidence: 0.99,
      riskScore: score,
      riskLevel: toRiskLevel(score),
      matchedCategories: [...new Set([...risk.categories, 'blocked_domain'])],
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  if (unsafeHit || ((blockingEnabled || policyLevel === 'SFW_STRICT') && sensitiveHit)) {
    const score = clamp(Math.max(risk.score, unsafeHit ? 88 : 74));
    return {
      decision: 'BLOCK',
      reason: unsafeHit ? 'Unsafe content detected' : 'Sensitive content blocked by policy',
      confidence: unsafeHit ? 0.96 : 0.84,
      riskScore: score,
      riskLevel: toRiskLevel(score),
      matchedCategories: risk.categories,
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  if (sensitiveHit || text.length < 8) {
    const score = clamp(Math.max(risk.score, text.length < 8 ? 30 : 38));
    return {
      decision: 'REVIEW',
      reason: 'Content may need review',
      confidence: 0.68,
      riskScore: score,
      riskLevel: toRiskLevel(score),
      matchedCategories: risk.categories,
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  const score = clamp(risk.score);
  return {
    decision: 'ALLOW',
    reason: 'Content allowed',
    confidence: 0.91,
    riskScore: score,
    riskLevel: toRiskLevel(score),
    matchedCategories: risk.categories,
    policy: {
      sensitivecontentblockingenabled: blockingEnabled,
      sensitivitylevel: policyLevel,
    },
  };
};

export const classifyImageUrl = (
  imageUrl: string,
  policyLevel: 'NORMAL' | 'SFW_STRICT',
  blockingEnabled: boolean,
  blockedDomains: string[],
): ContentModerationDecision => {
  const lowered = imageUrl.toLowerCase();
  const risk = scoreImageRisk(lowered);
  const tokenBlocked = risk.score >= 45;
  const matchedDomains = findMatchedBlockedDomains(imageUrl, blockedDomains);

  if (matchedDomains.length > 0 || tokenBlocked) {
    const score = matchedDomains.length > 0 ? clamp(Math.max(risk.score, 97)) : clamp(Math.max(risk.score, 82));
    return {
      decision: 'BLOCK',
      reason:
        matchedDomains.length > 0
          ? `Image host is blocked: ${matchedDomains[0]}`
          : 'Image appears unsafe by heuristic scan',
      confidence: matchedDomains.length > 0 ? 0.99 : 0.9,
      riskScore: score,
      riskLevel: toRiskLevel(score),
      matchedCategories:
        matchedDomains.length > 0
          ? [...new Set([...risk.categories, 'blocked_domain'])]
          : risk.categories,
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  if ((policyLevel === 'SFW_STRICT' || blockingEnabled) && risk.score >= 20) {
    const score = clamp(Math.max(risk.score, 42));
    return {
      decision: 'REVIEW',
      reason: 'Image not clearly unsafe but policy requires stricter review',
      confidence: 0.6,
      riskScore: score,
      riskLevel: toRiskLevel(score),
      matchedCategories: risk.categories,
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  const score = clamp(risk.score);
  return {
    decision: 'ALLOW',
    reason: 'Image allowed',
    confidence: 0.82,
    riskScore: score,
    riskLevel: toRiskLevel(score),
    matchedCategories: risk.categories,
    policy: {
      sensitivecontentblockingenabled: blockingEnabled,
      sensitivitylevel: policyLevel,
    },
  };
};

export const classifyUrlAccess = (
  inputUrl: string,
  policyLevel: 'NORMAL' | 'SFW_STRICT',
  blockingEnabled: boolean,
  blockedDomains: string[],
): ContentModerationDecision => {
  const lowered = inputUrl.toLowerCase();
  const matchedDomains = findMatchedBlockedDomains(inputUrl, blockedDomains);

  let score = 0;
  const categories = new Set<string>();
  for (const rule of MEDIUM_RISK_URL_TOKENS) {
    if (lowered.includes(rule.token)) {
      score += rule.weight;
      categories.add(rule.category);
    }
  }

  if (matchedDomains.length > 0) {
    score = Math.max(score, 96);
    categories.add('blocked_domain');
    return {
      decision: 'BLOCK',
      reason: `Blocked domain detected: ${matchedDomains[0]}`,
      confidence: 0.99,
      riskScore: clamp(score),
      riskLevel: toRiskLevel(score),
      matchedCategories: [...categories],
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  if ((policyLevel === 'SFW_STRICT' || blockingEnabled) && score >= 45) {
    const strictScore = clamp(Math.max(score, 76));
    return {
      decision: 'BLOCK',
      reason: 'URL blocked by strict safety model',
      confidence: 0.9,
      riskScore: strictScore,
      riskLevel: toRiskLevel(strictScore),
      matchedCategories: [...categories],
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  if (score >= 20) {
    const reviewScore = clamp(Math.max(score, 40));
    return {
      decision: 'REVIEW',
      reason: 'URL appears risky and requires review',
      confidence: 0.72,
      riskScore: reviewScore,
      riskLevel: toRiskLevel(reviewScore),
      matchedCategories: [...categories],
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel,
      },
    };
  }

  const allowScore = clamp(score);
  return {
    decision: 'ALLOW',
    reason: 'URL allowed',
    confidence: 0.88,
    riskScore: allowScore,
    riskLevel: toRiskLevel(allowScore),
    matchedCategories: [...categories],
    policy: {
      sensitivecontentblockingenabled: blockingEnabled,
      sensitivitylevel: policyLevel,
    },
  };
};