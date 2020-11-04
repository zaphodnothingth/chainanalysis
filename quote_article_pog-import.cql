//guide:  https://neo4j.com/developer/guide-importing-data-and-etl/
//ERROR : Executing queries that use periodic commit in an open transaction is not possible.

// Create articles              consider using **linenumber() AS number
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///articles_20200225.csv" AS row
CREATE (:Article {articleTitle: row.article_title, 
//					articleLink: row.article_link,      //i think we don't want to save this property; just use it for relationship later
                    author: row.author, 
                    publication: row.publication, 
                    date: row.date});
								

// Create quotes
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///quotes_20200225.csv" AS row
CREATE (:Quote {//quoteLink: row.article_link, //i think we don't want to save this property; just use it for relationship later
				//quotePog: row.speaker,  //i think we don't want to save this property; just use it for relationship later
				quoteText: row.quote,  
				quotePosition: row.position});


// Create persons/groups
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///pog_20200225.csv" AS row
CREATE (:Pog {pog: row.person, 
				pogParty: row.party, 
				pogReligion: row.religion, 
				pogAge: toInteger(row.age), 
				pogCountry: row.location_country, 
				pogProvince: row.location_province, 
				pogCity: row.location_city, 
				pogEducation: row.education, 
                pogProfession: row.profession});

// Create indexes
CREATE INDEX ON :Article(article_link); 
CREATE INDEX ON :Pog(pog);

////////////////////////////////////////////////////////////////
//Create relationships - tabbbed don't work....?

                USING PERIODIC COMMIT
                LOAD CSV WITH HEADERS FROM "file:///articles_20200225.csv" AS row
                MATCH (a:Article {articleLink: row.article_link})
                MATCH (au:Author {author: row.author})
                MERGE (au)-[:WROTE]->(a);

                USING PERIODIC COMMIT
                LOAD CSV WITH HEADERS FROM "file:///articles_20200225:.csv" AS row
                MATCH (au:Author {author: row.author})
                MATCH (p:Publication {publication: row.publication})
                MERGE (au)-[:WORKS_FOR]->(p);


LOAD CSV WITH HEADERS FROM "file:///articles_20200225.csv" AS row
MERGE(a:Article {articleLink: row.article_link})
MERGE(au:Author{author: coalesce(row.author, 'Unknown')})
CREATE (au)-[:WROTE]->(a)

    match path=(:Article)<-[:WROTE]-(:Author) 
    RETURN path

LOAD CSV WITH HEADERS FROM "file:///articles_20200225.csv" AS row
MERGE(au:Author{author: coalesce(row.author, 'Unknown')})
MERGE(p:Publication {publication: row.publication})
CREATE (au)-[:WORKS_FOR]->(p)

    match path=(:Article)<-[:WROTE]-(:Author)-[:WORKS_FOR]->(:Publication)
    RETURN path

LOAD CSV WITH HEADERS FROM "file:///quotes_20200225.csv" AS row
MERGE(a:Article{articleLink: row.article_link})
MERGE(p:pog {speaker: coalesce(row.speaker, 'Unknown')})
CREATE (a)-[:QUOTES]->(p)

    match path=(:pog)<-[:QUOTES]-(:Article)<-[:WROTE]-(:Author)-[:WORKS_FOR]->(:Publication)
    RETURN path
    
LOAD CSV WITH HEADERS FROM "file:///pog_20200225.csv" AS row
MERGE(p:Pog {pog: row.person})
MERGE(pa:Party{pogParty: coalesce(row.party, 'Unknown')})
CREATE (p)-[:PARTY_AFFILIATION]->(pa)

    match path=(:Party)<-[:PARTY_AFFILIATION]-(:Pog)
    RETURN path
    
LOAD CSV WITH HEADERS FROM "file:///pog_20200225.csv" AS row
MERGE(p:Pog {pog: row.person})
MERGE(r:Religion{pogReligion: coalesce(row.religion, 'Unknown')})
CREATE (p)-[:BELIEVES]->(r)

    match path=(:Religion)<-[:BELIEVES]-(:Pog)
    RETURN path
    
LOAD CSV WITH HEADERS FROM "file:///pog_20200225.csv" AS row
MERGE(p:Pog {pog: row.person})
MERGE(c:Country{pogCountry: coalesce(row.location_country, 'Unknown')}) 
CREATE (p)-[:FROM_COUNTRY]->(c)

    match path=(:Country)<-[:FROM_COUNTRY]-(:Pog)
    RETURN path
    
    
    