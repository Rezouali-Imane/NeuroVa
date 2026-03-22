import prisma from '../../infrastructure/database/prisma.client.js';
import { extractTextFromPDF, extractTextFromFile, chunkText, cleanText } from '../../infrastructure/pdf.chunker.js';
import { getEmbeddings } from '../../infrastructure/embedding.client.js';
import { insertChunkWithEmbedding } from '../../infrastructure/supabase.vector.client.js';
import { KnowledgeBaseRepository, AssistantRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { UploadDocumentDTO } from '../../interfaces/dtos/AI.dto.js';

export const ProcessDocument = async (data: UploadDocumentDTO) => {
  if (!data.userid) throw new Error('User ID is required');
  if (!data.fileBuffer) throw new Error('File is required');

  const assistant = await AssistantRepository.findOrCreate(data.userid, data.major);

  const doc = await KnowledgeBaseRepository.create({
    assistantid: assistant.assistantid,
    filename: data.filename,
    fileurl: '',
    ...(data.major ? { major: data.major } : {}),
    ...(data.subject ? { subject: data.subject } : {}),
  });

  let rawText: string;
  if (data.mimetype === 'application/pdf') {
    rawText = await extractTextFromPDF(data.fileBuffer);
  } else {
    rawText = extractTextFromFile(data.fileBuffer.toString('utf-8'));
  }

  const cleanedText = cleanText(rawText);
  const chunks = chunkText(cleanedText, 500, 50);

  if (chunks.length === 0) throw new Error("I couldn't read any text from this file. Please try a clearer document.");

  const savedChunks = await Promise.all(
    chunks.map((content, index) =>
      prisma.documentchunk.create({
        data: { userid: data.userid, knowledgeid: doc.knowledgeid, content, chunkindex: index },
      })
    )
  );

  const embeddings = await getEmbeddings(chunks);
  await Promise.all(
    savedChunks.map((chunk, index) =>
      insertChunkWithEmbedding(chunk.chunkid, embeddings[index]!)
    )
  );

  return {
    documentid: doc.knowledgeid,
    filename: data.filename,
    chunksCreated: chunks.length,
    message: `Document processed. ${chunks.length} chunks indexed.`,
  };
};