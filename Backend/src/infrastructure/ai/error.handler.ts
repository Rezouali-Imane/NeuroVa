import type { Request, Response } from 'express';

export enum AIErrorCode {
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  NOT_FOUND = 'NOT_FOUND',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  RATE_LIMITED = 'RATE_LIMITED',
  EMBEDDING_FAILED = 'EMBEDDING_FAILED',
  VECTOR_SEARCH_FAILED = 'VECTOR_SEARCH_FAILED',
  AI_ERROR = 'AI_ERROR',
  INTERNAL_ERROR = 'INTERNAL_ERROR',
}

export class AIError extends Error {
  constructor(
    public code: AIErrorCode,
    message: string,
    public statusCode: number = 400
  ) {
    super(message);
    this.name = 'AIError';
  }
}

export const validateUserAccess = (requestUserId: string, targetUserId: string): void => {
  if (requestUserId !== targetUserId) {
    throw new AIError(
      AIErrorCode.FORBIDDEN,
      'You do not have permission to access this resource',
      403
    );
  }
};

export const handleAIError = (error: any, res: Response): void => {
  if (error instanceof AIError) {
    console.error(`[AI Error] ${error.code}: ${error.message}`);
    res.status(error.statusCode).json({
      success: false,
      code: error.code,
      message: error.message,
    });
    return;
  }

  if (error instanceof Error) {
    // Determine status based on error type
    let statusCode = 400;
    let code = AIErrorCode.INTERNAL_ERROR;

    if (error.message.includes('Vector search error')) {
      statusCode = 500;
      code = AIErrorCode.VECTOR_SEARCH_FAILED;
    } else if (error.message.includes('Embedding')) {
      statusCode = 500;
      code = AIErrorCode.EMBEDDING_FAILED;
    } else if (error.message.includes('No file')) {
      statusCode = 400;
      code = AIErrorCode.VALIDATION_ERROR;
    }

    console.error(`[${code}] ${error.message}`, error.stack);
    res.status(statusCode).json({
      success: false,
      code,
      message: error.message,
    });
    return;
  }

  console.error('[UNKNOWN_ERROR]', error);
  res.status(500).json({
    success: false,
    code: AIErrorCode.INTERNAL_ERROR,
    message: 'An unexpected error occurred',
  });
};
