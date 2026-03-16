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

// Find similar chunks using cosine similarity.
export const searchSimilarChunks = async (
  queryEmbedding: number[],
  userid: string,
  matchCount: number = 5
): Promise<Array<{ chunkid: string; content: string; similarity: number }>> => {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.rpc('match_chunks', {
    query_embedding: queryEmbedding,
    match_userid: userid,
    match_count: matchCount,
  });

  if (error) throw new Error(`Vector search error: ${error.message}`);
  return data ?? [];
};

// Save embedding values into an existing chunk row.
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