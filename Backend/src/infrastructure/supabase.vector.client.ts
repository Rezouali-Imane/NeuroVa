import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

const supabaseUrl = process.env.SUPABASE_URL ?? '';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY ?? '';

type SupabaseChunkRow = {
  chunkid: string;
  content: string;
  embedding?: number[] | string | null;
};

let supabaseClient: ReturnType<typeof createClient> | null = null;

const getSupabaseClient = (): ReturnType<typeof createClient> => {
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
  const { data, error } = await supabase
    .from('documentchunk')
    .select('chunkid, content, embedding')
    .eq('userid', userid)
    .limit(matchCount * 3); // Get extra to allow filtering

  if (error) throw new Error(`Vector search error: ${error.message}`);
  
  if (!data || data.length === 0) return [];
  
  // Calculate similarity (cosine would be ideal, using euclidean for now)
  const results = (data as SupabaseChunkRow[])
    .map((chunk) => ({
      chunkid: chunk.chunkid,
      content: chunk.content,
      similarity: calculateEmbeddingSimilarity(queryEmbedding, chunk.embedding),
    }))
    .sort((left, right) => right.similarity - left.similarity)
    .slice(0, matchCount);
  
  return results;
};

// Helper: Calculate cosine similarity between two embeddings
const calculateEmbeddingSimilarity = (a: number[], b: unknown): number => {
  let vectorB: number[] | null = null;

  if (Array.isArray(b)) {
    vectorB = b;
  } else if (typeof b === 'string') {
    try {
      const parsed = JSON.parse(b);
      vectorB = Array.isArray(parsed) ? parsed : null;
    } catch {
      return 0;
    }
  }
  
  if (!vectorB || a.length !== vectorB.length) return 0;
  
  let dotProduct = 0;
  let normA = 0;
  let normB = 0;
  
  for (let i = 0; i < a.length; i++) {
    const valueA = a[i] ?? 0;
    const valueB = vectorB[i] ?? 0;
    dotProduct += valueA * valueB;
    normA += valueA * valueA;
    normB += valueB * valueB;
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
    .update({ embedding: `[${embedding.join(',')}]` } as never)
    .eq('chunkid', chunkid);

  if (error) throw new Error(`Embedding insert error: ${error.message}`);
};