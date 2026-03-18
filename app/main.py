# This Python file uses the following encoding: utf-8
import os
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtQml import QQmlApplicationEngine

from app.config import ConfigManager
from app.ai import ChatGPTService
from app.retrieval import ArticleRetriever
from app.writing import DocumentExporter
from app.controllers import ProjectController, SettingsController

def main():
    # Use a non-native style so custom backgrounds are supported.
    QQuickStyle.setStyle("Basic")
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
    ui_dir = Path(__file__).resolve().parent.parent / "ui"
    engine.addImportPath(os.fspath(ui_dir))
    qml_path = os.fspath(ui_dir / "main.qml")
    engine.load(qml_path)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
