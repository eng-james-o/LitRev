import pytest
import json
from unittest.mock import MagicMock, patch
from app.ai import SynthesisManager, ChatGPTService
from app.models import Article

@pytest.fixture
def mock_chatgpt_service():
    service = MagicMock(spec=ChatGPTService)
    # Mock parse_json to return the input if it's already a dict or list (simplified)
    service.parse_json.side_effect = lambda x: json.loads(x) if isinstance(x, str) else x
    return service

@pytest.fixture
def synthesis_manager(mock_chatgpt_service):
    return SynthesisManager(mock_chatgpt_service)

@pytest.fixture
def sample_articles():
    return [
        Article(title="Paper 1", abstract="Abstract 1", authors=["Author 1"], year="2021"),
        Article(title="Paper 2", abstract="Abstract 2", authors=["Author 2"], year="2022")
    ]

def test_map_articles(synthesis_manager, mock_chatgpt_service, sample_articles):
    mock_chatgpt_service.call_gpt.return_value = '{"Key Findings": "Finding 1"}'

    snippets = synthesis_manager._map_articles(sample_articles)

    assert len(snippets) == 2
    assert snippets[0]['title'] == "Paper 1"
    assert snippets[0]['Key Findings'] == "Finding 1"
    assert mock_chatgpt_service.call_gpt.call_count == 2

def test_identify_themes(synthesis_manager, mock_chatgpt_service):
    mock_chatgpt_service.call_gpt.return_value = '["Theme 1", "Theme 2"]'
    snippets = [{"title": "P1", "Key Findings": "F1"}]

    themes = synthesis_manager._identify_themes("Questions", snippets)

    assert themes == ["Theme 1", "Theme 2"]
    mock_chatgpt_service.call_gpt.assert_called_once()

def test_cluster_snippets(synthesis_manager, mock_chatgpt_service):
    mock_chatgpt_service.call_gpt.return_value = '{"Theme 1": ["Paper 1"]}'
    snippets = [{"title": "Paper 1"}]
    themes = ["Theme 1"]

    clusters = synthesis_manager._cluster_snippets(snippets, themes)

    assert clusters == {"Theme 1": ["Paper 1"]}

def test_run_pipeline(synthesis_manager, mock_chatgpt_service, sample_articles):
    # Setup mocks for each stage
    mock_chatgpt_service.call_gpt.side_effect = [
        '{"Key Findings": "F1"}', # Map P1
        '{"Key Findings": "F2"}', # Map P2
        '["Theme 1"]',             # Identify Themes
        '{"Theme 1": ["Paper 1", "Paper 2"]}', # Cluster
        'Section Text',            # Synthesize Theme 1
        'Final Review'             # Integrate
    ]

    result = synthesis_manager.run_pipeline("Questions", sample_articles, "Systematic")

    assert result == 'Final Review'
    assert mock_chatgpt_service.call_gpt.call_count == 6
