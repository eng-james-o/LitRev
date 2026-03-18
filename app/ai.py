import json
import re
import openai
import logging
from .config import logger

class SynthesisManager:
    """Manages the Map-Reduce literature review synthesis pipeline"""
    def __init__(self, chatgpt_service):
        self.chatgpt_service = chatgpt_service

    def run_pipeline(self, research_questions, articles, methodology):
        """Execute the full Map-Reduce synthesis pipeline"""
        logger.info(f"Starting Map-Reduce synthesis pipeline for {len(articles)} articles")

        # Step A: Map Phase (Extract Structured Evidence Snippets)
        snippets = self._map_articles(articles)

        # Step B: Thematic Clustering
        themes = self._identify_themes(research_questions, snippets)
        clustered_snippets = self._cluster_snippets(snippets, themes)

        # Step C: Reduce Phase (Sectional Synthesis)
        sectional_syntheses = self._synthesize_sections(themes, clustered_snippets, methodology, snippets)

        # Step D: Global Integration
        final_review = self._integrate_review(research_questions, sectional_syntheses, methodology, snippets)

        return final_review

    def _map_articles(self, articles):
        """Step A: Process each article to extract structured evidence snippets"""
        snippets = []
        # Process in small batches or individually
        for article in articles:
            prompt = f"""
            Extract a 'Structured Evidence Snippet' for the following article:
            Title: {article.title}
            Abstract: {article.abstract}
            Conclusion: {article.conclusion}

            Format the output as a JSON object with these fields:
            - Key Findings
            - Methodology
            - Sample Size (if applicable)
            - Theoretical Framework
            - Gaps Identified
            - Relevance to Research (High/Medium/Low)
            """

            try:
                content = self.chatgpt_service.call_gpt(prompt)
                snippet = self.chatgpt_service.parse_json(content)
                if not isinstance(snippet, dict):
                    snippet = {"Key Findings": content}
                snippet['title'] = article.title
                snippet['authors'] = article.authors
                snippet['year'] = article.year
                snippets.append(snippet)
            except Exception as e:
                logger.error(f"Error mapping article {article.title}: {e}")

        return snippets

    def _identify_themes(self, research_questions, snippets):
        """Step B1: Identify core themes across the snippets"""
        snippets_summary = "\n".join([f"- {s.get('title')}: {s.get('Key Findings')}" for s in snippets])

        prompt = f"""
        Based on these evidence snippets from various research papers:
        {snippets_summary}

        And considering these research questions:
        {research_questions}

        Identify 3-5 core themes that emerge across the literature.
        Format the response as a JSON list of theme titles.
        """

        try:
            content = self.chatgpt_service.call_gpt(prompt)
            themes = self.chatgpt_service.parse_json(content)
            if not isinstance(themes, list):
                themes = [themes] if themes else ["General Findings"]
            return themes
        except Exception as e:
            logger.error(f"Error identifying themes: {e}")
            return ["General Findings"]

    def _cluster_snippets(self, snippets, themes):
        """Step B2: Categorize each snippet into identified themes"""
        prompt = f"""
        Categorize the following evidence snippets into these themes: {", ".join(themes)}

        Snippets:
        {json.dumps(snippets, indent=2)}

        Format the response as a JSON object where keys are theme names and values are lists of paper titles belonging to that theme.
        """

        try:
            content = self.chatgpt_service.call_gpt(prompt)
            clusters = self.chatgpt_service.parse_json(content)
            if not isinstance(clusters, dict):
                return {themes[0]: [s.get('title') for s in snippets]}
            return clusters
        except Exception as e:
            logger.error(f"Error clustering snippets: {e}")
            return {themes[0]: [s.get('title') for s in snippets]}

    def _synthesize_sections(self, themes, clustered_snippets, methodology, snippets):
        """Step C: Draft narrative synthesis for each theme"""
        sectional_syntheses = {}

        snippet_map = {s.get('title'): s for s in snippets}

        for theme in themes:
            titles = clustered_snippets.get(theme, [])
            if not titles:
                continue

            # Pass snippets related to this theme
            theme_snippets = [snippet_map.get(title) for title in titles if title in snippet_map]

            prompt = f"""
            Write a narrative synthesis for the theme: "{theme}"
            Use a {methodology} approach.
            Compare and contrast the findings from the following papers:
            {json.dumps(theme_snippets, indent=2)}

            Ensure deep analysis and logical connections.
            """

            try:
                sectional_syntheses[theme] = self.chatgpt_service.call_gpt(prompt)
            except Exception as e:
                logger.error(f"Error synthesizing section for theme {theme}: {e}")

        return sectional_syntheses

    def _integrate_review(self, research_questions, sectional_syntheses, methodology, snippets):
        """Step D: Final assembly of the review"""
        sections_text = "\n\n".join([f"## {theme}\n{text}" for theme, text in sectional_syntheses.items()])

        prompt = f"""
        Assemble a complete {methodology} literature review.

        Research Questions:
        {research_questions}

        Synthesized Sections:
        {sections_text}

        Please write:
        1. Introduction (including research questions)
        2. Methodology section (explaining the search and synthesis process)
        3. [The Synthesized Sections already provided will be inserted here]
        4. Gaps in Literature and Future Research
        5. Conclusion

        Format with appropriate headings. Integrate the provided sections naturally.
        """

        try:
            return self.chatgpt_service.call_gpt(prompt, max_tokens=8000)
        except Exception as e:
            logger.error(f"Error integrating final review: {e}")
            return sections_text

class ChatGPTService:
    def __init__(self, config_manager):
        self.config_manager = config_manager
        self.api_key = config_manager.get_api_key()
        self.setup_client()
        self.synthesis_manager = SynthesisManager(self)

    def setup_client(self):
        if self.api_key:
            openai.api_key = self.api_key
        else:
            logger.warning("OpenAI API key not set")

    def update_api_key(self, api_key):
        self.api_key = api_key
        self.config_manager.set_api_key(api_key)
        self.setup_client()

    def call_gpt(self, prompt, model=None, temperature=None, max_tokens=None):
        """Generic helper to call ChatGPT"""
        if not self.api_key:
            raise ValueError("API key not set")

        try:
            response = openai.ChatCompletion.create(
                model=model or self.config_manager.config.get("model", "gpt-4o"),
                messages=[{"role": "user", "content": prompt}],
                temperature=temperature or self.config_manager.config.get("temperature", 0.7),
                max_tokens=max_tokens or self.config_manager.config.get("max_tokens", 4000)
            )
            return response.choices[0].message.content
        except Exception as e:
            logger.error(f"OpenAI API error: {e}")
            raise

    def parse_json(self, content):
        """Helper to parse JSON from GPT response"""
        # Extract JSON from the response
        json_match = re.search(r'```json\s*(.*?)\s*```', content, re.DOTALL)
        if json_match:
            content = json_match.group(1)

        try:
            return json.loads(content)
        except:
            # If parsing fails, try to extract a JSON array or object
            json_array_match = re.search(r'\[\s*{.*}\s*\]|\{\s*".*"\s*:.*\}', content, re.DOTALL)
            if json_array_match:
                try:
                    return json.loads(json_array_match.group(0))
                except:
                    pass

            logger.error(f"Failed to parse ChatGPT response as JSON: {content}")
            return {}

    def generate_search_queries(self, research_questions):
        """Generate search queries from research questions using ChatGPT"""
        prompt = f"""
        I'm conducting a literature review with the following research questions:

        {research_questions}

        Please generate 3-5 effective search queries for academic databases that would help me find relevant literature.
        Format each query as a set of terms with appropriate Boolean operators (AND, OR, NOT).
        For each query, provide a brief explanation of what aspect of my research it targets.
        Format your response as a JSON list of objects, each with 'query' and 'explanation' fields.
        """

        content = self.call_gpt(prompt)
        return self.parse_json(content)

    def suggest_publication_databases(self, research_questions, search_queries):
        """Suggest relevant publication databases based on research questions and search queries"""
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

        content = self.call_gpt(prompt)
        results = self.parse_json(content)
        # Filter to ensure only valid databases are included
        if isinstance(results, list):
            return [item for item in results if isinstance(item, dict) and item.get("database") in db_names]
        return []

    def generate_literature_review(self, research_questions, articles, methodology):
        """Generate a literature review using the Map-Reduce pipeline"""
        if not self.api_key:
            raise ValueError("API key not set")

        return self.synthesis_manager.run_pipeline(research_questions, articles, methodology)

    def expand_review_section(self, review_content, section_title, section_content):
        """Expand a specific section of the literature review"""
        prompt = f"""
        I have a literature review with the following section that needs expansion:

        # {section_title}
        {section_content}

        Please provide a more detailed and comprehensive version of this section,
        maintaining the same overall structure but adding more depth, analysis, and connections
        between the ideas presented. Keep the same academic tone and style.
        """

        return self.call_gpt(prompt)
