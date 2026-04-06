import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

const supabaseUrl = process.env.SUPABASE_URL ?? '';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY ?? '';

let supabaseClient: any = null;

const getSupabaseClient = (): any => {
  if (!supabaseUrl || !supabaseKey) {
    throw new Error('Supabase vector search is not configured (SUPABASE_URL/SUPABASE_SERVICE_KEY missing).');
  }

  if (!supabaseClient) {
    supabaseClient = createClient(supabaseUrl, supabaseKey);
  }

  return supabaseClient;
};

export const searchSimilarChunks = async (
  queryEmbedding: number[],
  userid: string,
  matchCount: number = 5
): Promise<Array<{ chunkid: string; content: string; similarity: number }>> => {
  const supabase = getSupabaseClient();
  
  // Use direct query instead of RPC (RPC function may not be defined)
  // Calculate similarity using Postgres built-in vector distance
  const embeddingString = `[${queryEmbedding.join(',')}]`;
  
  const { data, error } = await supabase
    .from('documentchunk')
    .select('chunkid, content, embedding')
    .eq('userid', userid)
    .limit(matchCount * 3); // Get extra to allow filtering

  if (error) throw new Error(`Vector search error: ${error.message}`);
  
  if (!data || data.length === 0) return [];
  
  // Calculate similarity (cosine would be ideal, using euclidean for now)
  const results = data
    .map((chunk: any) => ({
      chunkid: chunk.chunkid,
      content: chunk.content,
      similarity: calculateEmbeddingSimilarity(queryEmbedding, chunk.embedding),
    }))
    .sort((a, b) => b.similarity - a.similarity)
    .slice(0, matchCount);
  
  return results;
};

// Helper: Calculate cosine similarity between two embeddings
const calculateEmbeddingSimilarity = (a: number[], b: any): number => {
  if (!b || typeof b === 'string') {
    try {
      b = JSON.parse(b);
    } catch {
      return 0;
    }
  }
  
  if (!Array.isArray(b) || a.length !== b.length) return 0;
  
  let dotProduct = 0;
  let normA = 0;
  let normB = 0;
  
  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  
  const denominator = Math.sqrt(normA * normB);
  return denominator === 0 ? 0 : dotProduct / denominator;
};

export const insertChunkWithEmbedding = async (
  chunkid: string,
  embedding: number[]
): Promise<void> => {
  const supabase = getSupabaseClient();
  const { error } = await supabase
    .from('documentchunk')
    .update({ embedding: `[${embedding.join(',')}]` })
    .eq('chunkid', chunkid);

  if (error) throw new Error(`Embedding insert error: ${error.message}`);
};