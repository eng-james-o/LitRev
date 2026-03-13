import os
import json
import logging

# Configure logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    filename='autolitreview.log')
logger = logging.getLogger(__name__)

# Configuration settings
CONFIG_FILE = "config.json"

DEFAULT_CONFIG = {
    "api_key": "",
    "model": "gpt-4o",
    "max_tokens": 4000,
    "temperature": 0.7,
    "publication_databases": [
        {"name": "arXiv", "enabled": True, "url": "https://arxiv.org/search/"},
        {"name": "PubMed", "enabled": True, "url": "https://pubmed.ncbi.nlm.nih.gov/"},
        {"name": "IEEE Xplore", "enabled": True, "url": "https://ieeexplore.ieee.org/search/"},
        {"name": "ACM Digital Library", "enabled": True, "url": "https://dl.acm.org/action/doSearch"},
        {"name": "ScienceDirect", "enabled": True, "url": "https://www.sciencedirect.com/search"}
    ],
    "review_methodologies": [
        "Systematic Review",
        "Meta-analysis",
        "Narrative Review",
        "Scoping Review",
        "Integrative Review"
    ],
    "recent_projects": []
}

class ConfigManager:
    def __init__(self):
        self.config = self.load_config()

    def load_config(self):
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Error loading config: {e}")
                return DEFAULT_CONFIG.copy()
        else:
            return DEFAULT_CONFIG.copy()

    def save_config(self):
        try:
            with open(CONFIG_FILE, 'w') as f:
                json.dump(self.config, f, indent=2)
        except Exception as e:
            logger.error(f"Error saving config: {e}")

    def get_api_key(self):
        return self.config.get("api_key", "")

    def set_api_key(self, api_key):
        self.config["api_key"] = api_key
        self.save_config()

    def add_recent_project(self, project_path):
        """Add a project to recent projects list"""
        recent = self.config.get("recent_projects", [])
        if project_path in recent:
            recent.remove(project_path)
        recent.insert(0, project_path)
        self.config["recent_projects"] = recent[:10]  # Keep only 10 most recent
        self.save_config()
