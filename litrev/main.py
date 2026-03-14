# This Python file uses the following encoding: utf-8
import os
import sys
from pathlib import Path

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine

from litrev.config import ConfigManager
from litrev.ai import ChatGPTService
from litrev.retrieval import ArticleRetriever
from litrev.writing import DocumentExporter
from litrev.controllers import ProjectController, SettingsController

def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Initialize core services
    config_manager = ConfigManager()
    chatgpt_service = ChatGPTService(config_manager)
    article_retriever = ArticleRetriever(config_manager)
    doc_exporter = DocumentExporter()

    # Initialize controllers
    project_controller = ProjectController(
        config_manager,
        chatgpt_service,
        article_retriever,
        doc_exporter
    )
    settings_controller = SettingsController(config_manager, chatgpt_service)

    # Register controllers with QML context
    context = engine.rootContext()
    context.setContextProperty("projectController", project_controller)
    context.setContextProperty("settingsController", settings_controller)

    # Load QML
    qml_path = os.fspath(Path(__file__).resolve().parent.parent / "ui" / "main.qml")
    engine.load(qml_path)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
