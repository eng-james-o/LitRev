import json
import re
import openai
import logging
from .config import logger

class ChatGPTService:
    def __init__(self, config_manager):
        self.config_manager = config_manager
        self.api_key = config_manager.get_api_key()
        self.setup_client()

    def setup_client(self):
        if self.api_key:
            openai.api_key = self.api_key
        else:
            logger.warning("OpenAI API key not set")

    def update_api_key(self, api_key):
        self.api_key = api_key
        self.config_manager.set_api_key(api_key)
        self.setup_client()

    def generate_search_queries(self, research_questions):
        """Generate search queries from research questions using ChatGPT"""
        if not self.api_key:
            raise ValueError("API key not set")

        prompt = f"""
        I'm conducting a literature review with the following research questions:

        {research_questions}

        Please generate 3-5 effective search queries for academic databases that would help me find relevant literature.
        Format each query as a set of terms with appropriate Boolean operators (AND, OR, NOT).
        For each query, provide a brief explanation of what aspect of my research it targets.
        Format your response as a JSON list of objects, each with 'query' and 'explanation' fields.
        """

        try:
            response = openai.ChatCompletion.create(
                model=self.config_manager.config.get("model", "gpt-4o"),
                messages=[{"role": "user", "content": prompt}],
                temperature=self.config_manager.config.get("temperature", 0.7),
                max_tokens=self.config_manager.config.get("max_tokens", 4000)
            )

            content = response.choices[0].message.content
            # Extract JSON from the response
            json_match = re.search(r'```json\s*(.*?)\s*```', content, re.DOTALL)
            if json_match:
                content = json_match.group(1)

            try:
                return json.loads(content)
            except:
                # If parsing fails, try to extract a JSON array
                json_array_match = re.search(r'\[\s*{.*}\s*\]', content, re.DOTALL)
                if json_array_match:
                    return json.loads(json_array_match.group(0))
                else:
                    logger.error(f"Failed to parse ChatGPT response as JSON: {content}")
                    return []

        except Exception as e:
            logger.error(f"Error generating search queries: {e}")
            raise

    def suggest_publication_databases(self, research_questions, search_queries):
        """Suggest relevant publication databases based on research questions and search queries"""
        if not self.api_key:
            raise ValueError("API key not set")

        all_databases = self.config_manager.config.get("publication_databases", [])
        db_names = [db["name"] for db in all_databases]

        prompt = f"""
        I'm conducting a literature review with the following research questions:

        {research_questions}

        And these search queries:

        {search_queries}

        From this list of academic databases:
        {", ".join(db_names)}

        Please recommend which ones would be most relevant for my research, and explain why.
        Format your response as a JSON list of objects, each with 'database' and 'reason' fields.
        Only include databases from the list provided.
        """

        try:
            response = openai.ChatCompletion.create(
                model=self.config_manager.config.get("model", "gpt-4o"),
                messages=[{"role": "user", "content": prompt}],
                temperature=self.config_manager.config.get("temperature", 0.7),
                max_tokens=self.config_manager.config.get("max_tokens", 4000)
            )

            content = response.choices[0].message.content
            # Extract JSON from the response
            json_match = re.search(r'```json\s*(.*?)\s*```', content, re.DOTALL)
            if json_match:
                content = json_match.group(1)

            try:
                results = json.loads(content)
                # Filter to ensure only valid databases are included
                return [item for item in results if item.get("database") in db_names]
            except:
                logger.error(f"Failed to parse ChatGPT response as JSON: {content}")
                return []

        except Exception as e:
            logger.error(f"Error suggesting databases: {e}")
            raise

    def generate_literature_review(self, research_questions, articles, methodology):
        """Generate a literature review based on selected articles and methodology"""
        if not self.api_key:
            raise ValueError("API key not set")

        # Prepare article data
        article_data = []
        for article in articles:
            article_info = {
                "title": article.title,
                "authors": article.authors,
                "journal": article.journal,
                "year": article.year,
                "abstract": article.abstract,
                "conclusion": article.conclusion
            }
            article_data.append(article_info)

        prompt = f"""
        I'm writing a {methodology} literature review addressing these research questions:

        {research_questions}

        Here are the selected articles for review:

        {json.dumps(article_data, indent=2)}

        Please generate a comprehensive literature review following the {methodology} approach.

        Include:
        1. Introduction with research questions
        2. Methodology section explaining the review process
        3. Thematic analysis of the literature
        4. Discussion of findings in relation to research questions
        5. Gaps in the literature and suggestions for future research
        6. Conclusion
        7. Suggestions for where figures should be included (marked as [FIGURE: Description of suggested figure])

        Format the review with appropriate headings and subheadings.
        """

        try:
            response = openai.ChatCompletion.create(
                model=self.config_manager.config.get("model", "gpt-4o"),
                messages=[{"role": "user", "content": prompt}],
                temperature=self.config_manager.config.get("temperature", 0.7),
                max_tokens=self.config_manager.config.get("max_tokens", 8000)
            )

            return response.choices[0].message.content

        except Exception as e:
            logger.error(f"Error generating literature review: {e}")
            raise

    def expand_review_section(self, review_content, section_title, section_content):
        """Expand a specific section of the literature review"""
        if not self.api_key:
            raise ValueError("API key not set")

        prompt = f"""
        I have a literature review with the following section that needs expansion:

        # {section_title}
        {section_content}

        Please provide a more detailed and comprehensive version of this section,
        maintaining the same overall structure but adding more depth, analysis, and connections
        between the ideas presented. Keep the same academic tone and style.
        """

        try:
            response = openai.ChatCompletion.create(
                model=self.config_manager.config.get("model", "gpt-4o"),
                messages=[{"role": "user", "content": prompt}],
                temperature=self.config_manager.config.get("temperature", 0.7),
                max_tokens=self.config_manager.config.get("max_tokens", 4000)
            )

            return response.choices[0].message.content

        except Exception as e:
            logger.error(f"Error expanding review section: {e}")
            raise
