import unittest
from unittest.mock import MagicMock, patch
from app.retrieval import ArticleRetriever
from app.models import Article
import urllib.parse

class TestArticleRetriever(unittest.TestCase):
    def setUp(self):
        self.config_manager = MagicMock()
        self.retriever = ArticleRetriever(self.config_manager)

    @patch('requests.get')
    def test_search_arxiv(self, mock_get):
        # Mock ArXiv XML response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.content = b'''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <id>http://arxiv.org/abs/2101.00001v1</id>
    <published>2021-01-01T00:00:00Z</published>
    <title>Test ArXiv Article</title>
    <summary>This is a test summary.</summary>
    <author><name>Test Author</name></author>
  </entry>
</feed>'''
        mock_get.return_value = mock_response

        query = "test & query"
        results = self.retriever._search_arxiv(query)

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0].title, "Test ArXiv Article")

        # Verify URL encoding
        args, kwargs = mock_get.call_args
        url = args[0]
        self.assertIn(urllib.parse.quote(query), url)
        self.assertTrue(url.startswith("https://"))

    @patch('requests.get')
    def test_search_pubmed(self, mock_get):
        # Mock PubMed JSON responses
        mock_search_response = MagicMock()
        mock_search_response.status_code = 200
        mock_search_response.json.return_value = {
            'esearchresult': {'idlist': ['12345']}
        }

        mock_summary_response = MagicMock()
        mock_summary_response.status_code = 200
        mock_summary_response.json.return_value = {
            'result': {
                '12345': {
                    'title': 'Test PubMed Article',
                    'authors': [{'name': 'Test Author'}],
                    'source': 'Test Journal',
                    'pubdate': '2022 Jan 01',
                    'articleids': [{'idtype': 'doi', 'value': '10.1234/test'}]
                }
            }
        }

        mock_get.side_effect = [mock_search_response, mock_summary_response]

        query = "test & query"
        results = self.retriever._search_pubmed(query)

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0].title, "Test PubMed Article")

        # Verify URL encoding (first call is esearch)
        args, kwargs = mock_get.call_args_list[0]
        url = args[0]
        self.assertIn(urllib.parse.quote(query), url)

    @patch('app.retrieval.ArticleRetriever._search_arxiv')
    @patch('app.retrieval.ArticleRetriever._search_pubmed')
    def test_search_articles_aggregation(self, mock_pubmed, mock_arxiv):
        mock_arxiv.return_value = [Article(title="ArXiv Result")]
        mock_pubmed.return_value = [Article(title="PubMed Result")]

        results = self.retriever.search_articles("query", ["arXiv", "PubMed"])

        self.assertEqual(len(results), 2)
        titles = [r.title for r in results]
        self.assertIn("ArXiv Result", titles)
        self.assertIn("PubMed Result", titles)

if __name__ == '__main__':
    unittest.main()
