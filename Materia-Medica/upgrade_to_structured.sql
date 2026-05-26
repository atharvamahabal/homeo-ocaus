-- Run this in Supabase SQL Editor to upgrade the schema to Structured Data
-- This adds separate columns for clinical sections and their embeddings

ALTER TABLE remedies 
ADD COLUMN IF NOT EXISTS keynotes TEXT,
ADD COLUMN IF NOT EXISTS keynotes_embedding VECTOR(384),
ADD COLUMN IF NOT EXISTS modalities_worse TEXT,
ADD COLUMN IF NOT EXISTS modalities_worse_embedding VECTOR(384),
ADD COLUMN IF NOT EXISTS modalities_better TEXT,
ADD COLUMN IF NOT EXISTS modalities_better_embedding VECTOR(384),
ADD COLUMN IF NOT EXISTS mental_symptoms TEXT,
ADD COLUMN IF NOT EXISTS mental_symptoms_embedding VECTOR(384),
ADD COLUMN IF NOT EXISTS physical_symptoms TEXT,
ADD COLUMN IF NOT EXISTS physical_symptoms_embedding VECTOR(384),
ADD COLUMN IF NOT EXISTS miasm TEXT,
ADD COLUMN IF NOT EXISTS miasm_embedding VECTOR(384),
ADD COLUMN IF NOT EXISTS constitution TEXT,
ADD COLUMN IF NOT EXISTS constitution_embedding VECTOR(384);

-- Create a targeted search function
CREATE OR REPLACE FUNCTION match_remedies_structured (
  query_embedding VECTOR(384),
  match_threshold FLOAT,
  match_count INT,
  target_column TEXT -- 'full_text', 'keynotes', 'modalities_worse', etc.
)
RETURNS TABLE (
  id BIGINT,
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
    CASE 
      WHEN target_column = 'keynotes' THEN 1 - (r.keynotes_embedding <=> query_embedding)
      WHEN target_column = 'modalities_worse' THEN 1 - (r.modalities_worse_embedding <=> query_embedding)
      WHEN target_column = 'modalities_better' THEN 1 - (r.modalities_better_embedding <=> query_embedding)
      WHEN target_column = 'mental_symptoms' THEN 1 - (r.mental_symptoms_embedding <=> query_embedding)
      WHEN target_column = 'physical_symptoms' THEN 1 - (r.physical_symptoms_embedding <=> query_embedding)
      WHEN target_column = 'miasm' THEN 1 - (r.miasm_embedding <=> query_embedding)
      WHEN target_column = 'constitution' THEN 1 - (r.constitution_embedding <=> query_embedding)
      ELSE 1 - (r.embedding <=> query_embedding)
    END AS similarity
  FROM remedies r
  JOIN authors a ON r.author_id = a.id
  WHERE 
    CASE 
      WHEN target_column = 'keynotes' THEN 1 - (r.keynotes_embedding <=> query_embedding)
      WHEN target_column = 'modalities_worse' THEN 1 - (r.modalities_worse_embedding <=> query_embedding)
      WHEN target_column = 'modalities_better' THEN 1 - (r.modalities_better_embedding <=> query_embedding)
      WHEN target_column = 'mental_symptoms' THEN 1 - (r.mental_symptoms_embedding <=> query_embedding)
      WHEN target_column = 'physical_symptoms' THEN 1 - (r.physical_symptoms_embedding <=> query_embedding)
      WHEN target_column = 'miasm' THEN 1 - (r.miasm_embedding <=> query_embedding)
      WHEN target_column = 'constitution' THEN 1 - (r.constitution_embedding <=> query_embedding)
      ELSE 1 - (r.embedding <=> query_embedding)
    END > match_threshold
  ORDER BY similarity DESC
  LIMIT match_count;
END;
$$;
