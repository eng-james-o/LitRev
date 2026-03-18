import requests
import urllib.parse
import xml.etree.ElementTree as ET
import re
from PyPDF2 import PdfReader
import logging
from .config import logger
from .models import Article

class ArticleRetriever:
    """Handles searching for and retrieving articles from academic databases"""

    def __init__(self, config_manager):
        self.config_manager = config_manager

    def search_articles(self, query, databases):
        """Search for articles using the given query across specified databases"""
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

    def _search_arxiv(self, query):
        """Real implementation for searching arXiv"""
        logger.info(f"Searching arXiv for: {query}")
        results = []
        try:
            encoded_query = urllib.parse.quote(query)
            url = f"https://export.arxiv.org/api/query?search_query=all:{encoded_query}&start=0&max_results=10"
            response = requests.get(url)
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
        except Exception as e:
            logger.error(f"Error searching arXiv: {e}")

        return results
    def _search_pubmed(self, query):
        """Real implementation for searching PubMed using NCBI E-utilities"""
        logger.info(f"Searching PubMed for: {query}")
        results = []
        try:
            # Step 1: Search for IDs
            encoded_query = urllib.parse.quote(query)
            search_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term={encoded_query}&retmode=json&retmax=10"
            search_response = requests.get(search_url)
            if search_response.status_code != 200:
                return []

            search_data = search_response.json()
            id_list = search_data.get('esearchresult', {}).get('idlist', [])

            if not id_list:
                return []

            # Step 2: Fetch details for those IDs
            ids = ",".join(id_list)
            summary_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id={ids}&retmode=json"
            summary_response = requests.get(summary_url)
            if summary_response.status_code != 200:
                return []

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

        except Exception as e:
            logger.error(f"Error searching PubMed: {e}")

        return results
    def retrieve_full_text(self, article):
        """Attempt to retrieve full text for an article

        In a real implementation, this would:
        1. Check for open access versions
        2. Use institutional access if available
        3. Handle authentication for subscription services
        4. Parse PDF/HTML to extract text
        """
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
