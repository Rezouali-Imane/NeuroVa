import 'dotenv/config';

// Generates 768-dimensional vectors using Gemini text-embedding-004

export const getEmbedding = async (text: string): Promise<number[]> => {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) throw new Error('GEMINI_API_KEY not set');

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: 'models/text-embedding-004',
        content: { parts: [{ text }] },
      }),
    }
  );

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`Embedding API error: ${err}`);
  }

  const data = await response.json();
  return data.embedding.values as number[];
};

// Batch embed multiple texts with small delay to avoid rate limits
export const getEmbeddings = async (texts: string[]): Promise<number[][]> => {
  const embeddings: number[][] = [];
  for (const text of texts) {
    const embedding = await getEmbedding(text);
    embeddings.push(embedding);
    await new Promise(r => setTimeout(r, 100));
  }
  return embeddings;
};