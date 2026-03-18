# AutoLitRev TODO List

Based on the roadmap in README.md, here are the next steps for implementation:

## Article Retrieval

- [/] Implement multi-source article retrieval
  - [x] Implement ArXiv API integration
  - [x] Implement PubMed API integration
  - [ ] Implement CrossRef API integration
- [ ] Implement actual API calls for `app/retrieval.py`
- [ ] Add support for checking open access versions

## User Interface

- [ ] Build article screening interface
- [/] Complete QML pages for all steps of the workflow (Initial versions implemented)
- [ ] Integrate QML controllers with the UI components

## AI Engine

- [x] Integrate review generation engine in `app/ai.py`
- [ ] Add support for different research methodologies
- [ ] Implement thematic analysis logic

## Editor & Export

- [ ] Add integrated document editor
- [/] Add export options for PDF and other formats (DOCX, TXT, MD implemented)
- [ ] Add support for citation management and bibliography generation

## Testing & Docs

- [ ] Write unit and integration tests in `tests/`
- [ ] Complete developer and user documentation in `docs/`
