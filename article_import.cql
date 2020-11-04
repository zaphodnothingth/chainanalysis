# load data & create relationships
LOAD CSV WITH HEADERS FROM "file:///Climate_Change_outputs_.csv" AS row
MERGE(t:Title{title:row.Title})
MERGE(a:Authors{authors: coalesce(row.Authors, 'Unknown')})
CREATE (a)-[:WRITES]->(t)

# see initial load's relationships
match path=(:Title)<-[:WRITES]-(:Author) 
RETURN path