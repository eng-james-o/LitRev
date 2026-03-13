import unittest
import sys
import os

# Add the project root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

class TestImports(unittest.TestCase):
    def test_litrev_core_imports(self):
        try:
            import litrev.config
            import litrev.models
            import litrev.ai
            import litrev.retrieval
            import litrev.writing
            print("Core modules imported successfully")
        except ImportError as e:
            self.fail(f"Core import failed: {e}")

    def test_litrev_pyside2_imports(self):
        # We expect this might fail with Segfault in this environment
        # but we want to check for ImportErrors specifically
        try:
            import litrev.controllers
            import litrev.main
            print("PySide2 modules imported successfully")
        except ImportError as e:
            self.fail(f"PySide2 import failed: {e}")

if __name__ == '__main__':
    unittest.main()
