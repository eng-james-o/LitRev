from setuptools import setup, find_packages

setup(
    name="litrev",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "PySide2",
        "openai",
        "PyPDF2",
        "python-docx",
        "requests",
        "pandas",
        "langchain",
    ],
    entry_points={
        "console_scripts": [
            "litrev=litrev.main:main",
        ],
    },
)
