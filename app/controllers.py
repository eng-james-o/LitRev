import json
import logging
from PySide6.QtCore import QObject, Signal, Slot, Property
from .models import Project, Article
from .config import logger

class ProjectController(QObject):
    projectLoaded = Signal()
    projectSaved = Signal()
    researchQuestionsChanged = Signal()
    searchQueriesChanged = Signal()
    articlesChanged = Signal()
    reviewContentChanged = Signal()
    errorOccurred = Signal(str)

    def __init__(self, config_manager, chatgpt_service, article_retriever, doc_exporter):
        super().__init__()
        self.config_manager = config_manager
        self.chatgpt_service = chatgpt_service
        self.article_retriever = article_retriever
        self.doc_exporter = doc_exporter
        self.current_project = Project()
        self._is_loading = False

    @Slot(str, str)
    def createProject(self, name, path):
        try:
            self.current_project = Project(name, path)
            self.current_project.save()
            self.config_manager.add_recent_project(path)
            self.projectLoaded.emit()
        except Exception as e:
            logger.error(f"Error creating project: {e}")
            self.errorOccurred.emit(f"Failed to create project: {str(e)}")

    @Slot(str)
    def loadProject(self, path):
        try:
            self._is_loading = True
            self.current_project = Project.load(path)
            self.config_manager.add_recent_project(path)
            self._is_loading = False
            self.projectLoaded.emit()
        except Exception as e:
            self._is_loading = False
            logger.error(f"Error loading project: {e}")
            self.errorOccurred.emit(f"Failed to load project: {str(e)}")

    @Slot()
    def saveProject(self):
        try:
            self.current_project.save()
            self.projectSaved.emit()
        except Exception as e:
            logger.error(f"Error saving project: {e}")
            self.errorOccurred.emit(f"Failed to save project: {str(e)}")

    @Slot(str)
    def addResearchQuestion(self, question):
        self.current_project.research_questions.append(question)
        self.saveProject()
        self.researchQuestionsChanged.emit()

    @Slot(int)
    def removeResearchQuestion(self, index):
        if 0 <= index < len(self.current_project.research_questions):
            del self.current_project.research_questions[index]
            self.saveProject()
            self.researchQuestionsChanged.emit()

    @Slot(result=str)
    def getResearchQuestionsJson(self):
        return json.dumps(self.current_project.research_questions)

    @Slot()
    def generateSearchQueries(self):
        try:
            questions = "\n".join(self.current_project.research_questions)
            queries = self.chatgpt_service.generate_search_queries(questions)
            self.current_project.search_queries = queries
            self.saveProject()
            self.searchQueriesChanged.emit()
        except Exception as e:
            logger.error(f"Error generating search queries: {e}")
            self.errorOccurred.emit(f"Failed to generate search queries: {str(e)}")

    @Slot(str)
    def addSearchQuery(self, query_json):
        try:
            query = json.loads(query_json)
            self.current_project.search_queries.append(query)
            self.saveProject()
            self.searchQueriesChanged.emit()
        except Exception as e:
            logger.error(f"Error adding search query: {e}")
            self.errorOccurred.emit(f"Failed to add search query: {str(e)}")

    @Slot(int)
    def removeSearchQuery(self, index):
        if 0 <= index < len(self.current_project.search_queries):
            del self.current_project.search_queries[index]
            self.saveProject()
            self.searchQueriesChanged.emit()

    @Slot(result=str)
    def getSearchQueriesJson(self):
        return json.dumps(self.current_project.search_queries)

    @Slot()
    def suggestDatabases(self):
        try:
            questions = "\n".join(self.current_project.research_questions)
            queries = json.dumps(self.current_project.search_queries)
            suggested_dbs = self.chatgpt_service.suggest_publication_databases(questions, queries)

            # Update selected databases
            self.current_project.selected_databases = [db.get("database") for db in suggested_dbs]
            self.saveProject()
            return json.dumps(suggested_dbs)
        except Exception as e:
            logger.error(f"Error suggesting databases: {e}")
            self.errorOccurred.emit(f"Failed to suggest databases: {str(e)}")
            return "[]"

    @Slot(str, bool)
    def setDatabaseSelected(self, database, selected):
        if selected and database not in self.current_project.selected_databases:
            self.current_project.selected_databases.append(database)
        elif not selected and database in self.current_project.selected_databases:
            self.current_project.selected_databases.remove(database)
        self.saveProject()

    @Slot(result=str)
    def getSelectedDatabasesJson(self):
        return json.dumps(self.current_project.selected_databases)

    @Slot(str)
    def searchArticles(self, query_index):
        try:
            index = int(query_index)
            if 0 <= index < len(self.current_project.search_queries):
                query = self.current_project.search_queries[index]["query"]
                results = self.article_retriever.search_articles(query, self.current_project.selected_databases)

                # Add new articles to the project with robust deduplication
                for article in results:
                    exists = False
                    for existing in self.current_project.articles:
                        # Primary deduplication by DOI
                        if article.doi and existing.doi and article.doi.lower() == existing.doi.lower():
                            exists = True
                            break
                        # Secondary deduplication by Title (fuzzy match would be better, but simple equality for now)
                        if article.title.lower().strip() == existing.title.lower().strip():
                            exists = True
                            break
                    if not exists:
                        self.current_project.articles.append(article)

                self.saveProject()
                self.articlesChanged.emit()
        except Exception as e:
            logger.error(f"Error searching articles: {e}")
            self.errorOccurred.emit(f"Failed to search articles: {str(e)}")

    @Slot(result=str)
    def getArticlesJson(self):
        return json.dumps([article.to_dict() for article in self.current_project.articles])

    @Slot(int, bool)
    def setArticleSelected(self, index, selected):
        if 0 <= index < len(self.current_project.articles):
            self.current_project.articles[index].selected = selected
            article = self.current_project.articles[index]

            # Use DOI/Title for membership check in selected_articles
            in_selected = False
            for i, sel in enumerate(self.current_project.selected_articles):
                if (article.doi and sel.doi and article.doi.lower() == sel.doi.lower()) or \
                   (article.title.lower().strip() == sel.title.lower().strip()):
                    in_selected = True
                    if not selected:
                        del self.current_project.selected_articles[i]
                    break

            if selected and not in_selected:
                self.current_project.selected_articles.append(article)

            self.saveProject()

    @Slot(int)
    def retrieveFullText(self, index):
        if 0 <= index < len(self.current_project.articles):
            article = self.current_project.articles[index]
            success = self.article_retriever.retrieve_full_text(article)
            if success:
                self.saveProject()
                self.articlesChanged.emit()

    @Slot(str)
    def setReviewMethodology(self, methodology):
        self.current_project.review_methodology = methodology
        self.saveProject()

    @Slot()
    def generateReview(self):
        try:
            questions = "\n".join(self.current_project.research_questions)
            review_content = self.chatgpt_service.generate_literature_review(
                questions,
                self.current_project.selected_articles,
                self.current_project.review_methodology
            )
            self.current_project.review_content = review_content
            self.saveProject()
            self.reviewContentChanged.emit()
        except Exception as e:
            logger.error(f"Error generating review: {e}")
            self.errorOccurred.emit(f"Failed to generate review: {str(e)}")

    @Slot(str)
    def setReviewContent(self, content):
        self.current_project.review_content = content
        if not self._is_loading:
            self.saveProject()

    @Slot(result=str)
    def getReviewContent(self):
        return self.current_project.review_content

    @Slot(str, str)
    def exportReview(self, format_type, file_path):
        try:
            success = False
            if format_type == "docx":
                success = self.doc_exporter.export_docx(self.current_project.review_content, file_path)
            elif format_type == "txt":
                success = self.doc_exporter.export_text(self.current_project.review_content, file_path)
            elif format_type == "md":
                success = self.doc_exporter.export_markdown(self.current_project.review_content, file_path)

            if not success:
                self.errorOccurred.emit(f"Failed to export to {format_type}")
        except Exception as e:
            logger.error(f"Error exporting review: {e}")
            self.errorOccurred.emit(f"Failed to export review: {str(e)}")

    # Property getters for QML binding
    @Property(str, notify=projectLoaded)
    def projectName(self):
        return self.current_project.name

    @Property(str, notify=projectLoaded)
    def projectPath(self):
        return self.current_project.path

    @Property(str, notify=projectLoaded)
    def reviewMethodology(self):
        return self.current_project.review_methodology

class SettingsController(QObject):
    apiKeyChanged = Signal()
    configChanged = Signal()

    def __init__(self, config_manager, chatgpt_service):
        super().__init__()
        self.config_manager = config_manager
        self.chatgpt_service = chatgpt_service

    @Slot(str)
    def setApiKey(self, api_key):
        self.chatgpt_service.update_api_key(api_key)
        self.apiKeyChanged.emit()

    @Slot(result=str)
    def getApiKey(self):
        return self.config_manager.get_api_key()

    @Slot(result=str)
    def getRecentProjectsJson(self):
        return json.dumps(self.config_manager.config.get("recent_projects", []))

    @Slot(result=str)
    def getPublicationDatabasesJson(self):
        return json.dumps(self.config_manager.config.get("publication_databases", []))

    @Slot(result=str)
    def getReviewMethodologiesJson(self):
        return json.dumps(self.config_manager.config.get("review_methodologies", []))
