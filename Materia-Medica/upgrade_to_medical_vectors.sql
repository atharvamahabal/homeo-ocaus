-- Run this in Supabase SQL Editor to upgrade the vector dimension for the medical model
-- pritamdeka/S-PubMedBert-MS-MARCO uses a 768-dimensional vector

-- 1. Drop the old structured search function first as it depends on the column types
DROP FUNCTION IF EXISTS match_remedies_structured(vector, float, int, text);
DROP FUNCTION IF EXISTS match_remedies(vector, float, int);

-- 2. Alter columns to change VECTOR(384) to VECTOR(768)
-- Note: We have to drop and recreate the columns because Postgres/pgvector doesn't support direct resizing easily
-- Since we are going to re-embed everything anyway, this is the cleanest path.

ALTER TABLE remedies DROP COLUMN IF EXISTS embedding;
ALTER TABLE remedies DROP COLUMN IF EXISTS keynotes_embedding;
ALTER TABLE remedies DROP COLUMN IF EXISTS modalities_worse_embedding;
ALTER TABLE remedies DROP COLUMN IF EXISTS modalities_better_embedding;
ALTER TABLE remedies DROP COLUMN IF EXISTS mental_symptoms_embedding;
ALTER TABLE remedies DROP COLUMN IF EXISTS physical_symptoms_embedding;
ALTER TABLE remedies DROP COLUMN IF EXISTS miasm_embedding;
ALTER TABLE remedies DROP COLUMN IF EXISTS constitution_embedding;

ALTER TABLE remedies ADD COLUMN embedding VECTOR(768);
ALTER TABLE remedies ADD COLUMN keynotes_embedding VECTOR(768);
ALTER TABLE remedies ADD COLUMN modalities_worse_embedding VECTOR(768);
ALTER TABLE remedies ADD COLUMN modalities_better_embedding VECTOR(768);
ALTER TABLE remedies ADD COLUMN mental_symptoms_embedding VECTOR(768);
ALTER TABLE remedies ADD COLUMN physical_symptoms_embedding VECTOR(768);
ALTER TABLE remedies ADD COLUMN miasm_embedding VECTOR(768);
ALTER TABLE remedies ADD COLUMN constitution_embedding VECTOR(768);

-- 3. Recreate the targeted search function with the new dimension
CREATE OR REPLACE FUNCTION match_remedies_structured (
  query_embedding VECTOR(768),
  match_threshold FLOAT,
  match_count INT,
  target_column TEXT
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
