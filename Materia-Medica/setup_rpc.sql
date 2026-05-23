-- Run this in your Supabase SQL Editor to enable similarity search
CREATE OR REPLACE FUNCTION match_remedies (
  query_embedding VECTOR(384),
  match_threshold FLOAT,
  match_count INT
)
RETURNS TABLE (
  id INT,
  name TEXT,
  author_name TEXT,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.name,
    a.name as author_name,
    1 - (r.embedding <=> query_embedding) AS similarity
  FROM remedies r
  JOIN authors a ON r.author_id = a.id
  WHERE 1 - (r.embedding <=> query_embedding) > match_threshold
  ORDER BY similarity DESC
  LIMIT match_count;
END;
$$;
