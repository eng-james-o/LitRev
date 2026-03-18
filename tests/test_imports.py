import unittest
import sys
import os

# Add the project root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

class TestImports(unittest.TestCase):
    def test_app_core_imports(self):
        try:
            import app.config
            import app.models
            import app.ai
            import app.retrieval
            import app.writing
            print("Core modules imported successfully")
        except ImportError as e:
            self.fail(f"Core import failed: {e}")

    def test_app_pyside6_imports(self):
        # We expect this might fail with Segfault in this environment
        # but we want to check for ImportErrors specifically
        try:
            import app.controllers
            import app.main
            print("PySide6 modules imported successfully")
        except ImportError as e:
            self.fail(f"PySide6 import failed: {e}")

if __name__ == '__main__':
    unittest.main()
