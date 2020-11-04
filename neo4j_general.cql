----------    IMPORTING     ------------
----------------------------------------
--load CSV with nodes as columns
LOAD CSV WITH HEADERS FROM 'file:///data.csv' AS row
MERGE (e:Employee {employeeId: row.employeeId})
RETURN count(e);

LOAD CSV WITH HEADERS FROM 'file:///data.csv' AS row
MERGE (c:Company {companyId: row.companyId})
RETURN count(c);

LOAD CSV WITH HEADERS FROM 'file:///data.csv' AS row
MATCH (e:Employee {employeeId: row.employeeId})
MATCH (c:Company {companyId: row.companyId})
MERGE (e)-[r:WORKS_FOR]->(c)
RETURN count(*);

----------------------------------------
--load separate CSVs, create edges after
:auto
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///clusters-sub.csv' AS row
CREATE (cl:Cluster {rootAddress: row.root_address, 
                                `name`: row.`name`, 
                                category: row.category, 
                                firstActivity: row.first_activity, 
                                lastActivity: row.last_activity, 
                                sent: row.sent, 
                                received: row.received,
                                `withdrawals`: row.`withdrawals`,
                                deposits: row.deposits})
RETURN count(cl);

:auto
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///addresses-sub.csv' AS row
CREATE (a:Address {address: row.address, 
                            rootAddress: row.root_address})
RETURN count(a);

MATCH (a:Address), (cl:Cluster)
WHERE a.rootAddress = cl.rootAddress
CREATE (a)-[r:MEMBER_OF]->(cl)
RETURN count(r);


----------    UPDATING     ------------
---------------------------------------------
--create new node from property on existing
call apoc.periodic.iterate(
        "MATCH (i:Input) RETURN i",
        "MERGE (t:Transaction {txHash: i.inputId})", {batchSize:1000})
--same as last; but when that has memory error
call apoc.periodic.commit(
        "MATCH (i:Input) with i limit $limit
        MERGE (t:Transaction {txHash: i.inputId}) 
        RETURN count(t)", {limit:1000})
---------------------------------------------
--delete unconnected nodes 
MATCH (n) where not (n)--() delete (n);
--or
call apoc.periodic.iterate(
        "MATCH (n) where not (n)--() return n",
        "DELETE n", {batchSize:1000})

--delete all nodes & edges
call apoc.periodic.iterate(
        "match (n:Transaction) RETURN n",
        "DETACH DELETE n", {batchSize:1000}) 
--for when above has memory error
call apoc.periodic.commit(
        "MATCH (i:Input) with i limit $limit
        detach delete i return count(i)", {limit:1000})

--delete all edges of type
MATCH p=()-[r:OUTPUT_FROM]->() delete r


----------    ADMIN     ------------
---------------------------------------------
--return active queries
CALL dbms.listQueries()
--kill query
call dbms.killQuery('neo4j-query-6306')

----------    explore graph     ------------
---------------------------------------------
--full path`
match path=(:Comment)<-[:COMMENTED]-(:Cluster)<-[r:RECEIVED]-(Output)
RETURN path
--find all connections to particular node, up to 3 jumps
MATCH re=(ds:DataSource {id:"8815"})-[r*1..3]-()  --delete *1..3 for single jump
 RETURN re;

