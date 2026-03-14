import { PDFParse } from 'pdf-parse';

// Extract text from PDF buffer
export const extractTextFromPDF = async (buffer: Buffer): Promise<string> => {
  const parser = new PDFParse({ data: buffer });
  const data = await parser.getText();
  return data.text;
};

// Extract text from plain text file
export const extractTextFromFile = (content: string): string => {
  return content.trim();
};

// Clean extracted text
export const cleanText = (text: string): string => {
  return text
    .replace(/\n{3,}/g, '\n\n')
    .replace(/\s{2,}/g, ' ')
    .trim();
};

// Split text into overlapping chunks of ~500 words
export const chunkText = (
  text: string,
  chunkSize: number = 500,
  overlap: number = 50
): string[] => {
  const words = text.split(/\s+/).filter(w => w.length > 0);
  const chunks: string[] = [];

  let i = 0;
  while (i < words.length) {
    const chunk = words.slice(i, i + chunkSize).join(' ');
    if (chunk.trim()) chunks.push(chunk.trim());
    i += chunkSize - overlap;
  }

  return chunks;
};