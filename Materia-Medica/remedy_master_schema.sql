-- Consolidated Master Schema for Medical-Domain Structured Remedies
-- Dimension: 768 (pritamdeka/S-PubMedBert-MS-MARCO)

DROP FUNCTION IF EXISTS match_remedies_structured(vector, float, int, text);

ALTER TABLE remedies ADD COLUMN IF NOT EXISTS keynotes TEXT;
ALTER TABLE remedies ADD COLUMN IF NOT EXISTS modalities_worse TEXT;
ALTER TABLE remedies ADD COLUMN IF NOT EXISTS modalities_better TEXT;
ALTER TABLE remedies ADD COLUMN IF NOT EXISTS mental_symptoms TEXT;
ALTER TABLE remedies ADD COLUMN IF NOT EXISTS physical_symptoms TEXT;
ALTER TABLE remedies ADD COLUMN IF NOT EXISTS miasm TEXT;
ALTER TABLE remedies ADD COLUMN IF NOT EXISTS constitution TEXT;

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

NOTIFY pgrst, 'reload schema';
