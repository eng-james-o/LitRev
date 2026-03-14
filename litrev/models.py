import json
import re
from datetime import datetime
import logging
from .config import logger

class Article:
    def __init__(self, title="", authors=None, journal="", year="", doi="", abstract="",
                 conclusion="", full_text="", url="", source_db=""):
        self.title = title
        self.authors = authors or []
        self.journal = journal
        self.year = year
        self.doi = doi
        self.abstract = abstract
        self.conclusion = conclusion
        self.full_text = full_text
        self.url = url
        self.source_db = source_db
        self.selected = False
        self.notes = ""
        self.local_file_path = ""

    def to_dict(self):
        return {
            "title": self.title,
            "authors": self.authors,
            "journal": self.journal,
            "year": self.year,
            "doi": self.doi,
            "abstract": self.abstract,
            "conclusion": self.conclusion,
            "full_text": self.full_text,
            "url": self.url,
            "source_db": self.source_db,
            "selected": self.selected,
            "notes": self.notes,
            "local_file_path": self.local_file_path
        }

    @classmethod
    def from_dict(cls, data):
        article = cls()
        for key, value in data.items():
            setattr(article, key, value)
        return article

    def extract_conclusion(self):
        """Attempt to extract conclusion from full text if available"""
        if not self.full_text:
            return

        # Simple pattern matching for conclusion section
        patterns = [
            r'(?i)conclusion[s]?\s*(.*?)(?:\n\s*[A-Z][a-z]+|\Z)',
            r'(?i)discussion and conclusion[s]?\s*(.*?)(?:\n\s*[A-Z][a-z]+|\Z)',
            r'(?i)summary\s*(.*?)(?:\n\s*[A-Z][a-z]+|\Z)'
        ]

        for pattern in patterns:
            match = re.search(pattern, self.full_text, re.DOTALL)
            if match:
                self.conclusion = match.group(1).strip()
                return

class Project:
    def __init__(self, name="", path=""):
        self.name = name
        self.path = path
        self.research_questions = []
        self.search_queries = []
        self.selected_databases = []
        self.articles = []
        self.selected_articles = []
        self.review_methodology = ""
        self.review_content = ""
        self.date_created = datetime.now().isoformat()
        self.date_modified = self.date_created

    def to_dict(self):
        return {
            "name": self.name,
            "path": self.path,
            "research_questions": self.research_questions,
            "search_queries": self.search_queries,
            "selected_databases": self.selected_databases,
            "articles": [article.to_dict() for article in self.articles],
            "selected_articles": [article.to_dict() for article in self.selected_articles],
            "review_methodology": self.review_methodology,
            "review_content": self.review_content,
            "date_created": self.date_created,
            "date_modified": datetime.now().isoformat()
        }

    @classmethod
    def from_dict(cls, data):
        project = cls(name=data.get("name", ""), path=data.get("path", ""))
        project.research_questions = data.get("research_questions", [])
        project.search_queries = data.get("search_queries", [])
        project.selected_databases = data.get("selected_databases", [])
        project.articles = [Article.from_dict(article_data) for article_data in data.get("articles", [])]
        project.selected_articles = [Article.from_dict(article_data) for article_data in data.get("selected_articles", [])]
        project.review_methodology = data.get("review_methodology", "")
        project.review_content = data.get("review_content", "")
        project.date_created = data.get("date_created", datetime.now().isoformat())
        project.date_modified = data.get("date_modified", datetime.now().isoformat())
        return project

    def save(self):
        """Save project to its file path"""
        if not self.path:
            raise ValueError("Project path not set")

        self.date_modified = datetime.now().isoformat()

        try:
            with open(self.path, 'w') as f:
                json.dump(self.to_dict(), f, indent=2)
        except Exception as e:
            logger.error(f"Error saving project: {e}")
            raise

    @classmethod
    def load(cls, path):
        """Load project from file path"""
        try:
            with open(path, 'r') as f:
                data = json.load(f)
            return cls.from_dict(data)
        except Exception as e:
            logger.error(f"Error loading project: {e}")
            raise
