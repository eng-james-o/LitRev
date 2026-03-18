import requests
import urllib.parse
import xml.etree.ElementTree as ET
import re
import sqlite3
import json
import logging
from datetime import datetime
from PyPDF2 import PdfReader
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from ratelimit import limits, sleep_and_retry
from .config import logger
from .models import Article

# Rate limits
ARXIV_RATE_LIMIT = 1
ARXIV_PERIOD = 3 # 1 request every 3 seconds
PUBMED_RATE_LIMIT = 3
PUBMED_PERIOD = 1 # 3 requests every 1 second

class ArticleRetriever:
    """Handles searching for and retrieving articles from academic databases"""

    def __init__(self, config_manager):
        self.config_manager = config_manager
        self.user_email = self.config_manager.config.get("user_email", "james.o.oluwadare@gmail.com")
        self.headers = {
            "User-Agent": f"AutoLitRev/1.0 (mailto:{self.user_email})"
        }
        self.cache_db = "data/cache.db"
        self._init_cache()

    def _init_cache(self):
        """Initialize the SQLite cache database"""
        import os
        os.makedirs("data", exist_ok=True)
        with sqlite3.connect(self.cache_db) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS search_cache (
                    query_hash TEXT PRIMARY KEY,
                    results TEXT,
                    timestamp DATETIME
                )
            ''')

    def _get_cache(self, query, databases):
        """Retrieve cached results if available and not too old (e.g., 24h)"""
        query_hash = f"{query}:{','.join(sorted(databases))}"
        with sqlite3.connect(self.cache_db) as conn:
            cursor = conn.execute(
                "SELECT results, timestamp FROM search_cache WHERE query_hash = ?",
                (query_hash,)
            )
            row = cursor.fetchone()
            if row:
                results_json, timestamp_str = row
                timestamp = datetime.fromisoformat(timestamp_str)
                # Cache for 24 hours
                if (datetime.now() - timestamp).total_seconds() < 86400:
                    logger.info(f"Using cached results for: {query}")
                    data = json.loads(results_json)
                    return [Article.from_dict(d) for d in data]
        return None

    def _set_cache(self, query, databases, results):
        """Store results in the cache"""
        query_hash = f"{query}:{','.join(sorted(databases))}"
        results_json = json.dumps([r.to_dict() for r in results])
        with sqlite3.connect(self.cache_db) as conn:
            conn.execute(
                "INSERT OR REPLACE INTO search_cache (query_hash, results, timestamp) VALUES (?, ?, ?)",
                (query_hash, results_json, datetime.now().isoformat())
            )

    def search_articles(self, query, databases):
        """Search for articles using the given query across specified databases"""
        # Check cache first
        cached_results = self._get_cache(query, databases)
        if cached_results is not None:
            return cached_results

        results = []
        for db in databases:
            try:
                logger.info(f"Searching {db} for: {query}")

                if db == "arXiv":
                    db_results = self._search_arxiv(query)
                elif db == "PubMed":
                    db_results = self._search_pubmed(query)
                else:
                    # For other databases, use dummy results for now
                    db_results = self._generate_dummy_results(db, query, 5)

                results.extend(db_results)

            except Exception as e:
                logger.error(f"Error searching {db}: {e}")

        # Store in cache
        self._set_cache(query, databases, results)
        return results

    def _generate_dummy_results(self, database, query, count=5):
        """Generate dummy article results for demonstration purposes"""
        results = []
        keywords = re.findall(r'\b\w+\b', query)
        keywords = [k for k in keywords if k.lower() not in ('and', 'or', 'not')]

        for i in range(1, count + 1):
            keyword = keywords[i % len(keywords)] if keywords else "research"
            year = 2020 + (i % 5)

            article = Article(
                title=f"Research on {keyword.title()} in Modern Context ({i})",
                authors=[f"Author {i}A", f"Author {i}B"],
                journal=f"Journal of {database} Research",
                year=str(year),
                doi=f"10.1234/jxyz.{year}.{i:04d}",
                abstract=f"This study examines {keyword} in various contexts. "
                         f"We explored how {keyword} affects outcomes and presents "
                         f"a new framework for understanding its implications.",
                url=f"https://example.org/{database.lower()}/{year}/{i:04d}",
                source_db=database
            )
            results.append(article)

        return results

    @sleep_and_retry
    @limits(calls=ARXIV_RATE_LIMIT, period=ARXIV_PERIOD)
    @retry(
        retry=retry_if_exception_type(requests.exceptions.HTTPError),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        stop=stop_after_attempt(5)
    )
    def _search_arxiv(self, query):
        """Real implementation for searching arXiv with rate limiting and retries"""
        logger.info(f"Searching arXiv for: {query}")
        results = []

        encoded_query = urllib.parse.quote(query)
        url = f"https://export.arxiv.org/api/query?search_query=all:{encoded_query}&start=0&max_results=10"

        response = requests.get(url, headers=self.headers)
        if response.status_code == 429:
             logger.warning("ArXiv rate limit hit, retrying...")
             response.raise_for_status()

        if response.status_code == 200:
            root = ET.fromstring(response.content)
            # arXiv uses Atom format
            ns = {'atom': 'http://www.w3.org/2005/Atom'}
            for entry in root.findall('atom:entry', ns):
                title = entry.find('atom:title', ns).text.strip().replace('\n', ' ')
                summary = entry.find('atom:summary', ns).text.strip().replace('\n', ' ')
                published = entry.find('atom:published', ns).text[:4]
                url = entry.find('atom:id', ns).text

                authors = []
                for author in entry.findall('atom:author', ns):
                    authors.append(author.find('atom:name', ns).text)

                doi = ""
                doi_elem = entry.find('{http://arxiv.org/schemas/atom}doi')
                if doi_elem is not None:
                    doi = doi_elem.text

                article = Article(
                    title=title,
                    authors=authors,
                    journal="arXiv",
                    year=published,
                    doi=doi,
                    abstract=summary,
                    url=url,
                    source_db="arXiv"
                )
                results.append(article)
        else:
            response.raise_for_status()

        return results

    @sleep_and_retry
    @limits(calls=PUBMED_RATE_LIMIT, period=PUBMED_PERIOD)
    @retry(
        retry=retry_if_exception_type(requests.exceptions.HTTPError),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        stop=stop_after_attempt(5)
    )
    def _search_pubmed(self, query):
        """Real implementation for searching PubMed with rate limiting and retries"""
        logger.info(f"Searching PubMed for: {query}")
        results = []

        # Step 1: Search for IDs
        encoded_query = urllib.parse.quote(query)
        search_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term={encoded_query}&retmode=json&retmax=10"
        search_response = requests.get(search_url, headers=self.headers)

        if search_response.status_code == 429:
            logger.warning("PubMed rate limit hit, retrying...")
            search_response.raise_for_status()

        if search_response.status_code != 200:
            search_response.raise_for_status()

        search_data = search_response.json()
        id_list = search_data.get('esearchresult', {}).get('idlist', [])

        if not id_list:
            return []

        # Step 2: Fetch details for those IDs
        ids = ",".join(id_list)
        summary_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id={ids}&retmode=json"
        summary_response = requests.get(summary_url, headers=self.headers)

        if summary_response.status_code == 429:
            logger.warning("PubMed rate limit hit, retrying...")
            summary_response.raise_for_status()

        if summary_response.status_code != 200:
            summary_response.raise_for_status()

        summary_data = summary_response.json()
        result_data = summary_data.get('result', {})

        for uid in id_list:
            article_data = result_data.get(uid)
            if not article_data:
                continue

            title = article_data.get('title', '').strip()
            authors = [a.get('name') for a in article_data.get('authors', [])]
            journal = article_data.get('source', '')
            year = article_data.get('pubdate', '')[:4]

            # DOI is often in articleids
            doi = ""
            for aid in article_data.get('articleids', []):
                if aid.get('idtype') == 'doi':
                    doi = aid.get('value')
                    break

            url = f"https://pubmed.ncbi.nlm.nih.gov/{uid}/"

            article = Article(
                title=title,
                authors=authors,
                journal=journal,
                year=year,
                doi=doi,
                abstract="", # Summary API doesn't provide abstract, would need efetch
                url=url,
                source_db="PubMed"
            )
            results.append(article)

        return results

    def retrieve_full_text(self, article):
        """Attempt to retrieve full text for an article"""
        logger.info(f"Attempting to retrieve full text for: {article.title}")

        # Simulated implementation - would be replaced with real retrieval logic
        try:
            # For demonstration purposes
            article.full_text = (
                f"INTRODUCTION\n\n"
                f"This paper explores {article.title.lower()}. "
                f"Our research was motivated by the need to understand this topic better.\n\n"
                f"METHODOLOGY\n\n"
                f"We conducted a study using qualitative and quantitative methods.\n\n"
                f"RESULTS\n\n"
                f"Our findings indicate significant correlations between variables.\n\n"
                f"DISCUSSION\n\n"
                f"These results suggest important implications for the field.\n\n"
                f"CONCLUSION\n\n"
                f"In conclusion, we have demonstrated that our approach provides "
                f"valuable insights into {article.title.lower()}. Future research "
                f"should focus on expanding these findings."
            )

            # Extract conclusion
            article.extract_conclusion()

            return True
        except Exception as e:
            logger.error(f"Error retrieving full text: {e}")
            return False

    def parse_pdf(self, file_path):
        """Parse a PDF file to extract text and metadata"""
        try:
            with open(file_path, 'rb') as file:
                reader = PdfReader(file)

                # Extract text from all pages
                text = ""
                for page in reader.pages:
                    text += page.extract_text() + "\n"

                # Extract metadata
                metadata = reader.metadata

                return {
                    "text": text,
                    "metadata": metadata
                }
        except Exception as e:
            logger.error(f"Error parsing PDF: {e}")
            return None
