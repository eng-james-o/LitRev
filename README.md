
# AutoLitRev

**AutoLitRev** is an AI-powered software for automating and streamlining the literature review process using ChatGPT. It helps researchers generate high-quality reviews by assisting with search query formulation, article retrieval, content analysis, and structured report generation — all in one workflow.

---

## Key Features

- **Smart Query Generation**  
  Automatically generates precise and domain-specific search queries from your research question using advanced language models.

- **Corpus Selection and Management**  
  Suggests relevant publication sources (e.g., PubMed, ArXiv, CrossRef), with the ability to include or exclude sources manually.

- **Automated Article Retrieval**  
  Searches selected databases using generated queries and fetches metadata, abstracts, and full-text documents where accessible.

- **Screening and Selection**  
  Displays retrieved articles for manual review and filtering, helping you select only the most relevant works for your literature review.

- **Methodology-Based Review Generation**  
  Supports multiple research methodologies (e.g., systematic, scoping, narrative) to structure and generate well-formed literature reviews.

- **Integrated Document Editor**  
  Includes a built-in word processor with support for editing, adding figures, and receiving suggestions for improving flow and structure.

- **Multi-format Export**  
  Export your final literature review in `.docx`, `.pdf`, and other popular formats.

---

## Getting Started

### Installation

```bash
git clone https://github.com/eng-james-o/AutoLitRev.git
cd AutoLitRev
pip install -r requirements.txt
````

### Running the App

```bash
python app/main.py
```

---

## How It Works

1. **Input Research Question**
   Users begin by providing their research question.

2. **AI-Powered Query Generation**
   The system crafts optimized search queries using ChatGPT.

3. **Corpus Suggestion & Customization**
   AutoLitRev suggests appropriate journals and databases. Users can modify the corpus.

4. **Article Search & Retrieval**
   Articles are fetched from APIs (e.g., PubMed, ArXiv, CrossRef) with metadata, abstracts, and full texts where possible.

5. **Article Screening**
   An interface allows users to browse and select articles for the review.

6. **Structured Review Generation**
   The system assembles a coherent literature review using selected methodology.

7. **Editing & Exporting**
   Users can edit the review and export it to their desired format.

---

## Project Structure (Planned)

```text
AutoLitRev/
├── app/               # Core modules: AI, retrieval, writing
├── assets/               # SVG, Png, jpg assets
├── ui/                   # Graphical interface 
├── tests/                # Unit and integration tests
├── data/                 # Temporary data, cached articles
├── examples/             # Usage demos and workflows
├── docs/                 # Developer & user documentation
├── requirements.txt
├── README.md
└── setup.py
```

---

## Tech Stack

- Python 3.10+
- OpenAI GPT (via API)
- Requests, Pandas, Langchain
- `python-docx` or similar for document generation
- PySide6 QML for GUI

---

## Use Cases

- Academic researchers preparing literature reviews for publications
- Graduate students writing theses or dissertations
- Policy analysts compiling evidence-based reports
- R\&D professionals exploring existing knowledge on technical topics

---

## Roadmap

- [x] Initial CLI prototype
- [ ] Implement multi-source article retrieval
- [ ] Build screening interface
- [ ] Integrate review generation engine
- [ ] Add editor and export options
- [ ] GUI for end-to-end workflow
- [ ] Add support for citation management and bibliography generation

---

## Contribution

Contributions, issues, and feature requests are welcome.
Feel free to check the [issues page](https://github.com/eng-james-o/AutoLitRev/issues).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
