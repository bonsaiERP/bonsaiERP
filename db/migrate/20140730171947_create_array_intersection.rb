class CreateArrayIntersection < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.array_intersection(anyarray, anyarray)
  RETURNS anyarray AS
$BODY$
SELECT ARRAY(
    SELECT $1[i]
    FROM generate_series( array_lower($1, 1), array_upper($1, 1) ) i
    WHERE ARRAY[$1[i]] && $2
);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.array_intersection(anyarray, anyarray)
  OWNER TO postgres;
    SQL
  end

  def down
    execute "DROP FUNCTION IF EXISTS public.array_intersection(anyarray, anyarray)"
  end
end
