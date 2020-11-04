CREATE INDEX ON :Input(hash);
CREATE INDEX ON :Output(hash);
CREATE INDEX ON :Transaction(id);

--constraints
CREATE CONSTRAINT ON (t:Transaction) ASSERT t.id IS UNIQUE;
CREATE CONSTRAINT ON (i:Input) ASSERT i.id IS UNIQUE;
CREATE CONSTRAINT ON (o:Output) ASSERT o.id IS UNIQUE;

--load nodes

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///addresses-sub.csv' AS row
CREATE (a:Address {id: row.address, 
                            rootAddress: row.root_address})
RETURN count(a);

:auto USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS FROM 'file:///clusters-sub.csv' AS row
CREATE (cl:Cluster {id: row.root_address, 
                                name: row.name, 
                                category: row.category, 
                                firstActivity: row.first_activity, 
                                lastActivity: row.last_activity, 
                                sent: row.sent, 
                                received: row.received,
                                `withdrawals`: row.`withdrawals`,
                                deposits: row.deposits})
RETURN count(cl);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///observations-sub.csv' AS row
CREATE (ob:Observation {id: row.root_address + row.observationtime,
                                rootAddress: row.root_address, 
                                ip: row.ip, 
                                port: row.port, 
                                subversion: row.subversion, 
                                observationTime: row.observationtime, 
                                connectionTime: row.connectiontime, 
                                longitude: row.longitude, 
                                latitude: row.latitude, 
                                country: row.country, 
                                city: row.city, 
                                isp: row.isp, 
                                anonymous: row.anonymous})
RETURN count(ob);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///osint-sub.csv' AS row
CREATE (co:Comment {id: row.url,
                                rootAddress: row.root_address, 
                                name: row.name, 
                                categoryGroup: row.categorygroup,
                                category: row.category, 
                                label: row.label, 
                                text: row.text, 
                                timePosted: row.time})
RETURN count(co);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///outputs-sub.csv' AS row
MERGE (t:Transaction {id: row.hash})
CREATE (o:Output{id:row.row_id,
                hash: row.hash,
                address: row.address, 
                rootAddress: row.root_address, 
                value: row.value, 
                name: row.name, 
                category: row.category})
CREATE (t)-[r:OUTPUT_TO]->(o)
RETURN count(o) as OutputCount, count(t) as TransactionCount;

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///inputs-sub.csv' AS row
MERGE (t:Transaction {id: row.hash})
CREATE (i:Input{id:row.row_id,
                hash: row.hash,
                address: row.address, 
                rootAddress: row.root_address, 
                value: row.value, 
                name: row.name, 
                category: row.category})
CREATE (i)-[r:INPUT_TO]->(t)
RETURN count(i) as InputCount, count(t) as TransactionCount;

---------------------------------------------------- abandoned crap
--MERGE (t:Transaction {txHash: row.hash}) --including this explodes to year long query
--RETURN count(t);
--this version would take a couple of weeks
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///inputs-sub.csv' AS row
MERGE (i:Input {rowId: row.row_id})
ON CREATE SET 		
    i.hash = row.hash,
    i.address = row.address, 
    i.rootAddress = row.root_address, 
    i.value = row.value, 
    i.name = row.name, 
    i.category = row.category;
-------------------------------------------------------------


--create edges
MATCH (a:Address), (cl:Cluster)
WHERE a.rootAddress = cl.rootAddress
CREATE (a)-[r:MEMBER_OF]->(cl)
RETURN count(r);

MATCH (i:Input), (t:Transaction)
WHERE i.inputId = t.txHash
CREATE (i)-[r:INPUT_TO]->(t)
RETURN count(r);

MATCH (o:Output), (t:Transaction)
WHERE o.outputId = t.txHash
CREATE (t)-[r:OUTPUT_TO]->(o)
RETURN count(r);

MATCH (o:Output), (cl:Cluster)
WHERE o.rootAddress = cl.rootAddress
CREATE (cl)<-[r:RECEIVED]-(o)
RETURN count(r);

MATCH (i:Input), (cl:Cluster)
WHERE i.rootAddress = cl.rootAddress
CREATE (cl)-[r:SENT]->(i)
RETURN count(r);

MATCH (ob:Observation), (cl:Cluster)
WHERE ob.rootAddress = cl.rootAddress
CREATE (cl)-[r:CONNECTED]->(ob)
RETURN count(r);

MATCH (co:Comment), (cl:Cluster)
WHERE co.rootAddress = cl.rootAddress
CREATE (cl)-[r:COMMENTED]->(co)
RETURN count(r);


--explore graph
match path=(:Comment)<-[:COMMENTED]-(:Cluster)<-[r:RECEIVED]-(Output)
RETURN path
